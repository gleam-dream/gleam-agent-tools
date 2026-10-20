"""Observe repeated public app start/stop without altering application source."""
import json
import subprocess
from pathlib import Path

run = Path(__file__).resolve().parent
app = Path("/code/gleam-dream/oversight/apps/support_desk")
paths = sorted(str(p) for p in (app / "build/dev/erlang").glob("*/ebin"))
expression = """
{ok, _} = application:ensure_all_started(support_desk),
{ok, App1} = 'support_desk@app':start(),
{ok, nil} = 'support_desk@app':stop(App1),
timer:sleep(300),
First = processes(),
{ok, App2} = 'support_desk@app':start(),
{ok, nil} = 'support_desk@app':stop(App2),
timer:sleep(1000),
Second = processes(),
Remaining = [P || P <- Second -- First, is_process_alive(P)],
io:format("AFTER_FIRST_STOP=~p AFTER_SECOND_STOP=~p NEW_LIVE_PROCESSES=~p~n", [length(First), length(Second), length(Remaining)]),
lists:foreach(fun(P) -> io:format("REMAINING ~p~n", [process_info(P, [registered_name, current_function])]) end, Remaining),
halt().
"""
command = ["erl", "-noshell", "-pa", *paths, "-eval", expression]
result = subprocess.run(command, cwd=app, capture_output=True, text=True, timeout=30)
(run / "support-stop-probe.log").write_text(result.stdout + result.stderr)
(run / "support-stop-probe.json").write_text(json.dumps({
    "command": command, "cwd": str(app), "exit": result.returncode,
    "scope": "Two public app.start/app.stop cycles, requiring successful stop Results, no tickets or tool effects; inspect surviving process names/functions after grace; VM then exits.",
}, indent=2) + "\n")
print(result.stdout)
print(result.stderr)
raise SystemExit(result.returncode)
