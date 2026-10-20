# Live Gleam inspection

The portable `gleam-inspect` skill owns investigation of an existing BEAM service. It selects health/log surfaces, exact-target RPC, interactive consoles, optional Voyager MCP, Recon, or database transactions from the question being asked. Its deployment boundary is a selected existing instance and its service identity, independent of the hosting provider. Fly is the Dash pilot transport, not a required abstraction.

## Boundaries and delivered changes

The collection now has 20 independent skills. `gleam-otp` retains actor design, protocol and recovery ownership; its discovery description no longer attracts live attachment tasks. The new skill is one self-contained file within the collection's 650-word/80-line limit. It has no required framework installation or auxiliary skill load.

The reference implementation already existed as uncommitted work when this task began. It was inspected and reused, not recreated. In `/code/lostbean/skills`, development setup owns distribution, cookies, packaging and optional attachment/RPC tools; diagnosis owns investigation; language guidance owns actor compatibility; project setup owns discovery. Those boundaries remain intact. The new consumer-facing guide does not create a second runtime framework.

This task adds a reusable host-side `check-consoles.py` to the existing `skills/bootstrap-dev-env/beam-tools/` toolkit and copies it into Dash. It tests real Erlang/IEx attachment using a PTY, confirms the node from inside each console, exits the client and checks RPC afterward. Waits and transcript size are bounded; raw transcripts are suppressed. JSON argv prefixes support container transport without shell interpolation. The generic client check and Dash's local/image checks now exercise it. Operational automation still uses RPC.

Source setup/diagnosis guidance and Dash's existing runbook now explain Voyager's target requirements, MCP endpoint and schemas, selected-node limitation, output privacy and scan cost. The framework design distinguishes precompiled RPC from Voyager's runtime compilation. No new server, public port, HTTP evaluation endpoint, schema or domain mutation API was added. No GSH integration is present.

## Primary source review

- Voyager checkout: `577706b237899229b7cc496522a58d372157a000`, read on 2026-10-20. The [connection guide](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/docs/connecting_to_a_node.md) specifies OTP 27+ and the target `compiler` application. [CodeInjector](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/lib/voyager/services/code_injector.ex) confirms target-side compilation and in-memory loading. This is more specific than the README's “no setup” wording.
- [MCP server](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/lib/voyager/mcp/server.ex), [process tools](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/lib/voyager/mcp/tools/process_list.ex), [process detail](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/lib/voyager/mcp/tools/process_info.ex), [selected-node dispatch](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/lib/voyager/mcp/tools/remote.ex) and loopback endpoint/router were read. `node_info`, `process_list` and `ets_list` exist. There is no node parameter binding every MCP call to the operator's intended target; the desktop session selects it. Confirmation before/after a sequence cannot prevent a concurrent connection switch.
- `process_list` can return only five numeric metadata rows while scanning the node's process set. `process_info` includes more than a redacted metrics projection. Term budgets do not remove secrets or customer content. ETS content tools are deliberately excluded from automated evidence defaults.
- Dash's lock pins `gleam_otp` 1.3.0. Its installed `gleam_otp_external.erl` supports `get_state`, `get_status`, `suspend` and `resume`; the source explicitly leaves replacement, code change, termination and debug requests unsupported. The guide recommends public domain APIs for mutation.
- [Erlang distribution](https://www.erlang.org/doc/system/distributed.html), [erpc](https://www.erlang.org/doc/apps/kernel/erpc.html), [Recon 2.5.6](https://hexdocs.pm/recon/recon_trace.html), and [Fly SSH selection](https://fly.io/docs/flyctl/ssh-console/) were refreshed. Local and image probes settle the exercised runtime claims, rather than transferring current-documentation behavior to an untested target.

## Validation

Commands ran on 2026-10-20 using each repository's Nix tooling. Dash base was `ea45f9505d84f66d5fefeee64f71c13a0173cb98` plus its pre-existing inspection changes and this task's console-test/runbook changes.

| Surface | Local | Packaged Dash image | Actual Fly |
| --- | --- | --- | --- |
| Exact node and scripted RPC | Passed | Passed | Blocked by deployed prerequisites |
| Erlang and IEx attachment; service survives disconnect | Passed on actual Dash main | Passed on actual Dash main | Not available |
| Processes, mailbox lengths, memory and stack MFAs | Passed | Passed | Not available |
| Supervisor children and ETS metadata | Backend checks | Passed | Not available |
| Recon rankings and event/deadline-bounded tracing | Passed | Passed | Not attempted |
| Target trace cleanup after client interruption | Passed | Normal completion tested | Not attempted |
| Existing-pool verified READ ONLY | Passed | Passed | Not available |
| Disposable exact-key/expected-value repair and rollback | Passed | Passed | Not attempted |
| Wrong cookie, stopped node, missing module, sanitized errors | Reusable client passed | Shared client packaged | No fault injection |
| Cookie owner/mode and actual loopback listeners | Normal same-user cookie | Passed | No inspection cookie read |
| Selected Machine/user and health after SSH disconnect | Not applicable | Not applicable | Passed |

The packaged image is `dash-gleam-inspect:20261020`, manifest digest `sha256:1b75bc09cc7fd18811208b78daeea03da39b0d9570cd4f9e7bcfeed77ca05958`. It was built with Dash's current Dockerfile and matching application inputs. Frontend placeholders and private SQLite fixtures qualify runtime packaging only. The runtime has no Gleam executable, application checkout, Git checkout or client source file. Erlang/Elixir runtime compiler modules remain present for IEx; this is not a claim that all compiler modules are absent. No build compiler was invoked by inspection.

Reproduce from `/code/lostbean/skills`:

```sh
nix develop --command sh skills/bootstrap-dev-env/beam-tools/check.sh
```

Reproduce from `/code/dash-bank/dash`:

```sh
nix develop --command bash tools/scripts/check-inspection.sh
nix develop --command python3 tools/scripts/check-inspection-image.py dash-gleam-inspect:20261020
nix develop --command python3 tools/scripts/check-telemetry.py
nix develop --command bash -c 'cd backend/api && gleam test'
```

Local/image acceptance passed. Squirrel freshness passed as part of local acceptance. The one-connection fixture verified connection reuse after READ ONLY and rollback. The repair returned `{ok,{rollback_proof,1,1,true}}`; the bounded trace returned `{ok,{trace,1,true}}`. The Sinal acceptance verified JSON stdout; all 21 backend tests passed. Raw local logs are `/private/tmp/gleam-inspect-{client,local,image,telemetry,tests}.log` for this session.

The first console-test run failed because an absent/dumb `TERM` disabled Erlang terminal job control. A content-free disposable probe established the cause. The test now explicitly sets terminal capabilities; both consoles passed locally and in the image. No application logic changed for this correction.

All 20 skill entry points passed metadata, single-file, discovery, link, fence and size checks; 23 unchanged exact-revision local source paths were rechecked. Three Retrace paths remain remote-only evidence from the previous review. `gleam-inspect` is 47 lines and 649 whitespace-delimited words. Source/consumer console-test copies have identical SHA-256 `b6c805113d3a6fa8547add75a09f391b2d97fd84d80dd98b4214ba14bd1cb396`. Both repositories' current-system `nix flake check` passed, and whitespace checks passed.

The framework design PDF was regenerated and its affected pages 69–70 and neighbors 68/71 inspected at normal reading scale. The changed text and behavior cards are readable with no clipping. Artifact SHA-256: `0b732aff91c6831b73bd272ef6d8c4dc4e23a4650ea8f040bc924a0abb7d1ae0`. This is focused author inspection, not a whole-layer presentation review. The composite design check passed with its existing CI scope: `nix run .#design-gate-check -- docs/design . --nested-project skills/new-design/reference/order-lifecycle`. An initial invocation without that nested-project argument reported the shipped example as a second mislocated layer; using the repository's declared CI scope resolved those diagnostics. Existing uncited-ADR advisories remain outside this task.

## Authenticated Fly evidence and limits

After the operator authenticated flyctl, read-only probes selected existing Machine `287e355a7e2e98` (`dash-readonly-db-probe`), region `gru`, image `registry.fly.io/dash-abertura@sha256:0b61b1253384bdee9e25da502c61b4f6cc52422b7731d5a1092817e459c653fe`. It was started, its readiness check was passing, and only HTTP ports 80/443 were published.

SSH explicitly selected `--machine 287e355a7e2e98 --user app`. It confirmed UID 100, HOME `/home/app`, and the matching `FLY_MACHINE_ID`. The inspection client was absent and `epmd -names` could not reach EPMD. A separate unnamed helper VM inspected only the presence of `-name`/`-sname` in the service's startup arguments and printed `service_startup_naming_flag=false`; argument values were not output. A subsequent localhost `/api/ready` request exited successfully.

This establishes an actual deployed configuration gap, not a passing deployed attachment. No deployed console, RPC, tracing or pool query was possible through the intended surface. No Machine was created, restarted or deployed, no secret changed, and no customer query or deployed write ran. Deploying the prepared configuration and provisioning its cookie are separate mutating actions.

Voyager was source-reviewed at the revision above. The desktop application is not installed here; no live MCP session or Voyager-to-Fly tunnel is qualified. Its tools supplement the tested RPC workflow. No new fresh-agent behavioral evaluation or independent-review result is claimed for this skill.
