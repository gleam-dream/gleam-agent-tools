# Generic BEAM operator client

Use existing release/native tools first. This optional client provides one-shot
RPC and dynamic expressions when the runtime lacks a convenient client command.
It belongs to the operator's tooling, not the application's diagnostic API.
The [guide](../../docs/beam-inspection.md) describes minimal runtime setup.

Compile once with the selected OTP:

```sh
mkdir -p ebin
erlc -Werror -o ebin beam_tool.erl
```

Keep `beam-tool`, `ebin/beam_tool.beam` and `LICENSE` together. They can be used
from a development tool directory or copied temporarily to a selected remote
host. No application source, dependency or image change is required just to
supply this client. The target needs the existing functions being called;
`eval` uses OTP stdlib's interpreter without compiling a target module.

| Command | Behavior |
| --- | --- |
| `./beam-tool console NODE` | Confirm the target, then attach Erlang. |
| `./beam-tool iex NODE` | Attach IEx when compatible client and target modules exist. |
| `./beam-tool rpc NODE MODULE FUNCTION 'ERLANG_LIST' [TIMEOUT_MS]` | Call one existing exported function. |
| `./beam-tool eval NODE [TIMEOUT_MS] < PRIVATE_EXPRESSION_FILE` | Interpret ad hoc Erlang expressions on the target. |
| `./beam-tool run NODE ERL_ARGS...` | Optional naming/loopback wrapper around an existing bootstrap. |
| `./beam-tool cookie` | Optional private-cookie import for deployment setup. |

`eval` reads at most 64 KiB of source from stdin. Expressions end with a period
and may use bindings, anonymous functions and existing APIs. Form the expression
for the current question; do not install a fixed set of application probes.
This is full operator access, including arbitrary effects and I/O, not a sandbox.
Never evaluate untrusted input. Select bounded, non-sensitive evidence yourself.

Both `rpc` and `eval` confirm the exact target before execution. Per-call timeouts
are 1–30000 ms (default 5000), with a separate confirmation timeout capped at
2000 ms. Timeout does not cancel a remote effect. Returned values have a depth
limit of 20 and formatted output cap of 64 KiB; these do not bound remote work,
prevent expression I/O, or redact results. Top-level `{error, _}` results and
invocation failures exit nonzero; raw exception payloads are suppressed.

Default names are long names ending in `@127.0.0.1`; `BEAM_NAMING=short` supports
an existing short-name service. Client names are unique and hidden. Match the
service user's cookie home. Working same-user cookies need no provisioning.
`cookie` accepts either `BEAM_COOKIE_FILE` (service-owned, non-symlink, mode
0400/0600) or a platform-provided `BEAM_COOKIE`. It writes `.erlang.cookie` with
mode 0600. Never pass cookie values in argv. Secret-source variables are removed
from child runtimes; privileged mounts need service-owned private copies first.

`run` is optional. Prefer adding naming flags to the host's existing runtime
configuration when that is smaller. Do not route compilers, migrations or
recovery helpers through it. Shared `ERL_FLAGS`/`ERL_AFLAGS`/`ERL_ZFLAGS` are
refused. New distribution/EPMD listeners use loopback; check existing listeners.

Test only against disposable services:

```sh
sh ./check.sh
python3 ./check-consoles.py --client ./beam-tool --node service@127.0.0.1 --iex
```

The first check owns its fixture VM. The second uses an existing test VM with
IEx available. It verifies real console attachment and disconnect survival via
a PTY; operational automation uses one-shot commands. Neither requires a database
or installs application probes.

The client originated in `lostbean/skills` commit
`ce969335b4c94d3129217280c1c77081e55aa193`; this version adds dynamic expression
evaluation. Its [MIT notice](LICENSE) remains included. See
[current evidence](../../research/live-inspection.md) for scope and limitations.
