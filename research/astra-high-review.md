# Independent architectural and editorial review of Gleam Agent Tools

Reviewed 20 October 2026. Scope: all 19 current `SKILL.md` files in `/code/gleam-dream/gleam-agent-tools/skills`, as independent consumer guides. This is a read-only review, not a package implementation audit, release qualification, or design-layer conformance verdict. No skills, packages, dependencies, research records, caches, or installations were changed. No tests were run. Only this report was written.

## Overall verdict

**The collection is technically careful and structurally sound, but only partly achieves the intended architectural teaching. Revise its emphasis before calling the editorial work complete.** Its best material explains consequential distinctions: typed workflow dependencies, request-body ownership, response-stream ownership, stable effect identities, recoverable custody, and the difference between completion evidence and uncertainty. Those are useful insights, not generic caution. The weakest material spends its opening and decision tree describing package machinery before establishing why a consumer would want the abstraction.

The right revision is smaller than a rewrite. Keep the 19 boundaries, portable single-file format, source qualifications, and foundation policy. Replace some installation reminders, repetitive red flags, and low-level branch inventories with a concrete use case, the complexity the abstraction removes, and a credible simpler alternative. Do not add a mandatory architecture template or turn every package into a lesson about ports.

Retrace, Sinal, JSON Blueprint, and Saga deserve the first substantive pass. Gleam OTP, Lustre, HTTP Gun, and Correio already communicate appreciable architectural judgment. Warden's density is largely justified by its protocol and recovery responsibilities. The pub/sub guide's unusually defensive posture is warranted by actual compatibility and lifecycle findings; it should not be made more enthusiastic to match the collection.

This verdict combines three kinds of claim:

- **Source-backed:** stated API behavior, source identities, oracle scope, and concrete mismatches checked below.
- **Editorial/owner taste:** which explanation should lead, what deserves limited space, and which comparisons improve selection.
- **Unmeasured hypothesis:** that the proposed emphasis improves agent choices. No comparative agent task evaluation has established that yet.

## Prioritized collection findings

### 1. Explain the value before allocating responsibilities — strong, highest priority

Several introductions are responsibility slogans rather than useful models. [JSON Blueprint line 8](/code/gleam-dream/gleam-agent-tools/skills/json-blueprint/SKILL.md:8) says to choose an installed API; [Grind line 8](/code/gleam-dream/gleam-agent-tools/skills/grind/SKILL.md:8) says to distinguish admission and effects; [Sinal line 8](/code/gleam-dream/gleam-agent-tools/skills/sinal/SKILL.md:8) names observation and handler lifetimes. These are correct but do not tell a newcomer why the library exists.

Replace each weak opening with two things: the recurring consumer problem and the useful mechanism. For example, Blueprint reduces drift between an encoder, decoder, and schema by defining them together. Sinal lets a producer describe an event without selecting its eventual consumers. Grind lets work be admitted now and executed independently later while preserving inspectable outcomes. The rest of each guide can then explain the limitations that make those promises honest.

Retrace is the clearest imbalance. Its introduction calls it “selected application-message recording,” and its first source link is the server erasure contract. The largest single rule concerns upload quiescence ([lines 8, 39, 63](/code/gleam-dream/gleam-agent-tools/skills/retrace/SKILL.md:8)). The source's own core story is reconstruction of an application state from a session; the basic consumer records accepted inventory commands with the previous model and reconstructs an inert view. Put that concrete frontend use case first, then core portability, optional delivery, optional archival, and conditional erasure obligations.

### 2. Turn feature menus into selection criteria — strong

A tree is useful only if its branches settle a real choice. “Need typed dependencies → Saga” is too broad: ordinary function composition has typed dependencies too ([Saga line 15](/code/gleam-dream/gleam-agent-tools/skills/saga/SKILL.md:15)). The distinguishing need is coordinated dependent work with scheduling, parallel branches, undo/compensation, or retained partial progress. Short synchronous sequencing remains ordinary `Result` composition; related database changes normally belong in one transaction when that covers the whole operation.

Likewise, [Sinal lines 16–19](/code/gleam-dream/gleam-agent-tools/skills/sinal/SKILL.md:16), [HTTP Gun lines 15–19](/code/gleam-dream/gleam-agent-tools/skills/http-gun/SKILL.md:15), and [Correio lines 14–19](/code/gleam-dream/gleam-agent-tools/skills/correio/SKILL.md:14) mostly choose APIs after selecting the package. Retain these useful distinctions, but add the prior decision in prose: independent telemetry consumers; pooled/owned outbound exchanges; provider-independent message submission or independent single-use challenges. No new router or composition recipe is needed.

Compare alternatives at the same use case. A plain callback is an alternative to telemetry when a caller must supply a required reaction. A log is enough for one operator-facing diagnostic. A plain typed function is enough for an internal operation without MCP peers. A database transaction is a better starting point than compensation for changes confined to one database. These are useful selection rules; a list of unrelated package names is not.

### 3. Compress repetition selectively; preserve outcome and ownership distinctions — strong

Most guides repeat a positive rule almost verbatim as a red flag. Examples: HTTP Gun's owner-bound reading at lines 34–35 and red flag 50; Sinal's permanent atoms and synchronous I/O at lines 26/30 and 44/45; Retrace's pre-transition capture and inert replay at lines 28/44 and 52/54. One short red-flag reminder is sometimes valuable; a second complete statement usually buys less than a concrete reason to choose the abstraction.

Delete or compress generic reminders such as “inspect public APIs first,” “report commands actually run,” and basic setup narration when they add no package-specific distinction. Retain source qualifiers where the consequence is concrete: Blueprint's misleading version number, the incompatible Roar/Whisper pair, unpublished dependency pins, and Retrace's package revision agreement.

Do **not** collapse all failure guidance into “timeouts are not cancellation.” Different packages preserve different authority:

- HTTP Gun/Relay retain submission evidence about a remote request.
- Grind reconciles admission receipts separately from uncertain handler effects.
- Saga distinguishes failed-attempt compensation from undo of completed steps.
- Warden can publish already obtained custody without consuming a code or refresh token again.
- Correio separates possible email submission from verification-command recovery.
- Fabric records uncertain tool effects before permitting dependent progress.
- Retrace erasure requires proof that an admitted upload cannot publish later.

Those distinctions are much of this collection's value. Preserve them even if a sentence resembles another guide's warning.

### 4. Teach composability through a consumer-visible benefit — strong

The foundation already has good taste: bounded scope, native types, configuration as values, typed binding before heterogeneous collections, deliberate targets, and no ports without actual variation. The package guides should demonstrate what these principles buy rather than repeat the vocabulary.

Good examples already exist in source: Correio injects one `Message -> Outcome` sender across SMTP, Postmark and capture; Relay reuses one definition for server decoding and typed client calls; HTTP Gun views share a pool while narrowing per-call policy; Saga describes a reusable graph once and supplies each run's input; Blueprint derives encoding, decoding and schema from one definition. Bring these benefits forward. Do not prescribe a new port layer around a working application merely because the foundational skill mentions typed ports.

Two foundation caveats deserve precision, not expansion. Sans-I/O and an injected synchronous HTTP callback are not interchangeable cross-target designs: the [Gleam conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/) explicitly discuss the promise mismatch. Also, thin FFI must retain legitimate native resource sequencing and atomic database constraints; “domain logic in Gleam” must not become “move atomic enforcement out of the database.” The present foundation mostly handles the first distinction already and should retain that restraint.

### 5. Use oracle comparisons to explain transferred ideas, not borrowed credibility — strong

None of the package introductions should imply “the Gleam version of X” guarantees parity. The oracle files document much narrower relationships. A short comparison can still be highly instructive: Saga gets dependent-step scheduling and compensation vocabulary from Reactor but exposes typed ports; Grind shares database-job concerns with Oban but deliberately refuses automatic replay of abandoned uncertain effects; Fabric borrows selected agent-loop expectations from a particular BeamWeaver fork and rejects several of its recovery hazards.

Keep the full oracle map in maintainer evidence. Put a comparison into a skill only when it changes a consumer's decision. JSON Blueprint's independent validator is verification provenance, not an architecture inspiration like Zod or Pydantic; no such donor was established. Retrace explicitly has no external oracle. Do not manufacture one from a resemblance to Redux DevTools or session-recording products.

### 6. Keep the current size cap; stop treating it as a target — strong

A read-only count found all 19 files within the contract: 503–646 whitespace-delimited words and 54–67 lines. `gleam-lib` has 646 words, Correio 642, Retrace 628, Warden 625, and FFI 620. The issue is allocation, not lack of room. Two short fit sentences can generally replace duplicated warning pairs. Prefer 450 useful words to 649 mechanically compliant words.

Do not increase the cap now. Revisit it only if a proposed revision demonstrably cannot retain a safety-critical consumer distinction within 650 words. The 80-line ceiling also currently rewards very long bullets; readability should be assessed at normal text width, not by line count alone.

## Per-skill assessment — all 19

### 1. `gleam` — strong foundation; trim low-value convention detail first

**Use case and choice.** Ordinary typed domain functions and refactoring, before introducing runtime or library machinery. Its “values/functions first” rule and Result/Option distinction are appropriate. **Distinctive value.** Exhaustive matching, checked ingress, meaningful state variants, qualified imports, coherent modules, and preservation of effects during refactoring.

**Minimal adjustment.** Compress compiler-enforced casing in [line 29](/code/gleam-dream/gleam-agent-tools/skills/gleam/SKILL.md:29) and the generic verification wording at lines 43–45. Spend that room on one tiny modeling contrast: a state with mutually exclusive optional fields becomes named variants when those combinations encode real domain rules. Avoid a blanket ban on booleans. Keep line 35's qualified formulation (“when a new variant should force a new decision”); package-specific expandable error projections sometimes intentionally use a stable classifier instead. The [official conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/) support its central advice. No broad rewrite needed.

### 2. `gleam-lib` — already strong; protect it from overgeneralization

**Use case and choice.** Discovering a reusable boundary with an actual responsibility/invariant, not merely extracting files. Ordinary modules remain preferable for application-specific work; public records suit ordinary data; opacity suits construction invariants.

**Distinctive value.** [Lines 29–45](/code/gleam-dream/gleam-agent-tools/skills/gleam-lib/SKILL.md:29) combine hidden decisions, caller-native types, reuse of ecosystem contracts, independent configuration, and derivation of repeated facts. This is the strongest statement of the desired house architecture.

**Minimal adjustment.** Merge the overlapping red flags at 59–60 and use the space for one concrete depth test: removing the abstraction should force callers to reproduce meaningful rules, not only rename calls. Keep sans-I/O conditional and preserve “add ports for actual variation.” Do not demand cross-target support by default or turn every public record into a builder. External-consumer verification is worth retaining because it tests the claimed abstraction from the caller's side.

### 3. `gleam-ffi` — correct policy, unnecessarily repeated thesis

**Use case and choice.** Exposing a missing platform/native capability through a sound Gleam interface. Prefer an existing suitable typed dependency; otherwise isolate the native call and representation/lifetime mechanics. Domain workflow choices remain in Gleam.

**Distinctive value.** A declaration is an unchecked promise; Promise behavior, foreign handle types, actual variants and exact numeric ranges matter. The retained dishonest-return/Promise probes directly illustrate this problem.

**Minimal adjustment.** The thin-boundary thesis occurs at [lines 8, 12, 27–28, 54](/code/gleam-dream/gleam-agent-tools/skills/gleam-ffi/SKILL.md:8). Keep one strong rule and one operational test. Add a short exception for necessary atomic native/resource mechanics, without weakening the domain-policy boundary. Avoid implying that wrapping a deliberately selected foreign protocol library always requires reimplementing that library in Gleam; distinguish external capability from application workflow. Keep actual public-runtime probes and the compilation/runtime distinction. [Official externals documentation](https://gleam.run/documentation/externals/) is the right source.

### 4. `gleam-otp` — one of the best guides

**Use case and choice.** Processes provide serialization, resource lifetime, concurrency, or fault isolation. Plain functions are sufficient for stateless calculations; a persistent abstraction is needed for recovery beyond runtime loss.

**Distinctive value.** [Lines 28–44](/code/gleam-dream/gleam-agent-tools/skills/gleam-otp/SKILL.md:28) explain responsiveness, mailbox bounds, subject ownership, call failure, restart dependencies, retained handles, and link/monitor distinctions. This is materially better than generic “use supervisors” advice.

**Minimal adjustment.** Retain almost all of it. Move the very specific `sys:trace` result behind an “if inspecting actors” clause, or compress it if space is needed for a concrete ownership example. Preserve its pinned 1.3.0 qualification. Do not copy the Elixir reference's claim that choosing `call` supplies backpressure for the whole system: this skill correctly limits that inference. No demand for ETS, actors, or extra processes solely to organize code.

### 5. `lustre` — strong, with room for a clearer opening payoff

**Use case and choice.** Interactive state whose behavior can be expressed as model transitions and rendered views. Static output needs no runtime; presentation reuse begins with functions; components earn independent state/lifetime.

**Distinctive value.** [Lines 12, 29–40](/code/gleam-dream/gleam-agent-tools/skills/lustre/SKILL.md:12) explain deterministic transitions, stale async results, URL state, effect ordering, paint timing, and server-runtime ownership. These are actual architectural decisions.

**Minimal adjustment.** Add that explicit model/message transitions make behavior inspectable and reproducible; this is the reason to choose MVU, beyond “return managed effects.” Compress the obvious `effect.none()` instruction at 36 if needed. Keep simulation's inability to execute effects, including its evidence limit; it is verified by the retained probe. Do not make a full frontend design guide or a router recipe. [Lustre core documentation](https://lustre.hexdocs.pm/lustre.html) supports the runtime choices.

### 6. `wisp` — useful contract guidance, but its governing rule is too narrow

**Use case and choice.** A composable inbound HTTP layer that translates requests into application calls and responses. Wisp supplies ordinary handlers/middleware; Mist owns transport mechanics; a plain application function owns the business decision.

**Distinctive value.** The consume-once body rule, preservation of middleware's returned request, upload lifetime, and CSRF cookie stripping are worth teaching. [Wisp's API](https://wisp.hexdocs.pm/wisp.html) supports those concrete distinctions.

**Minimal adjustment.** Keep [line 12](/code/gleam-dream/gleam-agent-tools/skills/wisp/SKILL.md:12), but make it a body-handling rule rather than the whole abstraction's governing idea. Lead with the benefit of ordinary composable request/response functions and small middleware. Merge 28/31 into a clear boundary sentence. Retain real-adapter verification for body streams/uploads. Do not add a separate router, mandate a storage abstraction for a trivial handler, or expand into authentication architecture.

### 7. `http-gun` — strong consumer guide; make the depth obvious

**Use case and choice.** Erlang outbound HTTP needing shared pooling, bounded collection, process-owned streaming, or deterministic playback. An existing simpler client is sufficient if those requirements are absent; HTTP Gun's absent redirects/decompression/proxy/upload-stream APIs are real selection constraints.

**Distinctive value.** [Lines 25–36](/code/gleam-dream/gleam-agent-tools/skills/http-gun/SKILL.md:25) teach one shared client with immutable per-call views and explicit ownership. Submission evidence and body-failure response heads avoid naive retries.

**Minimal adjustment.** Rewrite the opening to name the complexity hidden behind the client: connection reuse, body lifetime, and bounded reading through the same contract in live/playback modes. Retain scoped `with_response` as the default streaming path. Compress duplicated red flags; preserve the unusual default-redaction limitation. The source facade and ordinary `usage_views.gleam` substantiate the claims. Do not present it as a high-level REST SDK or automatically preferred over an adequate installed transport.

### 8. `gleam-sql` — good separation; add the SQL-first rationale

**Use case and choice.** PostgreSQL applications wanting authored SQL with checked generated access, an explicit runtime connection, and ordered schema changes. Pog alone suits a few hand-written queries; Squirrel becomes valuable when manual row-decoder/signature maintenance would drift; Cigogne independently manages migrations.

**Distinctive value.** [Lines 26–37](/code/gleam-dream/gleam-agent-tools/skills/gleam-sql/SKILL.md:26) accurately make schema-dependent generation, numeric representation, nullable parameters, transaction connection ownership, and post-write decode failure visible.

**Minimal adjustment.** Replace the abstract opening with the benefit of keeping SQL visible while deriving typed access from the intended schema. Add that database constraints remain the concurrent enforcement point for database invariants; this prevents the foundation's “domain logic” language being misapplied. Keep the three-package grouping and independent adoption. The [Squirrel](https://squirrel.hexdocs.pm/), [Pog](https://pog.hexdocs.pm/pog.html), and [Cigogne](https://cigogne.hexdocs.pm/) docs were checked. No fresh PostgreSQL execution was performed.

### 9. `gleam-pubsub` — justified caution; improve the positive example, not the confidence

**Use case and choice.** Ephemeral fan-out notifications where subscribers can recover authoritative state elsewhere. A direct callback/subject can be simpler for one known recipient; telemetry fits optional diagnostics; a durable protocol is required when missing a notification loses required work.

**Distinctive value.** This guide preserves unusually important incompatibility, process placement, stale-handle, and overflow facts ([lines 23–42](/code/gleam-dream/gleam-agent-tools/skills/gleam-pubsub/SKILL.md:23)). They are not generic clutter.

**Minimal adjustment.** Add one positive case, such as notifying views to refresh a changed entity, and require a re-read path after missed notifications. Keep the explicit Roar/Whisper blocker. Consider wording the local Whisper selection as provisional for the chosen target/version: retained execution used an out-of-range stdlib and low-level compilation, so it did not establish normal dependency resolution. Do not recommend an invented downgrade. [Roar's overview](https://hexdocs.pm/roar/) describes distribution but does not settle the inspected incompatible pair or prove cluster semantics.

### 10. `grind` — valuable recovery model; ordinary purpose is buried

**Use case and choice.** Admit work durably so execution can happen independently of the request, with delayed availability, bounded local queue concurrency and retained typed results. Use supervised in-memory work when loss is acceptable; use an existing durable queue if it already meets the contract; use a workflow abstraction for dependent partial-effect settlement.

**Distinctive value.** [Lines 33–40](/code/gleam-dream/gleam-agent-tools/skills/grind/SKILL.md:33) distinguish exact-command admission receipts, uniqueness, caller transactions, external idempotency, uncertainty, cancellation and retention. Retain them.

**Minimal adjustment.** Lead with request-independent execution and typed persisted outcomes; follow immediately with the operational tradeoff that abandoned uncertain effects require resolution. This differentiates Grind from automatic rescue models and helps users judge whether they can operate it. Compress version/setup reminders and duplicated red flags. Preserve local queue limits and unbuilt cron/batch/workflow exclusions. The source/design do not justify claims of complete Oban capability or fresh release qualification.

### 11. `saga` — most important selection-rule correction

**Use case and choice.** Coordinating dependent effects whose partial completion matters: dependency scheduling, parallel branches, undo of known success, failed-attempt compensation, and optional checkpoint recovery. Plain `Result` composition remains enough for simple sequencing; a database transaction is preferable when it encompasses all relevant effects.

**Distinctive value.** The source's pure reusable graph and typed ports eliminate runtime result-name lookup. `undo` and `compensate` express different decisions. Embedding a workflow can reuse its typed contract.

**Minimal adjustment.** Replace [line 15](/code/gleam-dream/gleam-agent-tools/skills/saga/SKILL.md:15); “typed dependencies” alone does not justify Saga. Promote typed wiring/reusable definitions and one reserve-charge-release example. Mention workflow composition (`embed`/`map_errors`) only if it earns room by explaining reuse. Keep durable scheduling/wakeup limits and unknown-effect evidence. Source oracle diffs explicitly show reverse undo order and settlement of still-running siblings; do not imply Reactor parity or confuse compensation with database rollback.

### 12. `sinal` — accurate mechanics, missing its central architectural value

**Use case and choice.** A library/application emits observations without choosing who consumes them; applications attach optional metrics, logging or diagnostic consumers. A direct callback fits a required reaction; a log can suffice for one diagnostic; pub/sub fits ephemeral application notifications; a durable protocol fits required delivery.

**Distinctive value.** Typed definitions preserve native BEAM telemetry interoperability without turning fields into JSON or coupling producers to exporter dependencies. Applications can change consumers without rewriting emitters.

**Minimal adjustment.** Replace [line 8](/code/gleam-dream/gleam-agent-tools/skills/sinal/SKILL.md:8), explain producer/consumer independence before handler API choices, and move forwarding after that default story. Compress the lower-priority enum-list tip at 27 if necessary. Keep permanent atoms, callback placement/failure, spans, and routing boundaries. Define “scalable” only as independently extensible instrumentation and optional bounded offloading: synchronous default handlers add emitter latency, a forwarder can stall, overload drops, and shutdown loses queued work. No durability, total memory bound, or universal backpressure follows. Source: `src/sinal.gleam`, `src/sinal/forwarder.gleam`, and [native telemetry 1.4.2](https://telemetry.hexdocs.pm/1.4.2/telemetry.html).

### 13. `json-blueprint` — strong technical detail, wrong entry point

**Use case and choice.** One native type needs encoding, strict decoding, and a published schema that stay aligned. A standard Gleam JSON decoder is simpler for a one-way known input. Legacy recursive/wire compatibility and modern finite runtime contracts are separate choices.

**Distinctive value.** A codec is a shared definition across representations, not merely a stricter parser. Omission/null/value and exact/native numeric differences are central, concrete benefits and tradeoffs.

**Minimal adjustment.** Replace [line 8](/code/gleam-dream/gleam-agent-tools/skills/json-blueprint/SKILL.md:8) with that purpose, then keep the release warning immediately afterward. Recast the tree as capability first, source/version second. Combine duplicated callback-purity bullets 27/31/32. Preserve placeholder evaluation, strict closed records, bridge losses, finite-profile exclusions and frozen envelopes. Do not imply arbitrary JSON Schema support or universal equivalence of callback validation and emitted schema. `src/json/blueprint/codec.gleam` provides a much better opening model already.

### 14. `warden` — dense for good reason; do not weaken recovery guidance

**Use case and choice.** OIDC login, service-token acquisition, or resource-token validation with role-specific configuration and checked evidence. It is useful when the application needs these protocol roles and managed user-token custody; an adequate established integration remains a valid choice. Application accounts, sessions and permissions remain separate.

**Distinctive value.** Discovery, key rotation and synchronized refresh are hidden complexity; opaque checked identities and publication recovery prevent accidental code/token reuse. The [lines 34–35](/code/gleam-dream/gleam-agent-tools/skills/warden/SKILL.md:34) recovery rule is exceptionally important.

**Minimal adjustment.** Make the opening concrete: sign in users and manage their provider tokens, without supplying the application's account/session model. Put custom-store atomicity behind “if implementing a store”; ordinary consumers need not study lock-wait mechanics before choosing the default adapter. Preserve pre-production status and independent security-review requirement because these are explicit package conditions, not invented caution. Avoid assuming local JWT validation proves provider revocation state. Do not expand into a general authentication framework comparison.

### 15. `correio` — strong and unusually composable; slight reordering only

**Use case and choice.** Provider-independent transactional email or passwordless challenges over the application's own subject type; either capability stands alone. A provider's existing adequate mail integration can remain; use a different identity mechanism when the application does not want email-based proof.

**Distinctive value.** `delivery.Sender` lets production SMTP/Postmark and test capture use the same application contract. Issuance, delivery, consumption and session publication retain independent authority. Four delivery outcomes carry more meaning than success/failure.

**Minimal adjustment.** Add the benefit of that replaceable sender to [line 8](/code/gleam-dream/gleam-agent-tools/skills/correio/SKILL.md:8), then keep the independence rule. At 642 words, compress table rows or duplicate red flags to make room. Retain scanner-safe intentional verification, unknown-command recovery, confirmed evidence for session retries, and no automatic retry of possibly sent mail. This is not an opportunity to delete warnings wholesale. The delivery consumer is an excellent demonstration of actual composition.

### 16. `llm-wire` — already clear scope; sharpen the abstraction's payoff

**Use case and choice.** Typed provider interactions when the application controls history, tool execution and retry policy. Use Fabric when retained tool/graph execution is the actual problem; retain an adequate provider library; a narrow provider-specific client can be simpler when common outcomes and streaming are unnecessary.

**Distinctive value.** Preparation validates/encodes before I/O; common outcomes preserve provider refusal, truncation and tool requests; opaque turn data supports faithful continuation. The shared transport does not absorb conversation policy.

**Minimal adjustment.** Improve [line 8](/code/gleam-dream/gleam-agent-tools/skills/llm-wire/SKILL.md:8) by stating this benefit before listing providers. Keep the record-root/schema-profile constraint, turn replay, one reader, and retry evidence. “Native question answering → classification” at line 17 is obscure to a new reader; name the actual typed classification use case instead. Do not promise provider interchangeability beyond supported contracts, provider-native tool execution, or ReqLLM feature parity.

### 17. `fabric` — good separation; explain why a retained runtime earns its cost

**Use case and choice.** Model-chosen tools or application-controlled conditional graphs requiring policy, approval, bounded execution and recoverable records. A single provider call or small application-controlled loop can stay with Wire/plain functions; queue scheduling and compensation have different owners.

**Distinctive value.** Typed tools are bound before heterogeneous collection; agent and graph controllers share recovery machinery without erasing different control models; uncertain effects suspend dependent progress; approval belongs to an exact current action.

**Minimal adjustment.** Add a concrete reason to pay for the store/context/definition machinery: a tool call may pause for approval or lose its runner while the application still needs its outcome. Keep [lines 35–46](/code/gleam-dream/gleam-agent-tools/skills/fabric/SKILL.md:35). Remove one generic manifest/verification reminder if needed. State that bounds are the named implemented turn/concurrency/call/tool limits, not a whole-agent elapsed deadline. Source pending scope and the current red flag correctly make that distinction. No general LangGraph parity or automatic compensation claim.

### 18. `relay` — strong tool story, narrower than its real public scope

**Use case and choice.** Native application capabilities must be exposed to or consumed from MCP peers. Internal operations remain plain typed functions; an existing suitable MCP SDK remains appropriate. Stdio and Streamable HTTP solve different deployment/lifetime needs.

**Distinctive value.** One definition serves declaration, server binding and typed client calling. Buffered versus streaming mounts retain different progress/disconnect contracts; transport success differs from tool success; retry evidence differs from idempotency enforcement.

**Minimal adjustment.** Bring the shared-definition benefit into [line 8](/code/gleam-dream/gleam-agent-tools/skills/relay/SKILL.md:8). Add one concise scope sentence naming resources/prompts/completion when supported: the design and public client (`list_resources`, `list_prompts`, `read_resource`, `complete`) are broader than tool calling, although the compact guide may justifiably emphasize tools. Keep revision qualification, unsupported schemas and untrusted annotations. Do not convert this into an exhaustive protocol guide or claim client/auth interoperability from server conformance tests.

### 19. `retrace` — priority reorientation, not removal of important server facts

**Use case and choice.** Inspect or reproduce what happened in a frontend application by replaying safe model checkpoints and accepted messages through a deterministic reducer and view. Logs/metrics answer narrower operational questions; browser video/DOM recording is a different requirement; authoritative business-event storage is a different ownership model.

**Distinctive value.** Lustre's model/message structure enables typed reconstruction without recording arbitrary pixels or running live effects again. Portable core, frontend capture/delivery/viewer, and optional server archival can be selected independently.

**Minimal adjustment.** Replace [lines 8–17](/code/gleam-dream/gleam-agent-tools/skills/retrace/SKILL.md:8) with that model and a positive support/debugging case. Put safe projection, previous-model capture, accepted events, external observations as messages, inert replay and matching historical artifact together before delivery/archive. Keep server erasure as a conditional late rule; do not delete its quiescence requirement. Link the public capture/replay/basic-consumer source first and erasure later. The local core/frontend source is at `13ef6f9`; the remotely inspected server contract is `31352e53`. Neither source nor owner preference implies universal screen capture, complete frontend reconstruction without sufficient observations, or automatic privacy.

## Actual oracle and inspiration map

The following are established relationships, not interchangeable claims of inspiration, implementation reuse, or parity. Paths are primary local provenance; the upstream links identify the named comparison source. This review read the records and selected source/fixtures, not every upstream suite.

| Package | Actual reference and provenance | What transfers; what does not |
| --- | --- | --- |
| Grind | [Oban OSS 2.24.1](https://github.com/oban-bg/oban/tree/64b8481e5383f6bc46b7a5284e4ced3202dec9d5); [ORACLE](/code/gleam-dream/grind/docs/ORACLE.md:10), `oracle/README.md`, scenario/ledger files | Durable database jobs, scheduling/retry/uniqueness/pruning comparison cases. Grind retains typed outcomes, admission receipts, live-lease fencing and attributed uncertainty resolution. Oban rescue behavior is deliberately different. No Oban Pro parity, cluster quota or cron support inferred. |
| Saga | [Reactor 1.0.6](https://github.com/ash-project/reactor/tree/e4ddc9e438f08562e9fb31b08255a86f4bade8ef); [ORACLE](/code/gleam-dream/saga/docs/ORACLE.md:13), `oracle/differences/d2.diff`, `d3.diff` | Dependent-step scheduling, concurrency, retry and rollback vocabulary. Saga uses typed ports; retained diffs reverse undo order and settle completed siblings. Durability, uncertainty and storage are Saga contracts; Reactor's dynamic expansion/DSL is not inherited. |
| Sinal | [Native telemetry 1.4.2](https://telemetry.hexdocs.pm/1.4.2/telemetry.html), commit `7baf8085e406d5ae9e43b284d7c866742ae04b28`; [ORACLE](/code/gleam-dream/sinal/docs/ORACLE.md:35) | Native registry, atom-list names, maps, synchronous callbacks and spans are real runtime interoperability. Typed codecs, malformed-map retention and bounded forwarding are Sinal additions/adaptations. Historical 42-case native run is retained provenance, not a new load/scalability test. |
| HTTP Gun | [Dream client](https://github.com/lostbean/dream/tree/bbc4b5402a7e0cb5247829c8f4be8fb273afc2a5), Gun/Cowlib audited archives, `nghttpd`; [ORACLE](/code/gleam-dream/http_gun/docs/ORACLE.md:8) | Byte/status/header/trailer, ownership and recording comparison cases. Persistent-session, cancellation and cassette formats intentionally differ. Gun/Cowlib are runtime wire dependencies, not merely inspirations. No whole-stack memory or full HTTP conformance claim follows. |
| JSON Blueprint | Python `jsonschema` 4.26.0 / Draft 2020-12, frozen local manifest, legacy source `0e379c6`, Oversight probes `bd0b837`; [ORACLE](/code/gleam-dream/json_blueprint/docs/ORACLE.md:9) | Independent finite-schema acceptance checks; exact-number/native-projection distinctions and legacy compatibility are separately tested. No evidence here establishes a Zod/Pydantic donor or arbitrary-schema parity. The manifest version does not identify the modern API. |
| Warden | [oidcc 3.9.0](https://github.com/erlef/oidcc/tree/aa212d52d0140addf057c34917b734647401b34e), OIDF RP suite `release-v5.3.1`, Keycloak 26.7.5, node-oidc-provider 9.12.2, Dex 2.45.1, Hydra 26.2.0, erlang-jose/vectors; [ORACLE](/code/gleam-dream/warden/docs/ORACLE.md:17) | Selected protocol/claim/refresh and provider interoperability comparisons. Warden is native Gleam on gose/kryptos/HTTP Gun, not an oidcc wrapper. Stricter audience, ID-token and refresh decisions are documented. Suite skips/reviews and incomplete initiation remain non-pass; no certification. |
| Correio | [Swoosh 1.28.1](https://github.com/swoosh/swoosh/tree/13f10492615cbb9c29cc974f14e18e1c26a551b5), Phoenix 1.8.15 `bd180183`, AshAuthentication 4.15.0 `d6b2be35`; [ORACLE](/code/gleam-dream/correio/docs/ORACLE.md:5), `oracles/README.md` | Message/MIME-envelope semantics, sequential challenge behavior, concurrent single-use redemption. They are separate references for separate responsibilities. Account confirmation, registration, session publication and linking do not transfer; SMTP fault behavior needs separate evidence. |
| LLM Wire | [ReqLLM 1.24.0](https://github.com/agentjido/req_llm/tree/fd9e079fddf253e9b719b2d2c6920f4306592809), Jido AI architecture context, `anthropic_gleam` 0.1.1 reuse experiment, provider protocol docs, Dream `98a7103` and ReqCassette `cb0251c`; [ORACLE](/code/gleam-dream/llm_wire/docs/ORACLE.md:5) | Selected text/tool/terminal/SSE/continuation laws. Jido's different ReqLLM pin is context only. Wire owns no automatic retry/tool execution/model discovery parity. The reuse experiment did not adopt anthropic_gleam's stream state. HTTP Gun now owns cassette mechanics. |
| Fabric | BeamWeaver fork `lostbean/beam_weaver` at `d0aa1f90d31c55d49be2f7b5a24224b5e18145a1`, upstream `caudena/beam_weaver` 0.1.23 plus four durability commits; [ORACLE](/code/gleam-dream/fabric/docs/ORACLE.md:14), retained capture fixtures | Selected agent-loop, approval, child-start and restart observations. Fork manifest 0.1.23 is not Hex 0.1.23. Fabric rejects duplicate/stale approval and interrupted-effect hazards; its concurrency/uncertainty contracts are often original. No general graph or timeout equivalence. Exact remote fork fetch returned 404 in this review, so independent upstream reinspection is incomplete. |
| Relay | Frozen MCP 2026-07-28 schema `5f5440bb`, conformance 0.2.0-alpha.10, scoped TypeScript/Python 2.0.0 peers, older `mcp_toolkit` 0.3.1 / `mcp_client` 0.1.0 feature references; [ORACLE](/code/gleam-dream/relay/docs/ORACLE.md:13) | Structural schema evidence and selected emitted server assertions. Older packages inspire typed builders/child ownership, not modern conformance. Direct pinned SDK interop is not executed by the gate; client/auth/legacy behavior is separate. |
| Retrace | Explicitly no external oracle: [AGENTS references](/code/gleam-dream/retrace/AGENTS.md:42), core, frontend consumer and design | Model/checkpoint/message reconstruction is demonstrated by its own contracts/consumers. MVU is the applicable architectural fit; no invented recorder-product inspiration or oracle parity. |

For the other eight guides, the primary authorities are language/ecosystem public contracts rather than an invented local oracle: official Gleam conventions/externals; `gleam_otp`/`gleam_erlang`; Lustre's MVU/effects/runtime APIs; Wisp/Mist; Squirrel/Pog/Cigogne; Whisper/Roar source. The Elixir Agent Tools checkout at `ac3a5a1` is an **editorial reference** for direct rules and selection structure. It is not a behavioral source for Gleam. Its “call gives backpressure” and broad Oban “let it crash” slogans should not be transplanted.

## Proposed short replacements — proposals only

These are candidate text, not applied edits or a required common outline.

**Retrace opening:**

> Reconstruct a frontend session from safe model checkpoints and the accepted messages that changed them. In Lustre, this lets a developer inspect how a user reached a state by replaying the same transitions through an inert view. Choose Retrace when that application history is the evidence you need; logs or metrics suffice for narrower diagnostics, while arbitrary screen or DOM recording needs a different approach.

**Retrace decision rules:**

> Start with the portable recorder/reducer contract. Add frontend capture and delivery for a browser or Tauri application, and server archival only when you need it. Project the model and messages before capture; record external results as messages; replay with the matching historical reducer/view without live effects. Capture an accepted transition using its previous model.

Retain later: `record` is not persistence, cursor/outbox consistency, artifact identity limits, and erasure's no-future-publish proof when operating the server.

**Sinal opening:**

> Emit typed observations without coupling producers to their consumers. A library defines what happened; the application can attach metrics, logging, or other observers, or attach none. Choose Sinal for optional diagnostics that remain compatible with native BEAM telemetry. Use a direct application protocol when another component must act successfully.

**Sinal execution rule:**

> Unrouted handlers run synchronously in the emitter, so their work becomes producer latency. Route selected prefixes to a supervised bounded forwarder only when isolation is worth possible loss: full or unavailable forwarders drop events, and shutdown does not drain. This changes callback placement, not the event's authority or durability.

**Saga decision rule:**

> Use ordinary `Result` composition for short sequencing and a database transaction for changes one transaction can cover. Choose Saga when dependent effects need coordinated scheduling, parallel branches, undo, compensation, or retained partial progress. Its typed ports connect step outputs to inputs without a result-name dictionary; define the graph once and supply each run's input separately.

**Blueprint opening:**

> Define a JSON boundary once when its encoder, decoder, and schema must stay aligned. Use ordinary Gleam JSON decoding for a one-way input that needs no schema. Check the installed source before using the codec API: published 1.7.1 and the unreleased codec checkout expose different contracts despite the checkout's version field.

**Grind opening:**

> Admit work durably so it can run after the request ends and its typed outcome can be inspected later. Choose Grind when Erlang/OTP and PostgreSQL fit that lifecycle. Its recovery model preserves uncertainty: an abandoned effect may require investigation and an explicit resolution instead of automatic replay.

**HTTP Gun opening:**

> Reuse one HTTP client for pooled byte requests, bounded response collection, owned streams, and offline playback. Choose it when those transport responsibilities matter; keep an existing suitable client otherwise. Per-call views adjust policy over the shared pool, while the application keeps status interpretation and retry decisions.

## Evidence coverage and limits

**Completed inspection.** Read all 19 full skill files with line anchors and measured their sizes. Read the collection README and relevant source-identity/research records as leads. Read the review-design, design-taste, orchestrate and write-a-skill entry guidance; applied one integrated abstraction-fit/editorial lens, without imposing a design render/gate. Read repository AGENTS responsibilities and relevant root design foundations/pending scope. Inspected README openings, actual public facade/module contracts, and selected external consumers for all 11 local packages. Inspected each available ORACLE document's pins/scope/differences, selected oracle harness material, Saga expected diffs, and Fabric's retained model-limit fixture. Inspected the house library-API guidance and the Elixir OTP/Oban style examples.

**Package source identities observed locally:** Correio `a449864`, Fabric `815fc59`, Grind `bcd4b92`, HTTP Gun `db1cc97`, Blueprint `45b3616`, Wire `aa74ce6`, Relay `8d588eb`, Retrace `13ef6f9`, Saga `c09b7a7`, Sinal `58c6e7d`, Warden `33e9056`. These identify sibling source, not every consumer's resolved dependency. The collection research explicitly identifies Fabric/Wire consumer pins and a stale Fabric README claim; this review did not relabel all sibling paths as a compatible tested assembly.

**Independent remote reads.** Opened current primary Gleam conventions/externals, Lustre, Wisp, Squirrel, Pog, Cigogne, native telemetry and Roar docs; fetched Reactor's exact pinned README and Retrace's `31352e53` server README through GitHub. The latter confirms typed erasure states, prior admission, the two-part in-flight quiescence proof and no old-layout upgrade. The exact BeamWeaver fork fetch failed with 404; local ledger and captured fixture provenance remain the evidence for that relationship. Other oracle claims above are primarily from inspected local pinned provenance and selected fixtures, not a complete independent upstream-source audit.

**Retained probes inspected, not rerun.** `/code/gleam-dream/gleam-agent-tools-research/probes` contains dishonest FFI/Promise/fallback/number tests and Lustre simulation/static rendering/OTP system probes. Its retained record reports seven tests per target under Gleam 1.19.2, OTP 28 and Node 25.8.1; it explicitly is not an automatically captured clean-cache transcript. I read the relevant test/source assertions. `/code/gleam-dream/gleam-agent-tools-research/second-pass/probes/pubsub` retains source, raw results and hashes for Roar incompatibility, Whisper drop-oldest/cancel/reopen behavior and target-specific callback lifetimes. I read the shared public probe, JavaScript lifetime probe and selected raw logs, with the broader experiment report. It used stdlib 1.0.5 outside Whisper's `<1.0.0` declared range and bypassed normal dependency resolution. It proves neither a normally resolved Whisper installation nor any working Roar pair or multi-node behavior.

**Missing fresh evidence.** No compiler/runtime, real browser/Tauri, database, server transport, provider, conformance, load, security, power-loss, cluster, or agent-effectiveness execution was performed in this review. Source comments and checked-in passing assertions are not fresh runtime evidence. Several packages retain explicit unbuilt or unqualified scope; the guides should continue to distinguish those limits. No new gate failure is fabricated from the absence of execution: this assignment is an architectural/editorial review, not release acceptance.

## Recommended revision order and acceptance criteria

1. **Reorient Retrace and Sinal.** A reader should explain the model/message replay mechanism and optional producer/consumer relationship after the first paragraph. Keep conditional server erasure and forwarding limits.
2. **Repair the selection threshold in Saga and the purpose of Blueprint/Grind.** Each should identify a case where a plain function, standard decoder, database transaction or in-memory task is enough. Keep the nontrivial recovery contracts.
3. **Sharpen benefit statements in HTTP Gun, Correio, Warden, Wire, Fabric and Relay.** Reuse demonstrated consumer mechanisms; do not add abstractions merely to sound architectural.
4. **Lightly trim foundations, OTP, Lustre, Wisp, SQL and pub/sub.** Preserve the strong material. Add only the missing concrete payoff or alternative; retain evidence-qualified incompatibility warnings.
5. **Review the whole collection for semantic duplication and new overclaims.** Maintain single-file independence and all 19 concerns. Do not add a composition guide, router, OpenAPI scope, or compulsory supporting loads.

Acceptance should be observable but modest:

- Every guide answers “what problem,” “why this abstraction,” and “when simpler/different” without relying on another skill or on its package name.
- Every new benefit has a primary contract/consumer basis; taste is stated as a choice rule, not a fictitious guarantee.
- A small concrete scenario replaces at least one vague abstraction phrase where judgment is otherwise hard to apply.
- Removed rules are accounted for as redundant, compressed, or deliberately lower priority; no meaningful outcome, ownership, recovery or source-identity distinction disappears accidentally.
- No proposal implies arbitrary-schema support, universal portability, full-system backpressure, durable telemetry/pubsub, automatic privacy, upstream feature parity, or release qualification.
- The guide can be read as an independent consumer aid. Package guides do not direct internal library refactoring.
- Mechanical metadata/link/word/line checks still pass. This is necessary structure, not proof of usefulness.
- A later small agent evaluation should compare actual choices on contrasting tasks: simple sequential operation versus compensating workflow; one diagnostic versus independently attachable observers; one-way JSON input versus shared codec/schema; frontend reproduction versus logs; ephemeral task versus durable admission. Record over-selection and incorrect guarantees, not merely whether the agent mentioned the intended package. This evaluation is recommended and currently unevaluated.

The collection should emerge more decisive, not more absolute: a smaller number of concrete reasons to choose an abstraction, followed by the exact distinctions that let a consumer use it safely.
