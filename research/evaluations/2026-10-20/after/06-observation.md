# INITIAL

Selected guides (read completely):
- `/code/gleam-dream/gleam-agent-tools/skills/gleam-lib/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/sinal/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/gleam-pubsub/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/grind/SKILL.md`

Two decisive guide lines:
> A library describes what happened; the application attaches metrics, logging, an exporter, or nothing.
> Roar 0.1.0 uses Whisper's older router API and is source-incompatible with the inspected Whisper 0.2.0 API, despite its permissive dependency range.

## Boundaries and ordinary consumption

Separate three contracts: optional diagnostic observations, ephemeral application refresh notifications, and required payment execution. Reject a shared bus that makes all three look equally reliable. Cluster fanout is an additional transport decision, not evidence of durable delivery.

For the reusable BEAM library, select typed Sinal-style observations and native telemetry interoperability, subject to source/install qualification. Define stable events with separate native measurement and metadata types: for example `OperationMeasurements(duration, item_count)` and `OperationMetadata(operation_kind, correlation_id, outcome)`. Keep public operations returning the existing `Result(Value, DomainError)`; consumers should not receive JSON or a generic event dispatcher in place of their domain API. A service attaches metrics, logs, both independently, or nothing. Observation success never decides whether a domain operation committed. Keep field encoders total: the guide says producer-side encoding still happens without observers, so absence of observers alone cannot guarantee an ill-written encoder is harmless.

Clearly labeled pseudocode, not runnable API claims:

1. Service startup defines/reuses the library's event definition, starts a supervised bounded exporter forwarder, installs fixed routing, and attaches chosen handlers; retain attachment handles.
2. Request calls `library.update(config, EntityId, Update) -> Result(Entity, UpdateError)`. Library performs its operation and emits typed diagnostics. The same call works when startup installs zero handlers.
3. After successful authoritative state commit, application publishes `EntityChanged(EntityId, Revision)` to the local refresh topic. Each panel rereads the entity; initial mount, reconnect, and an explicit refresh also reread.
4. A required `PayInvoice(PaymentId, InvoiceId, Amount, Currency)` goes through an explicit payment service protocol or a durable queue/outbox. Commit payment intent with related business changes, then execute with provider-enforced idempotency and retain outcome.
5. Service shutdown stops publishers, detaches its handlers, and closes owned runtime resources. Panel teardown invokes its retained subscription cancellation closure.

For one known callback destination, use an ordinary typed callback or subject: e.g. a local update completion callback refreshing its single parent. A single known required payment recipient can also use a direct request/result protocol, with a durable authoritative record and recovery if the requirement includes surviving failure. Do not introduce pub/sub solely to rename a function call.

Whisper is a candidate for the two panels' ephemeral local refresh fanout. Browser-local topics do not transport changes between separate browser processes or machines; if panels live in different sessions, the server needs an explicit delivery transport and each client needs its own local subscription. The scenario does not specify that topology. Keep one application-owned payload contract per stable topic name; typed handles are not global schema validation or authorization. Avoid creating a topic for every arbitrary user value.

Roar is only a conditional cluster-notification candidate. Do not install the offered Roar 0.1.0 plus Whisper 0.2.0 pair under the current evidence, and do not propose an unverified downgrade. Required payments stay outside it. Grind is an optional candidate only if PostgreSQL, retained outcomes, and its operational recovery fit; preserve an existing suitable durable queue. No requirement establishes PostgreSQL here, so selecting that dependency now would be premature.

## Ownership, limits, and recovery

The embedding service owns handler registration IDs, startup attachments, routing policy, supervised forwarder, and detachment. Library calls must not register handlers repeatedly or start a global exporter implicitly. Use trusted static names and field keys because native atom creation is permanent. Capture correlation in metadata; asynchronous forwarding loses producer process context. Keep synchronous handlers short: exporter network I/O must not block emitters. Configure bounded queued-plus-executing work, drop/count observations when full or unavailable, and expose diagnostic health separately. No inline fallback or payment retry through telemetry; shutdown need not drain according to the guide.

The application owns topic creation/closing; each panel owns cancellation. On BEAM, investigate linked registry/topic startup before claiming independent supervision. Keep callbacks short: the guide places JS callbacks within publish and BEAM callbacks inside the topic process. Use bounded buffers for acceptable bursts; overflow drops old notifications. This bounds the subscription buffer, not mailboxes or total memory, and is not publisher backpressure. Distinguish Empty from Closed; closure requires reattachment/recovery. Avoid topic-name reuse while stale handles survive.

Payment failure recovery needs durable intent, stable command identity, retained status and provider evidence. Retry known-safe transient failures with limits; after an ambiguous network outcome, reconcile by the same idempotency key instead of blindly issuing another charge. Admission acknowledgment is not proof of payment success; staged transactional admission is not proof of commit.

Before promising installation: inspect exact resolved dependency graph, compiler/OTP and target constraints, package availability, public APIs and supported versions, then normally resolve/compile an external consumer in a real project. This synthetic exercise runs no builds. Before distribution claims: qualify a compatible Roar/Whisper pair, scopes restricted to bounded trusted atom names, node membership, duplicates, disconnect/reconnect recovery, cancellation and bridge cleanup. Scope membership is not authorization; publish return proves no durable receipt or exactly-once delivery. Missing requirements include panel topology, loss/latency budgets, cluster trust, payment authority and durable infrastructure. Next verification checks guide claims against public pinned sources and preserves this initial assessment.

# VERIFIED

Primary-source checks after saving INITIAL:

- [Native telemetry 1.4.2](https://telemetry.hexdocs.pm/1.4.2/telemetry.html), `attach/4`, `attach_many/4`, `detach/1`, and `execute/3`: confirms synchronous execution in the dispatching process, unspecified handler ordering, unique registration IDs, removal upon handler failure, and explicit detachment. Amendment: handle duplicate-ID startup errors as configuration failures; alert on handler removal and correct the cause before reattaching. One failed multi-event handler loses all its registrations. A domain call should not treat those diagnostic failures as a business rejection.
- [Roar v0.1.0 overview](https://hexdocs.pm/roar/), “Quick Start,” “How It Works,” and “Scope isolation”: confirms the published examples use routers, explicit cancellation, Whisper for local delivery, `pg` for remote fanout, and buffers dropping old messages. Its broad memory and duplicate-delivery claims are documentation assertions, not established cluster behavior. No payment or exactly-once guarantee follows from them.
- Attempts to retrieve the pinned Roar manifest/source, Whisper 0.2 source/docs, and Sinal forwarder source failed through the public fetch tool; a direct public-source fetch also failed DNS resolution. Consequently, API incompatibility, Sinal's unreleased status and detailed drop/shutdown behavior, and Whisper's precise runtime cleanup hazards remain guide-derived cautions, not independently verified findings here. Installation remains unqualified. This does not justify substituting a version or declaring compatibility; obtain the pinned manifests/source and a normally resolved external consumer before approval in an actual project.

Design clarification: compose independent service values such as `MetricsConfig`, `LoggingConfig`, `ExportPolicy(capacity, export_deadline)`, and `RefreshPolicy(buffer_capacity)` through ordinary typed functions; no single mandatory bus object should own them. The host service may add or omit each observer without changing domain-operation arguments. An exporter adapter must enforce its network deadline, since a bounded queue cannot stop one executing handler from blocking forever. Handler forwarder startup must precede routing/attachment; teardown must prevent new emissions from targeting resources already closed. For an entirely Erlang-authored library, native telemetry alone may be the simplest producer boundary; Sinal is useful where its typed Gleam definitions fit the implementation. The scenario does not establish that implementation language.

Output: `/private/tmp/gleam-skills-rerun-20261020/06-observation.md`

Summary: optional telemetry, recoverable panel invalidation, and durable payments have separate owners and contracts. Roar/Whisper installation and distribution remain conditional on source and resolved-consumer qualification.
