# Applied Astra recommendations

The original [Astra High review](astra-high-review.md) is retained unchanged. Baseline commit `a873eac` precedes these revisions. This pass changes consumer guidance, not package behavior or supported targets.

| Skill | Applied recommendation | Preserved contract |
| --- | --- | --- |
| gleam | Lead with ordinary domain functions; show mutually exclusive states as variants; shorten naming detail. | Result/Option, checked ingress, exhaustiveness, observable refactor behavior. |
| gleam-lib | Lead with shared responsibility; add the depth test; merge overlapping red flags. | Conditional sans-I/O and ports, native types, independent configuration, purpose-led targets, external consumers. |
| gleam-ffi | Consolidate thin-boundary advice; explicitly allow required native atomic/resource mechanics and selected protocol implementations. | Domain/workflow policy in Gleam; unchecked declarations, representations, Promise, numeric and lifetime checks. |
| gleam-otp | Add concrete runtime ownership choices; make actor inspection conditional. | Mailbox limits, call panic semantics, owner-only receive, stale handles, restart dependencies, links versus monitors. |
| lustre | Lead with inspectable model/message transitions; remove the routine no-effect instruction. | Async revision guards, URL state, effect order, paint/context lifecycle, server ownership, simulation limits. |
| wisp | Lead with composable HTTP functions; broaden the governing rule; avoid ports without variation. | Consumed body and returned-request ownership, CSRF stripping, upload cleanup, real-adapter evidence. |
| http-gun | Explain pooling, bounded reads, body ownership and playback; surface absent transport capabilities as selection constraints. | Scoped streaming, shared cursor, read wait versus EOF, submission evidence, failed-body response heads, redaction limits. |
| gleam-sql | Explain visible SQL and derived access, Pog-only and independent migrations; retain database enforcement. | Live schema, numeric/nullability limits, transaction connection, post-write decode uncertainty, migration hashes/atomicity. |
| gleam-pubsub | Add refresh notification and simpler-recipient cases; make local Whisper qualification explicit. | Re-read recovery, incompatible pair, callbacks, stale names, atoms, local bounds, no distributed guarantee. |
| grind | Lead with request-independent execution and retained results; expose uncertainty resolution as an operating responsibility. | Admission receipts versus uniqueness/effects, outer commit, attributed resolution, cancellation, pruning, local capacity. |
| saga | Replace typed dependencies as justification with coordinated effects; add transaction alternative and reserve/charge example. | Reusable graph, typed ports, undo versus compensation, unknown effects, owner/reporting handles, checkpoint and scheduler limits. |
| sinal | Lead with independent producers and optional observers; state bounded forwarding limits. | Native interoperability, synchronous latency, atoms, callback failures, global setup, span bypass, context and units. |
| json-blueprint | Lead with aligned encoding/decoding/schema; make choices capability-first; merge callback-purity rules. | Published versus checkout API, placeholders, omission/null, closed records, exact numbers, bridge losses, finite schema profile. |
| warden | Explain protocol complexity hidden behind login/token roles; make custom-store advice conditional. | Per-configuration handles, existing custody recovery, both durable stores/stable key, release conditions, revocation and shutdown limits. |
| correio | Lead with the replaceable sender and independent challenge capability; shorten duplicated injection/setup wording. | Four delivery outcomes, unknown submission, intentional POST, command recovery, confirmed evidence, explicit revocation, recovery persistence limits. |
| llm-wire | Lead with common outcomes and preflight checks; name typed classification with a source-backed native answer example. | Schema profile, opaque assistant turns, complete tool results, single reader, read timeout, usage/submission/deadline evidence. |
| fabric | Explain approval/lost-runner cases that justify retained machinery; distinguish named bounds from an elapsed deadline. | Typed binding, adapter-specific resources, effect meaning, exact approval, uncertainty, replay restrictions, storage and incorporation. |
| relay | Explain shared definition and MCP selection; name resources/prompts/completion. | Frozen revision, buffered/streaming distinction, admission versus permissions, delivery evidence, application idempotency, untrusted hints. |
| retrace | Reorder around frontend reconstruction, safe previous-model capture and inert historical replay; make archival/erasure conditional. | Cursor/outbox, acknowledgement levels, artifact/authorization separation, host-owned lifetimes, upload quiescence and schema incompatibility. |

Repeated rules were consolidated only where the remaining instruction carries their meaning. No source qualification was converted into a release or compatibility guarantee. Oracle provenance stays in the original report; no inspiration or parity claim was invented for the skills.

## Verification

All 19 files passed checks for the portable single-file format, required decision/red-flag/source sections, size limits, metadata, links, source paths, and whitespace: 532–649 words and 55–67 lines each. All 21 unique exact-revision local GitHub paths resolved, and `git diff --check` passed. Counts are retained in [validation.json](validation.json).

Astra High independently reread the full collection and baseline diff. Its one finding was a Blueprint tree that could imply legacy decoders had modern shared-definition encoding. The tree and opening were corrected to distinguish the one-way legacy decoder with separate encoders from the modern bidirectional codec. No other material regression was found.

The editorial examples are prose; no new implementation or runtime probe was needed. Existing execution evidence remains historical with its original limits. The review establishes source-backed editorial fit, not measured agent effectiveness or fresh package-runtime qualification.
