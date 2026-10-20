# Lightweight runtime inspection: current scope and evidence

## Corrected boundary

The owner rejected the instrumented Dash pilot. The accepted goal is a reachable
BEAM runtime with dynamic operator investigation. Service setup should normally
be limited to runtime naming, protected cookie access and private connectivity.
Inspection does not justify application modules, fixed SQL probes, generated
queries, schema changes or a dedicated diagnostic API.

The earlier implementation applied application-persistence conventions to
operational SQL and turned validation exercises into shipped interfaces. Its
passing tests established behavior, not suitability for the requested scope.
Dash commit `4e650211f85119e456ecff4df043b10dcd85055b` was reverted by
`3a19553`. The resulting tracked tree exactly matches its parent baseline
`ea45f9505d84f66d5fefeee64f71c13a0173cb98`. The generated client beam was also
removed. No deployed service was changed.

The rejected Dash patch is removed from this repository. Previous pilot results
remain in Git history (`ec36228` and `295d56c`); they are not a recommended
integration or current lightweight-runtime qualification.

## Generic dynamic client

The optional client in `tools/beam` stays outside application code. `rpc` calls
an existing export. `eval` reads an ad hoc expression from stdin, parses it on
the client and sends its abstract syntax to the confirmed target's OTP stdlib
`erl_eval:exprs/2`. It installs no application module and invokes no compiler.
The client can be temporary operator tooling on a selected host.

Expressions have full operator authority, including effects and I/O. The client
is not a sandbox or redaction boundary. Source input is capped at 64 KiB;
returned-value formatting retains the previous depth/size caps. Finite RPC
waiting does not cancel target execution. Select bounded, non-sensitive results
in the expression itself and keep trace cleanup independent of the client.

Primary contracts checked: [Erlang expression interpreter](https://www.erlang.org/doc/apps/stdlib/erl_eval.html),
[expression parsing](https://www.erlang.org/doc/apps/stdlib/erl_parse.html), and
[RPC](https://www.erlang.org/doc/apps/kernel/erpc.html). Validation uses the
consumer-selected OTP 28.5.0.7, not an assumption about the current documentation
release. Voyager's separately reviewed revision remains
`577706b237899229b7cc496522a58d372157a000`; it needs OTP 27+ and target compiler
support for its in-memory helper. No live Voyager MCP session is qualified.

## Current checks

Run `sh tools/beam/check.sh` with the selected OTP and Python 3. It owns only a
disposable fixture VM, with no application database or persistence code.

- The new dynamic-expression case initially failed with `Unknown mode`.
- After implementation, target identity, bindings/list comprehension and an ad hoc
  process/supervisor/ETS metadata expression passed using existing runtime APIs.
- Target `compile` remained unloaded after the dynamic probes.
- Expression exceptions suppressed their private payloads. Oversized/malformed
  source and timed-out evaluation returned failure. The timeout test makes no
  claim that evaluation was cancelled.
- Existing RPC, real Erlang attachment, disconnect survival, stopped-node,
  wrong-cookie, timeout-bound and missing-module checks passed.

Local logs: `/private/tmp/gleam-inspect-dynamic-red.log` and
`/private/tmp/gleam-inspect-dynamic-green.log`. Console acceptance uses a PTY only
for attachment testing; operational automation uses one-shot RPC/expressions.
No current application-specific SQL or image integration is required or claimed.

The earlier read-only Fly observation found an unnamed service and no reachable
EPMD on Machine `287e355a7e2e98`. No later deployment or restart occurred. That
observation identifies missing access prerequisites, not successful deployed
attachment for this client.
