# LLM Wire, Fabric, Relay, and Retrace source refresh

Research date: 2026-10-20. This pass produced four consumer skills, each one self-contained file. It refreshed source evidence after the collection's scope and format decisions. It did not create recipes, a router, package implementations, or provider evaluations.

## Source identity

All four inspected package working trees were clean. The first three local revisions also matched remote main when fetched through the GitHub connector. Retrace's remote main had advanced; its six-commit comparison was inspected separately below. Checkout identity is not consumer resolution.

| Repository | Inspected revision | Target / source distribution |
| --- | --- | --- |
| [LLM Wire](https://github.com/gleam-dream/llm_wire) | `aa74ce6d4364a851c12e58f5ae36afc5aece490a` | Erlang, Gleam >=1.18; unreleased Git candidate |
| [Fabric](https://github.com/gleam-dream/fabric) | `815fc5971e0ae8e7783f122e1ee00a7e50c08de7` | Erlang, Gleam >=1.18; unpublished Git package |
| [Relay](https://github.com/gleam-dream/relay) | `8d588eb45659779bc26db1e32711a21336b3741d` | Erlang, Gleam >=1.18; unpublished Git package |
| [Retrace](https://github.com/gleam-dream/retrace) | `13ef6f9c4304081bb60c13c9d6d3c0802170fdbb` | Portable core, JavaScript frontend, Erlang server; Gleam >=1.16; experimental Git packages |

Read `AGENTS.md` in each package. Read the authoring `write-a-skill`, `lang-gleam`, and `clausative` instructions. The user-requested portable metadata and single-file format take precedence over local catalog-specific metadata/resource conventions.

The style comparison was `/tmp/gleam-agent-research-elixir/plugins/elixir-dev/skills/{otp,oban}/SKILL.md`, checkout `ac3a5a1661a087158b39d5eb742b3c25fe3c7b44`. Retained direct descriptions, abstraction decisions, imperative rules, and red flags. Did not copy their broad scope, absolute slogans, or extensive examples.

## Freshly inspected sources

Paths below are relative to the named package. These are source observations and documented contracts unless explicitly called a run.

| Package | Primary evidence refreshed |
| --- | --- |
| LLM Wire | `README.md`; `src/llm_wire.gleam`; `src/llm_wire/{error,generation}.gleam`; `docs/design/generation/design.typ`; `docs/ORACLE.md`; public consumer README, `gleam.toml`, `manifest.toml`, `usage_conversation.gleam`, `usage_failures.gleam`, `generation_checks.gleam` |
| Fabric | `README.md`; `src/fabric/{tool,run,agent,graph,invoke,llm}.gleam`; root design including pending ledger; `docs/ORACLE.md`; usage README, waiting/reconciliation consumers, usage manifest; graph consumer README |
| Relay | `README.md`; `src/relay/client.gleam`; `src/relay/client/output.gleam`; root design including pending ledger; `docs/ORACLE.md`; usage README and manifest |
| Retrace | Root, frontend and server READMEs; `src/retrace.gleam`; recording/archive/replay designs; `examples/README.md`; basic manifest; `capture.gleam`, `client.gleam`, client adapter, `client_ffi.mjs`, frontend replay, `retrace_server.gleam`; `test/retrace_test.gleam` |

The earlier `gleam-agent-tools-research/second-pass/agents-replay.md` supplied leads. Its passing tests and blocked runs remain historical evidence; this pass does not relabel them as fresh runs.

## Rules and their evidence

| Guide rule | Refreshed evidence and limit |
| --- | --- |
| Prepare without I/O, then execute through a borrowed HTTP client | Wire facade `prepare`, `run`, `stream`; generation design admission and client ownership. Synchronous custom callbacks do not acquire a universal termination guarantee. |
| Distinguish final answers, tool requests, truncation, and refusal | Wire `Outcome` variants and public consumer. Structured `with_output` requires record root; preparation rejects unsupported provider schemas. |
| Retain opaque assistant-turn data and exact tool-result coverage | Wire `NeedsTools` documentation and public `usage_conversation` roundtrip assertions. The source demonstrates the intended public codecs; those assertions were not rerun. |
| Read timeout leaves stream readable; retry advice does not retry | Wire `ReadError`, `next_within`, `RetryProspect`, `ProviderDelay`, `advise`. Provider delay is uncapped, and `MaybeSent` allows paid remote work. |
| Agent control differs from graph control | Fabric root goal and graph API. `graph.new` binds definition/store/context/policy; pure selection/acceptance are application obligations. |
| Typed handlers preserve effect meaning | Fabric tool facade explicitly distinguishes `Explain` from `Uncertain`. Replay is allowed only for safe repeatable effects, with stable run/action identity; typed failures and cancellation are not replay triggers. |
| Completed model answer does not establish business success | Fabric README and run/action contracts; inspect retained action records. Awaiting and cancellation have separate lifecycle roles. |
| Recovery needs a store and application-owned resources | Fabric README, design and usage recovery. Memory is ephemeral; directory storage lacks power-loss durability. Context, credentials, and settings must be supplied again. Whole-agent elapsed deadline and agent progress streaming remain pending. |
| Approval covers the exact current action | Fabric design invariant: current policy, fresh context, matching requirement/revision, configured verifier. Changing arguments does not inherit approval. |
| MCP definition is one server/client contract | Relay README and public client/output interfaces. Runtime definition admission returns errors; authored invalid definitions may panic. A tool refusal is a completed exchange rather than a transport error. |
| Buffered and streaming mounts provide different capabilities | Relay README and root design explicitly document missing progress/disconnect visibility and buffered subscription 406. Mist streaming mounting retains those capabilities. |
| Relay evidence does not enforce business idempotency | Client error evidence and design retry section. Application principal/key receipts own duplicate suppression. Correlation and ids do not authorize requests. |
| Bearer verification and business permission have different owners | Relay README protection example and design. Stdio relies on its trusted parent. Continuation state does not bind principal/tenant/arguments to the retained stronger intended contract. |
| Record safe accepted transitions, not secrets | Retrace package contract and recording API. `record` does not persist; `resume` trusts caller cursor and does not establish exclusive ownership. |
| Capture needs the previous model; capture failure can leave application live | Public frontend `capture.observe` contract and implementation. Coordination messages must not reenter the domain recording hook. |
| Delivery acknowledgement is distinct from local persistence/archive | Frontend client adapter and `client_ffi.mjs`: save precedes upload; acknowledged session/cursor checked before row deletion; stopped client cannot consume a late upload completion. Fixed-delay retries leave a permanently invalid first batch blocking delivery. |
| Server admission is atomic; application owns transactions and workers | `retrace_server.accept` opens a transaction; `accept_in_transaction` explicitly requires an existing transaction and warns against nesting Pog 4 transactions. Server README assigns pools, object stores and archive workers to the host. |
| Failed replay step leaves old player usable | Core `step` immutable API and `recording_and_recovery_test`: missing/duplicate entry, contract mismatch, backwards time and reducer errors. Purity remains a convention, not a function-type proof. |
| Historical artifacts and inert replay remain application responsibilities | Replay design and frontend replay checks build/contract identity before reconstructing. Signing, artifact integrity and authorization do not follow from identity equality. |

## Dependency discrepancy resolved from committed source

Fabric's README still says its immutable Wire dependency lacks configured generation support. The manifest instead locks Wire to `aa74ce6d4364a851c12e58f5ae36afc5aece490a`. Inspected that committed Wire tree with `git show`: `src/llm_wire/generation.gleam` exists and `llm_wire.with_generation` is exported. Fabric's committed `fabric/llm.gleam` imports generation settings and uses that function. The guide therefore teaches the actual adapter API rather than repeating the stale sentence.

Fabric and its usage consumer resolve Wire to the revision above. Wire's and Fabric's public consumers lock HTTP Gun `db1cc9789af6cc6af2175d502dfcabb0451f4e2e`, Blueprint `45b361628af9d464a1670e8789b82a4dc310604f`, and Sinal `58c6e7dea08abccd9f187d16b9ef5f9bb86eb769`. A path dependency on one parent does not override those transitive Git resolutions. Do not infer compatibility from a different sibling checkout.

## Web refresh

Fetched the official [MCP latest specification](https://modelcontextprotocol.io/specification/latest), which redirected to [2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28), and the [tools contract](https://modelcontextprotocol.io/specification/2026-07-28/server/tools) on 2026-10-20. This corroborates the revision identity and conservative treatment of untrusted tool annotations. It does not establish Relay conformance.

Web opens of all four package GitHub repository pages returned cache misses. Exact-commit raw fetches of Wire's facade and Fabric's LLM adapter also returned cache misses. A later GitHub connector refresh successfully fetched the first three repositories' `branches/main` metadata and the Retrace commit comparison below. All skill source links now pin inspected revisions.

Relay's local oracle pins MCP schema commit `5f5440bb26a62e2cf3440b92da5a667efa03b267`, schema checksum `ef70b61f99b6d2e5e3b46863822eab08dff6a45bedc7a08914e0e5b133f40203`, and `@modelcontextprotocol/conformance@0.2.0-alpha.10`. These were inspected, not downloaded or executed here. Wire's ReqLLM comparison and Fabric's BeamWeaver comparison cover selected laws, not upstream suite parity.

## Retrace remote refresh

Fetched and inspected the [six-commit comparison](https://github.com/gleam-dream/retrace/compare/13ef6f9c4304081bb60c13c9d6d3c0802170fdbb...31352e53c7673fd948540e2f7cbe921a9903b203) through the GitHub connector. Remote main is `31352e53c7673fd948540e2f7cbe921a9903b203`; the local package checkout remains unchanged at `13ef6f9c4304081bb60c13c9d6d3c0802170fdbb`. The intervening commits are `f9337eb`, `a8ffd3b`, `01fa094`, `b3dafaa`, `28bf8fc`, and `31352e5`. Changes concern server erasure, upload-attempt state, schema compatibility, related tests, and design. Core/frontend code is unchanged in the comparison.

Inspected the server README patch, public server API and erasure implementation patch, archive design patch, and new [ADR 0019](https://github.com/gleam-dream/retrace/blob/31352e53c7673fd948540e2f7cbe921a9903b203/docs/adr/0019-complete-erasure-only-after-uploads-quiesce.md). Upload admission is now committed before dispatch. Fencing blocks new admission while pre-admitted uploads can dispatch later. `erase` takes `Eraser(remove, quiesced)` and returns `Erasing`, `AwaitingWriters`, or `Erased`; only `Erased` proves completion. The host's quiescence callback runs inside the session lock and must answer from local state. An in-flight attempt requires evidence both that no local dispatch can happen and that no already-issued request can publish. Worker death or credential revocation alone proves at most the first. Admission age is not a remote-write clock; a returned-failure age helps only against a provider-qualified maximum lifetime. The S3 adapter supplies no such policy.

The schema now refuses earlier tombstone layouts with `UnsupportedSchema`, has no in-place upgrade path, and adds an attempt sequence requiring runtime `USAGE`. Consumers must upgrade all workers before enabling retention. Updated the compact Retrace guide's erasure/schema rules and pinned its sources to the inspected remote revision. Retained source test assertions are not a passing runtime check.

## Checks and boundaries

Ran source identity/status commands and inspected committed manifest/API content for the disputed Fabric README claim. Ran mechanical skill checks for file count, metadata names, descriptions, line/word bounds, decision trees, red flags, and source links. No new code prototype was needed; primary source and committed consumer contracts settled the intended claims, including the refreshed Retrace erasure rules.

No package test suite, provider request, database service, browser/native check, MCP conformance suite, or agent effectiveness evaluation ran in this pass. No package source, dependencies, installations, commits, or publications changed. Public runtime guarantees in the skills are documented/source-observed contracts; fresh runtime validation is not claimed.
