"""Verify interactive attachment and disconnect survival on an existing test VM.

Uses a real PTY only to test the consoles. Operational automation uses RPC.
Pass a JSON argv prefix for transports, e.g. ["docker", "exec", "-it", ...].
No transcripts or remote exception payloads are printed.
"""

import argparse
import errno
import json
import os
import pty
import re
import select
import signal
import time


def session(command, steps):
    pid, fd = pty.fork()
    if pid == 0:
        # Erlang disables terminal job control for an absent/dumb TERM.
        os.environ["TERM"] = "xterm-256color"
        os.execvp(command[0], command)
    buffer = b""
    deadline = time.monotonic() + 20
    status = None
    try:
        while time.monotonic() < deadline:
            if steps and re.search(steps[0][0], buffer):
                _, response = steps.pop(0)
                buffer = b""
                if response:
                    os.write(fd, response)
            readable, _, _ = select.select([fd], [], [], 0.1)
            if readable:
                try:
                    chunk = os.read(fd, 4096)
                except OSError as error:
                    if error.errno != errno.EIO:
                        raise
                    chunk = b""
                if not chunk:
                    break
                buffer += chunk
                if len(buffer) > 65536:
                    raise RuntimeError("console output exceeded its budget")
        if steps:
            raise RuntimeError("console did not confirm the expected target and exit")
        for _ in range(20):
            done, status = os.waitpid(pid, os.WNOHANG)
            if done:
                break
            status = None
            time.sleep(0.1)
        if status is None or os.waitstatus_to_exitcode(status) != 0:
            raise RuntimeError("client did not exit successfully")
    finally:
        os.close(fd)
        if status is None:
            try:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            except ProcessLookupError:
                pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client", required=True)
    parser.add_argument("--node", required=True)
    parser.add_argument("--prefix", default="[]", help="JSON argv transport prefix")
    parser.add_argument("--iex", action="store_true")
    args = parser.parse_args()
    if not re.fullmatch(r"[A-Za-z0-9_]+@127\.0\.0\.1", args.node):
        parser.error("use the exact loopback test node")
    prefix = json.loads(args.prefix)
    if not isinstance(prefix, list) or not all(isinstance(x, str) for x in prefix):
        parser.error("prefix must be a JSON list of argv strings")
    command = prefix + [args.client]
    marker = rb"\r?\nINSPECT_TARGET=" + re.escape(args.node.encode()) + rb"\r?\n"
    rpc_marker = rb"confirmed_node=" + re.escape(args.node.encode()) + rb"\r?\n"

    def verify_rpc():
        session(
            command + ["rpc", args.node, "erlang", "node", "[]", "2000"],
            [(rpc_marker, b"")],
        )

    verify_rpc()
    session(
        command + ["console", args.node],
        [
            (rb"\)\d+> ", b'io:format("INSPECT_TARGET=~s~n", [node()]).\n'),
            (marker, b"\x07"),
            (rb"--> ", b"q\n"),
        ],
    )
    verify_rpc()
    print("erlang_console_and_disconnect_survival=passed")
    if args.iex:
        session(
            command + ["iex", args.node],
            [
                (rb"iex\([^\r\n]+\)\d+> ", b'IO.puts("INSPECT_TARGET=#{node()}")\n'),
                (marker, b"\x03"),
                (rb"BREAK:", b"\x03"),
            ],
        )
        verify_rpc()
        print("iex_console_and_disconnect_survival=passed")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        raise SystemExit("Console acceptance failed; private transcript suppressed")
