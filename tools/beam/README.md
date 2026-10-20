# BEAM inspection tools

This directory contains the optional runtime tools used by `gleam-inspect`.
Copy them into a service only when its existing release commands lack these
capabilities. The [operator guide](../../docs/beam-inspection.md) covers setup,
investigation, Voyager MCP and database ownership. The skill remains useful on
its own.

## Build and ship

Use the consumer's selected OTP:

```sh
mkdir -p ebin
erlc -Werror -o ebin beam_tool.erl
```

Ship `beam-tool`, `ebin/beam_tool.beam` and `LICENSE` together. Runtime calls need `erl`,
not this source file or `erlc`. IEx needs compatible client and target Elixir/IEx
runtime modules. Recon must be a target runtime dependency when used.

## Commands

| Command | Behavior |
| --- | --- |
| `./beam-tool run NODE ERL_ARGS...` | Names the existing service bootstrap and binds distribution to loopback. |
| `./beam-tool console NODE` | Confirms the exact target, then attaches Erlang. |
| `./beam-tool iex NODE` | Checks target IEx availability, then attaches IEx. |
| `./beam-tool rpc NODE MODULE FUNCTION 'ERLANG_LIST' [TIMEOUT_MS]` | Confirms the exact target and invokes one exported function. |
| `./beam-tool cookie` | Imports a private file or platform secret into the service user's cookie home. |

The default naming mode is long, with names ending in `@127.0.0.1`.
`BEAM_NAMING=short` supports an existing short-name deployment. Clients receive
unique hidden names. Service arguments must not contain another naming or cookie
option. Inherited `ERL_FLAGS`, `ERL_AFLAGS` and `ERL_ZFLAGS` are refused.
Migrations, builds and recovery helpers do not use `run`.

RPC arguments are parsed as an Erlang list term, without expression evaluation.
Quote generated module names and `$`-suffixed process names appropriately for
the shell. Timeouts default to 5000 ms and must be 1–30000 ms. Target confirmation
has a separate timeout capped at 2000 ms. Timeout does not cancel a remote effect.

The client prints target confirmation to stderr. Results have depth 20 and a
64 KiB formatted-output ceiling. Connection faults, exceptions and top-level
`{error, _}` results exit nonzero with private error details suppressed. Other
application result shapes need caller checks. Successful results are not
redacted: automated calls must select reviewed metadata projections. This is a
trusted operator tool with arbitrary exported-function access, not a read-only
server or a sandbox.

For cookie import, supply `BEAM_COOKIE_FILE` or `BEAM_COOKIE`, never both. File
sources must be regular, non-symlink files owned by the service user with mode
0400/0600. The tool writes that user's `.erlang.cookie` with mode 0600. It strips
secret-source variables from launched runtimes. A root-owned secret mount needs
a private service-owned copy before privilege drop. Working same-user local
cookies need no import.

## Verify

Inside an environment supplying the consumer's OTP and Python 3:

```sh
sh ./check.sh
python3 ./check-consoles.py --client ./beam-tool --node service@127.0.0.1 --iex
```

`check.sh` owns a disposable VM and verifies Erlang attachment, RPC, disconnect
survival, wrong-cookie/stopped-node failures, timeout bounds, missing modules
and error-payload privacy. The second command additionally checks IEx against
an existing disposable service with compatible target modules.

For container console acceptance, add
`--prefix '["docker","exec","-it","--user","app","CONTAINER"]'` and use the
container's client path. This PTY test only validates attachment and disconnect;
operational automation uses RPC. It bounds waits and transcript size and prints
no raw transcript. Host database and tracing lifecycles need their own checks.

Imported byte-for-byte from `lostbean/skills` commit
`ce969335b4c94d3129217280c1c77081e55aa193`. This repository carries the runnable
files directly; no checkout of that project is required. The accompanying
[MIT license](LICENSE) applies to the imported code. See the
[validation record](../../research/live-inspection.md) for consumer evidence.
