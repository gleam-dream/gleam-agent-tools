# INITIAL

Use Fabric's retained agent for model-selected research tools and approvals; use Saga behind the publishing tool for the dependent object/index effects. Keep the existing durable queue for admission, wakeups, and redelivery. A queue handler starts or reconnects a retained run and returns; it must not own an approval wait or all recovery through a provider loop. LLM Wire supplies the provider adapter under Fabric, rather than a second application-managed transcript loop. A Fabric graph is unnecessary unless the application, rather than the model, must prescribe research routes. Do not add Grind merely because the work is asynchronous. Plain Result sequencing or one SQL transaction would be preferable if publication could be made atomic, but the stated external partial success warrants coordinated compensation.

Selected guides (complete files read):

- `/code/gleam-dream/gleam-agent-tools/skills/fabric/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/saga/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/llm-wire/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/grind/SKILL.md` (boundary check; package rejected)
- `/code/gleam-dream/gleam-agent-tools/skills/json-blueprint/SKILL.md`

Two influential exact lines:

> Bind approval to the exact action and current policy. Reconstruct fresh context and use the configured verifier; changed arguments need fresh approval.

> Own wakeups, unfinished-run discovery, and redelivery. Durable storage does not start a permanent scheduler; a drive timeout stops that driver without cancelling saved execution.

Define native `ResearchRequest`, `Finding`, `ReportDraft`, `Publication`, and explicit publication error/outcome variants. For example, `Publication` contains the object identity/version and index receipt; failures distinguish definite rejection, cleanup failure, and unresolved effect. Version codecs at durable boundaries. Use Blueprint codecs for tool input/output and retained workflow data after verifying the resolved modern API; avoid string-keyed result dictionaries. Schema validity does not establish authorization or provider compatibility.

Bind each typed handler to its tool definition before combining heterogeneous tools: search receives `SearchInput` and produces findings; publish receives a validated draft and produces a publication receipt. Handler context holds current tenant/principal permissions and borrowed service clients, with fresh credentials and authorization on reconstruction. Shared tool/agent/workflow definitions contain reusable behavior, not a captured request's identity or credentials. Supply request data as run input and context. Compose provider generation settings, bounded agent policy, storage adapter, and service clients explicitly. Configure turn/concurrency/model-call/tool-body bounds plus a separate application deadline; per-call bounds are insufficient.

Ordinary consumer call path (conceptual pseudocode, signatures unverified):

1. HTTP validates the request and authorizes research admission. Persist its business record, stable run identity, and queue submission atomically when the existing queue supports it; otherwise use a transactional outbox. Return an accepted response with a status reference after durable admission.
2. Worker obtains the stable run identity, reconstructs live context, and starts/reconnects Fabric. Recovery belongs to a supervised application service. Waiting for approval releases the queue handler; later approval or unfinished-run discovery schedules further driving.
3. Fabric calls bound research handlers, records their outcomes, and requests approval for the exact proposed publishing action. Approval is checked against current policy and arguments even after runner loss; changes invalidate it.
4. Publishing starts/reconnects a durable Saga using a stable identity derived from run/action, identical encoded input, versioned step codecs, and recovery resolvers. Typed ports connect object creation to index update. Known index failure can undo a known-created object, subject to ownership/version checks; retain cleanup failures for repair. An unknown index outcome suspends instead of deleting a potentially public object.
5. A result consumer reads Fabric status and action records. A model's final answer alone is insufficient. It commits the validated publication/result and an applied marker in one business transaction, keyed uniquely by run identity; duplicate delivery observes the marker. Preserve unapplied terminal runs during pruning.

Own and supervise durable Fabric storage/recovery, Saga storage, the existing queue, and whichever HTTP/database pools their adapters actually require. Borrow clients in handlers; avoid transaction-scoped connections retained across waits. Migrate before consumers start. During shutdown, stop new driving and release owned handles/resources according to runtime contracts; request loss or wait timeout does not cancel saved execution. Explicit cancellation still cannot retract an external write.

Timeout is not evidence that an effect failed. Definite tool failures can be explained to the model; uncertain mutations block dependent work pending authoritative evidence. Reconcile by stable effect keys and provider-enforced idempotency, receipts, or authoritative lookups. Do not replay a mutation to discover its result or infer absence from an eventually consistent lookup. Replay only reads or writes with a demonstrated idempotency contract. Queue redelivery repairs scheduling; Fabric and Saga recover their respective execution records. Queue deduplication is not external-effect deduplication.

Before implementation verify exact adapter/signature/storage support, compatible revisions, approval resumption and verification semantics, nested durable workflow recovery, terminal result inspection, and retention behavior. Missing requirements: queue transaction capabilities, object/index idempotency and lookup guarantees, overwrite/delete ownership rules, acceptable deadline/cancellation policy, and production storage failure model. These determine resolvers and compensation safety; do not guess them.

# VERIFIED

Inspected local public source at the guides' pinned commits: Fabric `815fc5971e0ae8e7783f122e1ee00a7e50c08de7`, Saga `c09b7a7c72148fcaf73fea96cb595ccf16a56e7b`. No builds, credentials, or live calls were used.

- Clarify start/reconnect: Fabric has `start` returning `AlreadyStarted`, `open` for inspection/commands, and `recover` for takeover; it is not Saga's `start_or_reconnect` API. Compare exact admission input before accepting an existing run. A pending approval needs no live runner. For multi-node recovery use a leased database store; recovering through an unleased store while another owner lives can interrupt it. Sources: `/code/gleam-dream/fabric/src/fabric.gleam:36`, `:129`, `:395`, `:450`.
- Approval is stricter than simply retaining the original action: `approve` takes a requirement-bound proof and fresh context; approved work uses that checked context. An approved action not yet started asks again after runner loss. Sources: `/code/gleam-dream/fabric/src/fabric.gleam:896`, `:923`; `/code/gleam-dream/fabric/src/fabric/store.gleam:279`.
- Fabric supplies `sweeper.supervised` for leased-store recovery, taking registered roots and context factories, replacing standalone `store.supervised`. Keep this recovery owner distinct from queue admission. Its subtree stops the sweeper before draining runners; keep backend/pools alive through draining. Sources: `/code/gleam-dream/fabric/src/fabric/sweeper.gleam:1`, `:132`; `/code/gleam-dream/fabric/src/fabric/store.gleam:260`.
- The bundled Saga tool recipe uses owner-bound `reporting.run_owned` and `tool.bind_settling`, classifying complete reports into definite/uncertain failures. It does **not** implement the proposed durable publishing bridge. Implement that application adapter explicitly: persist the run/action-to-Saga mapping before effects, reconnect/drive the same Saga, and settle or reconcile the corresponding Fabric action from retained evidence. Preserve the full report, including unknowns and cleanup failures. Sources: `/code/gleam-dream/fabric/consumers/saga_tool/src/saga_tool.gleam:9`; `/code/gleam-dream/fabric/src/fabric.gleam:1197`.
- Saga resolvers return `Completed`, `Failed`, `NotSent`, or `MaybeSent`; interrupted undo/compensation need their own resolvers. `unfinished` discovers work but never drives it; `drive` timeout stops its runner without cancelling saved execution. Sources: `/code/gleam-dream/saga/src/saga/durable.gleam:314`, `:370`, `:394`, `:671`, `:706`.

The business applied marker remains application-owned; do not assume atomicity with runtime checkpoints. Provider compatibility and infrastructure-specific idempotency/retention guarantees remain implementation checks.

Output: `/private/tmp/gleam-skills-eval-20261020/04-agent.md`

Summary: retain the existing queue, use Fabric for agent/approval recovery, and a deliberately integrated durable Saga for publication, with evidence-based reconciliation and transactional result incorporation.
