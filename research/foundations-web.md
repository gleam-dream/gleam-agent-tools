# Foundations and web source refresh

Research date: October 20, 2026. This pass authored six single-file skills: Gleam, library design, FFI, OTP, Lustre, and Wisp. It reread primary guidance after the collection's scope was accepted. It used existing code probes only for claims retained in those skills.

## Source identity and method

The GitHub connector refreshed `georgeguimaraes/elixir-agent-tools` main to `ac3a5a1661a087158b39d5eb742b3c25fe3c7b44`, matching the materialized checkout. The current language, OTP, and Ecto skill bodies were read for editorial structure. Other authoring lanes also read Phoenix/Oban. Their technical rules were not treated as Gleam contracts.

All five local `lostbean/skills` Gleam resources were read: `SKILL.md`, `library-api.md`, `ffi.md`, `tooling.md`, and `beam-inspection.md`. Their source revision remains `477c0cd3bdfc3837e0d347c8e4607ea118ad6008`. Portable principles about consumer APIs and FFI ownership were adapted. Host-specific approval, design-layer, Nix, logging, and historical LSP policies retain their original owners. The [notice](../NOTICE.md) preserves the source licence.

The [Agent Skills specification](https://agentskills.io/specification) supplies the portable metadata contract. The new repository has no house catalog, so each file uses only `name` and `description`. Names match directories and normalize package underscores to hyphens. Each entry point works without a supporting resource or compulsory peer load.

## Fresh primary documentation

The following pages were actually opened during this pass. Versions identify the retrieved documentation, not universal package requirements.

| Area | Refreshed primary sources |
| --- | --- |
| Language | [Conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/), [use](https://tour.gleam.run/advanced-features/use/), [configuration](https://gleam.run/documentation/gleam-toml-reference/), [CLI](https://gleam.run/documentation/command-line-reference/), [compatibility](https://gleam.run/documentation/compatibility-reference/) |
| Foreign interfaces | [Externals](https://gleam.run/documentation/externals/), [multi-target externals](https://tour.gleam.run/advanced-features/multi-target-externals/) |
| Library design | Gleam sources above; [Ousterhout's modular-design lecture](https://web.stanford.edu/~ouster/cgi-bin/cs190-winter18/lecture.php?topic=modularDesign); adapted MIT consumer-design guidance |
| OTP | gleam_otp 1.3.0 [actor](https://gleam-otp.hexdocs.pm/gleam/otp/actor.html), [static supervisor](https://gleam-otp.hexdocs.pm/gleam/otp/static_supervisor.html), [factory supervisor](https://gleam-otp.hexdocs.pm/gleam/otp/factory_supervisor.html); gleam_erlang 1.3.0 [process](https://gleam-erlang.hexdocs.pm/gleam/erlang/process.html) |
| Lustre | 5.7.1 [core](https://lustre.hexdocs.pm/lustre.html), [state](https://lustre.hexdocs.pm/guide/02-state-management.html), [effects guide](https://lustre.hexdocs.pm/guide/03-side-effects.html), [effect API](https://lustre.hexdocs.pm/lustre/effect.html), [server components](https://lustre.hexdocs.pm/lustre/server_component.html), [simulation](https://lustre.hexdocs.pm/lustre/dev/simulate.html) |
| HTTP | Wisp 2.2.2 [API](https://wisp.hexdocs.pm/wisp.html) and [Mist adapter](https://wisp.hexdocs.pm/wisp/wisp_mist.html); Mist 6.0.3 [API](https://mist.hexdocs.pm/mist.html) |

Initial Lustre guide URLs without `/guide/` failed. The correct guide URLs above were fetched. Those failures are not evidence about the framework's behavior.

## Decision-changing rules

| Guide | Rule and evidence |
| --- | --- |
| Gleam | Separate fallibility from absence, annotate module functions, and preserve future-variant checking. The official conventions establish these rules; refactors must preserve caller-visible behavior. |
| Gleam | `use` is callback syntax. The tour's expansion supplies the mechanism; the guide avoids presenting it as an early return. |
| Gleam | Inspect resolved dependencies and test entry points. Configuration/CLI specify resolution and execution; a sibling checkout and an uninvoked test are insufficient evidence. |
| Library design | Design around the hidden responsibility and verify from an external consumer. This is an editorial design policy informed by the sources, not a compiler guarantee. |
| Library design | Choose targets from purpose, keep configuration independent, and expose meaningful ownership. The existing portable guidance and multi-target I/O constraints support this policy. |
| Library design | Exported constructors/variants are compatibility surface. `internal_modules` marks an unstable interface but permits imports; it is not access control. |
| FFI | A type declaration cannot validate the implementation's actual return. Official representations and focused dishonest-return/Result probes establish the boundary. |
| FFI | JavaScript async values and exact integers need explicit treatment. Promise and integer probes show the consequences under the selected runtimes. |
| OTP | A call timeout panics and does not cancel receiver work. The process API specifies failure cases; no new timeout-to-Error conversion is invented. |
| OTP | Restart strategy follows dependency ownership; direct handles and names have different restart behavior. Static/factory/process contracts supply the mechanisms. |
| OTP | Debugging support is operation/version-specific. Pinned actor/system source and the state-versus-trace probe refute a universal GenServer tracing recipe. |
| Lustre | Choose static rendering, ordinary views, browser applications, or components from state/lifetime needs. Core/state guidance supplies the distinction. |
| Lustre | Batched effects do not promise order; context subscription is distinct from arbitrary event listeners. The effect API supplies both limits. |
| Lustre | Stale-response rejection is application logic, not a built-in framework guarantee. The guide states it as a required design decision when newer requests supersede older ones. |
| Lustre | Server runtime and WebSocket lifetimes differ; simulation discards effects. Documented contracts and the simulator probe establish the narrower claims. |
| Wisp | Read bodies once and retain middleware's returned request. Body helpers consume streams without caching; checked/modified headers must reach subsequent handlers. |
| Wisp | Temporary upload cleanup depends on the adapter. Mist/compliant adapters clean at completion; others require an owner. Persist a file before that boundary if it must survive. |
| Wisp | Origin protection, authentication, and permission remain distinct. The documented CSRF helper accepts GET/HEAD and can strip cookies; the guide preserves those conditions. |

## Focused probe rerun

Used the retained [boundary lab](../../gleam-agent-tools-research/probes/README.md). This avoids duplicating a prototype whose claims and source already exist. Read its source and resolved manifest before rerunning it.

Environment: Gleam 1.19.2 at `/nix/store/jp0y9aa4kkfkp49vza4f10slpi66qznj-gleam-1.19.2/bin/gleam`, Erlang/OTP 28 (ERTS 16.4.0.6), Node 25.8.1. Locked libraries include gleam_stdlib 1.0.5, gleam_erlang 1.3.0, gleam_otp 1.3.0, Lustre 5.7.1, and gleeunit 1.11.0.

From `gleam-agent-tools-research/probes`, ran the selected compiler with `test --target erlang` and `test --target javascript`: **seven tests passed per target**. The BEAM warning `Actor discarding unexpected message: Debug(Trace(True))` and trace timeout are intentional observations. Target-specific tests differ, so this is not fourteen distinct cross-target laws.

No new prototype or application was needed. No live browser, Wisp/Mist listener, database, external provider, distributed node, deployment, or agent-effectiveness evaluation ran. The tests validate only the named FFI/runtime/rendering/simulation claims. Behavioral design recommendations and source contracts remain distinguished from executed checks.
