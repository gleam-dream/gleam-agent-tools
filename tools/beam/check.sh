#!/bin/sh
# Run inside a shell supplying Erlang; no customer application or credentials.
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
work=$(mktemp -d)
service_pid=
cleanup() {
  if [ -n "$service_pid" ]; then
    kill "$service_pid" 2>/dev/null || true
    wait "$service_pid" 2>/dev/null || true
  fi
  rm -rf "$work"
}
trap cleanup 0 HUP INT TERM
mkdir "$work/ebin"
cp "$here/beam-tool" "$work/beam-tool"
erlc -Werror -o "$work/ebin" "$here/beam_tool.erl"
cat >"$work/beam_check_fixture.erl" <<'ERLANG'
-module(beam_check_fixture).
-export([private_error/0]).
private_error() -> {error, <<"private_test_payload_must_not_print">>}.
ERLANG
erlc -Werror -o "$work/ebin" "$work/beam_check_fixture.erl"
node="beam_check_$$@127.0.0.1"
"$work/beam-tool" run "$node" -pa "$work/ebin" -noshell -eval 'timer:sleep(infinity).' >"$work/service.log" 2>&1 &
service_pid=$!
ready=0
for attempt in 1 2 3 4 5; do
  if "$work/beam-tool" rpc "$node" erlang node '[]' 1000 >"$work/rpc.log" 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
[ "$ready" = 1 ] || {
  echo 'service failed to start (private log retained only until cleanup)' >&2
  exit 1
}
python3 "$here/check-consoles.py" --client "$work/beam-tool" --node "$node"
"$work/beam-tool" rpc "$node" erlang is_alive '[]' | grep -qx true
if "$work/beam-tool" rpc "absent_$$@127.0.0.1" erlang node '[]' 1000 >"$work/stopped.log" 2>&1; then exit 1; fi
grep -q node_unreachable "$work/stopped.log"
if "$work/beam-tool" rpc "$node" erlang node '[]' 30001 >"$work/invalid.log" 2>&1; then exit 1; fi
# A private argument file avoids cookie material in process argv or test output.
printf '%s\n' '-setcookie inspection_test_incorrect_cookie' >"$work/wrong.args"
chmod 600 "$work/wrong.args"
if erl -args_file "$work/wrong.args" -name "wrong_$$@127.0.0.1" -noshell -hidden -pa "$work/ebin" -s beam_tool main -extra "$node" erlang node '[]' 1000 >"$work/wrong.log" 2>&1; then exit 1; fi
grep -q node_unreachable "$work/wrong.log"
if "$work/beam-tool" rpc "$node" beam_check_fixture private_error '[]' >"$work/private.log" 2>&1; then exit 1; fi
if grep -q private_test_payload_must_not_print "$work/private.log"; then exit 1; fi
# Code-loading failure must be an actionable nonzero result.
if "$work/beam-tool" rpc "$node" code ensure_loaded '[inspection_deliberately_missing]' >"$work/module.log" 2>&1; then exit 1; fi
"$work/beam-tool" rpc "$node" erlang is_alive '[]' | grep -qx true
printf '%s\n' 'PASS: node confirmation, RPC, disconnect survival, stopped node, wrong cookie, timeout bounds, missing module'
