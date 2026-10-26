"""Exercise the installed launcher through MCP and a real Gleam server."""

import json
import os
from pathlib import Path
import selectors
import subprocess
import sys
import tempfile
import time
import unittest

LAUNCHER = sys.argv.pop(1)


class Connection:
    def __init__(self, cwd, env=None):
        self.stderr = tempfile.TemporaryFile()
        self.process = subprocess.Popen(
            [LAUNCHER],
            cwd=cwd,
            env=env,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=self.stderr,
            bufsize=0,
        )
        self.selector = selectors.DefaultSelector()
        self.selector.register(self.process.stdout, selectors.EVENT_READ)
        self.buffer = b""
        self.sequence = 0

    def send(self, payload):
        self.process.stdin.write(json.dumps(payload).encode() + b"\n")
        self.process.stdin.flush()

    def request(self, method, params, timeout=120):
        self.sequence += 1
        wanted = self.sequence
        self.send({"jsonrpc": "2.0", "id": wanted, "method": method, "params": params})
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            while b"\n" in self.buffer:
                line, self.buffer = self.buffer.split(b"\n", 1)
                if not line.strip():
                    continue
                message = json.loads(line)
                if message.get("id") == wanted:
                    if "error" in message:
                        raise AssertionError(message["error"])
                    return message["result"]
                if message.get("method") == "roots/list" and "id" in message:
                    self.send(
                        {
                            "jsonrpc": "2.0",
                            "id": message["id"],
                            "result": {"roots": []},
                        }
                    )
            if self.selector.select(timeout=1):
                chunk = os.read(self.process.stdout.fileno(), 65536)
                if not chunk:
                    self.stderr.seek(0)
                    raise AssertionError(self.stderr.read().decode(errors="replace"))
                self.buffer += chunk
        raise AssertionError(f"Timed out waiting for {method}")

    def tool(self, name, arguments):
        result = self.request("tools/call", {"name": name, "arguments": arguments})
        text = "\n".join(item.get("text", "") for item in result.get("content", []))
        return result, text

    def close(self):
        self.process.stdin.close()
        try:
            self.process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.process.terminate()
            self.process.wait(timeout=5)
        self.selector.close()
        self.process.stdout.close()
        self.stderr.close()


class LauncherTest(unittest.TestCase):
    def test_starts_without_project_or_compiler(self):
        with tempfile.TemporaryDirectory() as temporary:
            connection = Connection(temporary, dict(os.environ, PATH="/not-provided"))
            try:
                connection.request(
                    "initialize",
                    {
                        "protocolVersion": "2025-06-18",
                        "clientInfo": {"name": "no-compiler-check", "version": "1"},
                        "capabilities": {},
                    },
                    timeout=15,
                )
                connection.send(
                    {
                        "jsonrpc": "2.0",
                        "method": "notifications/initialized",
                        "params": {},
                    }
                )
                catalog = connection.request("tools/list", {})
                self.assertIn("start_lsp", {t["name"] for t in catalog["tools"]})
            finally:
                connection.close()

    def test_non_project_startup_and_gleam_workflow(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            project = root / "project"
            (project / "src").mkdir(parents=True)
            (project / "test").mkdir()
            (project / "gleam.toml").write_text(
                'name = "launcher_test"\nversion = "0.1.0"\n'
            )
            source = project / "src/arithmetic.gleam"
            source.write_text(
                "pub fn add(a: Int, b: Int) -> Int { a + b }\n"
                "pub fn double(value: Int) -> Int { add(value, value) }\n"
            )
            (project / "test/arithmetic_test.gleam").write_text(
                "import arithmetic\npub fn double_test() { arithmetic.double(2) }\n"
            )
            connection = Connection(root)
            try:
                initialized = connection.request(
                    "initialize",
                    {
                        "protocolVersion": "2025-06-18",
                        "clientInfo": {
                            "name": "gleam-agent-tools-check",
                            "version": "1",
                        },
                        "capabilities": {},
                    },
                    timeout=15,
                )
                self.assertNotEqual(initialized["serverInfo"]["version"], "dev")
                connection.send(
                    {
                        "jsonrpc": "2.0",
                        "method": "notifications/initialized",
                        "params": {},
                    }
                )
                catalog = connection.request("tools/list", {})
                self.assertIn("get_diagnostics", {t["name"] for t in catalog["tools"]})

                result, text = connection.tool(
                    "blast_radius", {"changed_files": [str(source)]}
                )
                self.assertFalse(result.get("isError"), text)
                self.assertIn("double_test", text)

                result, text = connection.tool(
                    "list_symbols", {"file_path": str(source)}
                )
                self.assertFalse(result.get("isError"), text)
                self.assertIn("double", text)

                missing = project / "src/missing.gleam"
                result, text = connection.tool(
                    "blast_radius", {"changed_files": [str(missing)]}
                )
                self.assertTrue(result.get("isError"), text)
                self.assertIn("missing.gleam", text)

                broken = project / "src/broken.gleam"
                broken.write_text('pub fn broken() -> Int { "wrong type" }\n')
                result, text = connection.tool(
                    "get_diagnostics", {"file_path": str(broken)}
                )
                self.assertFalse(result.get("isError"), text)
                self.assertIn("Type mismatch", text)
                self.assertNotIn("Safe to proceed", text)

                broken.write_text("pub fn broken() -> Int { 42 }\n")
                result, text = connection.tool(
                    "get_diagnostics", {"file_path": str(broken)}
                )
                self.assertFalse(result.get("isError"), text)
                self.assertNotIn("Type mismatch", text)
                self.assertNotIn("not confirmed current", text)
            finally:
                connection.close()


if __name__ == "__main__":
    unittest.main(verbosity=2)
