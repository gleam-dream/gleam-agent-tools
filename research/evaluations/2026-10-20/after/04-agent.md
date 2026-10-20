# INITIAL

Choose Fabric’s agent for model-selected research tools and retained approval/recovery. Use Saga for the dependent publish effects: write report object, then update public index, with cleanup of a known completed object write if indexing definitively fails. Keep the existing durable queue for admission, scheduled wakeups, and redelivery. Use LLM Wire beneath Fabric through its model adapter; do not build a second provider tool loop in the queue handler. A Fabric graph is unnecessary unless application-authored routing becomes a requirement. A database transaction alone cannot cover external object/index effects. Owner-bound Saga execution and an in-memory Fabric store do not meet runner-loss recovery requirements. Do not add Grind merely because the request must return early.

Selected complete guides:
- `/code/gleam-dream/gleam-agent-tools/skills/fabric/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/saga/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/llm-wire/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/grind/SKILL.md` (boundary guidance; package not selected)

Two decisive guide lines: “Bind approval to the exact action and current policy.” “Own wakeups, unfinished-run discovery, and redelivery.”

**Ordinary consumer path — architectural pseudocode, not runnable API:**

1. HTTP handler validates a `ResearchRequest`, creates a stable application request/run identity, and commits its Pending record and queue admission atomically if the existing queue supports it. Otherwise use an application outbox and admission reconciliation. Return accepted with request identity/status location.
2. Queue delivery looks up that identity and starts or reconnects its retained Fabric agent; retries must find the same run. Its short driving attempt may return while approval waits. A queue acknowledgment must not discard the only means of discovering unfinished work.
3. At startup define native tool input/output codecs and individual `tool.Definition`s; bind each typed handler before combining heterogeneous tools. Tools include document search/read and a publish operation whose handler starts/reconnects one durable Saga using stable execution identity and identical encoded input. The retained publish report distinguishes complete, failed cleanup, and unresolved effects.
4. Fabric owns provider request construction and transcript replay. Its model adapter uses the configured Wire model and application-owned HTTP client. Tool handlers receive fresh per-run context: tenant/request identity, current authorization/policy, database/object/index clients, and live credentials. Persist identifiers and typed execution records, not live connections or secrets.
5. A protected action becomes pending approval against exact decoded arguments/action identity and current policy. After runner loss, rebuild live context and verify the approval before execution. Changed arguments or requirements need new approval; a model’s text cannot grant permission.
6. A supervised recovery owner finds pending runs and resumes through supported recovery APIs. Queue wakeups drive durable Saga work when needed; its store alone is not a permanent scheduler. Polling or notifications can wake incorporation, but correctness reads retained records.
7. Inspect Fabric status and action snapshot plus Saga’s typed report before declaring business success. In one application transaction, lock/conditionally update the request, apply its terminal result, and write a unique applied marker for the request/run identity. Duplicate deliveries see that marker. If the commit reply is lost, read the durable marker. Retain terminal results until incorporation is confirmed; emit further notifications through an outbox if required.

Use native types such as `ResearchRequest`, `Finding`, `Citation`, `ReportDraft`, `ObjectReceipt`, `IndexReceipt`, and a `PublicationOutcome` distinguishing published, failed-with-cleanup-report, and awaiting-reconciliation. Wrap run/action/publication IDs distinctly; avoid dictionaries of opaque step values. Saga typed ports carry the draft to object creation and the object receipt to indexing and undo. Publication success means both required effects are proven, not merely that the agent returned an answer.

Configuration composes separately: reusable typed tool definitions, explicit Fabric policy/bounds, Wire generation settings and model adapter, durable stores, Saga definition/codecs/recovery resolvers, and application client/context factories. Build/validate definitions before accepting work. Set turns, concurrency, model/tool timeouts and an explicit application elapsed deadline; individual limits do not establish an overall deadline. Check every build/configuration error.

The application supervisor owns borrowed database pools, outbound HTTP resources, selected durable stores, Fabric recovery worker, queue consumers, and discovery/wakeup owner. Start dependencies before consumers; migrate stores through an explicit owner. Shutdown stops admission/driving, closes owned handles/clients after their users, and leaves unfinished durable runs discoverable. Request processes own none of these shared resources.

Definitely failed tools can explain a recoverable failure to the model. Timeout or abandoned writes may have completed: retain uncertainty and pause dependent work. Reconcile from authoritative effect evidence using stable run/action/effect identity. Replay only reads or writes whose idempotency the destination enforces; never replay merely to learn the outcome. Delete only an object proven created by this publication, using its exact receipt/version. If index outcome is unknown, neither retry indexing blindly nor delete an object it may expose. Cleanup failure remains explicit for operator repair; cancellation cannot prove absence of effects.

Verify resolved package versions, actual model/tool/start/recovery APIs, production-durable Fabric backend availability, Saga durability adapters and codec compatibility, queue admission/wakeup guarantees, approval verifier semantics, external idempotency/lookup consistency, and publication overwrite/delete rules. Missing requirements include who approves, approval expiry, whether index rollback is possible, retention and operational reconciliation ownership. These affect policy and recovery details, not the selected boundaries.

# VERIFIED

Public web fetches failed; verification used local primary-source checkouts whose HEADs match both guide pins exactly: Fabric `815fc5971e0ae8e7783f122e1ee00a7e50c08de7`, Saga `c09b7a7c72148fcaf73fea96cb595ccf16a56e7b`. No builds, live services, or repository changes were used.

Amend the ordinary path with these concrete contracts:

- Fabric is not a `start_or_reconnect` API. [`fabric.gleam`](https://github.com/gleam-dream/fabric/blob/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/src/fabric.gleam), local lines 319–497, exposes `start`, `AlreadyStarted(id, same_input)`, `StartUnconfirmed`, `matches_initial`, `open`, and `recover`. Resolve uncertain admission against the same ID and input. Use `open` for inspection/approval without takeover; use `recover` for actual recovery. Concurrent nodes require a leased backend; an unleased store may only take over when the old owner is known gone.
- Approval is stricter than simply rechecking an old grant. Fabric’s `recover` documentation at local lines 433–437 says an approved action not yet started requests approval again under a new reference after incarnation loss. A suspended pending request otherwise remains, subject to expiry and current verifier/policy checks.
- [`tool.gleam`](https://github.com/gleam-dream/fabric/blob/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/src/fabric/tool.gleam), local lines 194–244 and 416, confirms typed `bind`, optional `bind_settling`, and `tool.idempotency_key(call)`. The repository’s `consumers/saga_tool/src/saga_tool.gleam` demonstrates owner-bound reporting with settlement; it is not itself a durable Saga bridge. For this scenario build the bridge around durable execution IDs, persist its action-to-execution association, and reconcile the Fabric action from the saved Saga outcome. A timed-out bridge must not silently become publication success.
- [`durable.gleam`](https://github.com/gleam-dream/saga/blob/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b/src/saga/durable.gleam), local lines 1–60 and 317–329, confirms `start_or_reconnect`, `drive`, `unfinished`, and evidence variants. A drive timeout actually stops its runner/in-flight attempts; only the saved execution remains for another drive. Recovery must prove `NotSent`; `MaybeSent` suspends. `undo` reverses known completed work; compensation chooses recovery for a failed attempt.

Fabric’s `src/fabric/store.gleam` confirms supervised ownership and recommends PostgreSQL/application database storage for production; `src/fabric/llm.gleam:85` confirms the Wire model adapter borrows its HTTP client and requires configuration/settings again on reconstruction. Existing queue guarantees and external effect evidence remain application-specific and unverified. Keep the application applied-marker transaction separate from runtime checkpoint commits.

Output: `/private/tmp/gleam-skills-rerun-20261020/04-agent.md`

Summary: retain the queue, use Fabric for retained research/approval, durable Saga for publication effects, and an application transaction for one-time result incorporation.
