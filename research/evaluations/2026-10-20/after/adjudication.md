# Independent adjudication: five fresh-agent reruns

Read the rubric, each named prompt and complete answer, and the current complete portable guides selected by those answers. No prior evaluation answers, scores, reports, or parent findings were consulted. INITIAL is graded as saved; VERIFIED is the resulting design after its explicitly appended amendments. Scores describe these responses, not guide causality or passing runtime evidence. No builds, services, repository edits, or delegation occurred.

Axis order is selection / composition / configuration / ownership / recovery. A 2 means clear and correct at the scenario's architectural scope; it does not require an executable implementation. Appropriate, explicitly bounded uncertainty is not itself an error.

| Case | INITIAL | VERIFIED | Material distinction |
| --- | --- | --- | --- |
| 02 frontend | 2 / 2 / 2 / 2 / 2 | 2 / 2 / 2 / 2 / 2 | Verification makes retained history and historical bug behavior explicit. |
| 04 agent | 2 / 2 / 2 / 2 / 1 | 2 / 2 / 2 / 2 / 2 | Initial approval recovery omits incarnation-specific reapproval. |
| 06 observation | 2 / 2 / 2 / 2 / 2 | 2 / 2 / 2 / 2 / 2 | Installation/distribution remain explicitly unqualified. |
| 09 financial | 2 / 2 / 2 / 2 / 2 | 2 / 2 / 2 / 2 / 2 | Verification correctly distinguishes immutable finished uncertainty. |
| 11 replay | 2 / 2 / 2 / 2 / 2 | 2 / 2 / 2 / 2 / 2 | Correctly scopes the existing core consumer and target evidence. |

Totals: INITIAL 49/50; VERIFIED 50/50. No case-specific critical error override applies. These are frozen independent grades pending case 10 and any later comparison.

## 02 frontend

The answer chooses core for local capture/export and makes the frontend viewer optional. It keeps existing message ownership, rejects late redaction and live-effect replay, separates private live context, records external outcomes, guards superseded requests, and retains historical reducer/view artifacts. Separate writers, recorder ownership, export bounds, teardown and storage failure are explicit.

The rubric's pre-transition-model requirement applies to `capture.observe`. This answer deliberately selects core and correctly reduces before `record`, then checkpoints the resulting safe model. Penalizing it for not supplying a pre-transition model to the unused capture adapter would be wrong. Core documents this accepted-event contract in [record](https://github.com/gleam-dream/retrace/blob/13ef6f9c4304081bb60c13c9d6d3c0802170fdbb/src/retrace.gleam#L56); checkpoint construction does not validate model/stream consistency at L79–82.

VERIFIED explicitly retains the initial checkpoint and following entries, and clarifies that replay preserves historical stale-response behavior even when new releases fix it. INITIAL already calls for the matching historical artifact, so this is useful clarification rather than evidence that it proposed today's fixed reducer. It also identifies its source revision mismatch honestly. I independently checked the local core and viewer APIs: the viewer's replaceable Source/Resolver and mount disposer support its optional imported-file approach ([viewer L25–55](https://github.com/gleam-dream/retrace/blob/13ef6f9c4304081bb60c13c9d6d3c0802170fdbb/packages/retrace_frontend/src/retrace_frontend/viewer.gleam#L25)). Import wiring and browser execution remain unverified; no such success is claimed.

## 04 agent

Selection and composition are sound: preserve the existing queue, use Fabric for retained model-selected tools/approval, Wire for provider protocol, and durable Saga for publication's dependent effects. Native binding before heterogeneous combination, reconstructed credentials/context, adapter-specific clients, stable IDs, once-only application incorporation and coordinated retention are present. The answer correctly refuses timeout replay to discover effects and avoids deleting an object while indexing is uncertain.

The consequential INITIAL omission is narrower than its architecture: after runner loss it says to rebuild context and “verify the approval before execution,” without specifying that an already approved action which had not started must ask again under a new reference. Rechecking an old stored grant is insufficient. [Fabric's pinned recover contract](https://github.com/gleam-dream/fabric/blob/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/src/fabric.gleam#L433) explicitly requires fresh approval after incarnation loss. This warrants recovery 1, not a material-error 0: the answer demands exact action/current policy and names verifier semantics as requiring verification; it does not expressly authorize stale approval reuse.

VERIFIED repairs this precisely. It also distinguishes `open` from recovery/takeover, qualifies unleased ownership, resolves uncertain admission using the same identity/input, and makes the durable Fabric-action-to-Saga association explicit. Those amendments are consistent with the inspected pinned sources. Saga's [durable ownership contract](https://github.com/gleam-dream/saga/blob/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b/src/saga/durable.gleam#L49) confirms driver timeout stops in-flight execution without cancelling the saved run. A durable bridge still needs application implementation; the response labels that work rather than claiming the owner-bound example supplies it.

## 06 observation

Both stages separate optional diagnostics, lossy local invalidation and required payment execution. A direct callback/protocol is offered for one known recipient; Grind remains conditional on suitable infrastructure. The answer rejects the offered Roar/Whisper installation, refuses to invent a downgrade, and distinguishes browser-local fanout from server or cluster transport.

Ownership and overload detail is substantive: stable handler IDs, detachment/cancellation, callback execution contexts, trusted atom names, bounded queued-plus-running forwarding, drops without inline fallback, authoritative rereads, and no whole-memory/backpressure/draining claim. I checked the pinned Sinal forwarder source at `58c6e7d`, whose opening operational contract confirms those bounds and shutdown loss. [Native telemetry 1.4.2](https://telemetry.hexdocs.pm/1.4.2/telemetry.html#attach/4) confirms emitter-process execution, unspecified ordering and failed-handler removal.

The answer's failed source fetches are handled appropriately: it labels compatibility and cleanup cautions guide-derived and keeps installation unqualified. My fetches of the pinned Roar/Whisper raw sources also failed; I do not independently certify that pair's incompatibility here. That limitation does not make its refusal or conditional recommendation defective. Export deadlines, independent observer values and duplicate-ID handling in VERIFIED are useful refinements, not proof that INITIAL violated a boundary.

## 09 financial

INITIAL correctly separates provider evidence, Saga recovery authority, Grind delivery disposition, application settlement and queue acknowledgment. It explicitly commits financial settlement first, then atomically couples queue resolution with the application's acknowledgment using the transaction connection. It retains identity beyond queue pruning and forbids replay after cancellation.

I checked reconciliation's complete implementation and the principal relevant source/tests. The [ordinary preflight](https://github.com/gleam-dream/oversight/blob/15aceae5e73a0d1c4b943a0898291f5a8933259e/apps/financial_recovery/src/financial_recovery/reconciliation.gleam#L104) requires finished Unresolved and positive evidence; settlement L214–269 and confirmation L328–369 establish the two distinct transactions. [Grind's locked contract](https://github.com/gleam-dream/grind/blob/bcd4b9205392596bbb3c60cd94d0c251e5072110/src/grind/admin.gleam#L426) confirms staged resolution and readback after uncertain outer commit. Tests explicitly retain the original Saga report, refuse cancelled replay, and reuse completion after pruning. The temporary migration pool and subsequent Grind-owned named pool match VERIFIED's ownership amendment.

No scoped application defect is established. The proposed guide addition distinguishing suspended interrupted recovery from immutable finished Unresolved is justified preventive enrichment. INITIAL already sends finished uncertainty to application reconciliation; it does not propose reopening that terminal Saga. Source/test assertions are properly distinguished from freshly passing execution.

## 11 replay

Both stages select only portable core, retain application-native Cart/Message/CartError and deterministic reduction, and explain caller-owned recorder/player continuity and typed refusal. No frontend/archive/process requirement is invented.

The complete consumer and five tests support VERIFIED's account: accepted messages reconstruct Cart(2), checkpoint continuation reaches Cart(4), a gap leaves the original player usable, contract mismatch refuses, and reducer failure preserves native error and cursor. Core `step` returns only an error on failure; VERIFIED correctly says the caller retains the old player rather than extracting one from that error. `restore` returning only final Cart is explicitly distinguished from stepwise support tooling.

The configured target and [application profile](https://github.com/gleam-dream/oversight/blob/15aceae5e73a0d1c4b943a0898291f5a8933259e/scripts/ci.py#L148) establish which commands the profile selects, not passing execution or JavaScript/browser guarantees. The proposed checkpoint-consistency/`verify` guide example is optional enrichment. No missing feature or actual application defect follows from that suggestion.

## 10 support: separately frozen follow-up

INITIAL: **2 / 2 / 2 / 2 / 2**. VERIFIED: **2 / 2 / 2 / 2 / 2**. The five earlier grades remain unchanged. Six-case totals are INITIAL **59/60**, VERIFIED **60/60**.

INITIAL preserves the existing runtime and separates authenticated approver evidence, application permission, exact pending action, typed tool, Saga report and business result. It identifies reporting ownership, callback lifetimes and shutdown as verification obligations without inventing a process or durability requirement. Its phrase “authorization evidence” does not demand that Proof itself encode an action ID; there is no actual approval-semantics error to deduct.

VERIFIED traces the actual composed path. I checked the current approver, Desk, App, invocation tracker, Saga bridge, refund and shop implementations, relevant tests/design, and pinned Fabric/Saga public contracts. [Fabric approve](https://github.com/gleam-dream/fabric/blob/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/src/fabric.gleam#L894) combines the exact reference with requirement-scoped proof and rechecks current context. This supports the answer; an action-specific Proof is no missing feature. [Saga reporting](https://github.com/gleam-dream/saga/blob/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b/src/saga/reporting.gleam#L153) establishes the receiver before starting, owns report reception and monitors the returned coordinator, so early completion is handled. Unknown payment/report outcomes preserve uncertainty; reporting handles do not misuse ordinary await.

The tracker releases only confirmed terminal/not-started invocations. App waits for drain before releasing borrowed effect resources, and the late settlement path after tracker release uses neither shop nor ledger. Runtime claims remain inspected assertions; the parent's separately run profile is not evidence produced by this response.

The reported Desk ownership ambiguity needs a time qualification. The answer records Desk blob `3af7178`; current Desk blob is `9c253ae`, with the explicit comment that stop is App's drain phase, Error requires retaining resources, and App retains the tracker through remaining fallible cleanup. Thus its wording recommendation describes an earlier snapshot and is now satisfied. Retaining the tracker is intentional retry ownership, not an established App leak. No current application defect follows. The Proof/reference explanation is useful guide enrichment, not correction of a demonstrated INITIAL defect.

## Same-case comparison, read only after freezing

The old adjudication scores 02 INITIAL 9/10 versus this rerun's 10/10: the new answer selects core/local export immediately instead of leaving delivery capture unconnected. Old 04 INITIAL was 9/10 for composition; rerun remains 9/10, now for incarnation-specific reapproval. Its action/Saga relationship is more concrete, though VERIFIED still adds settlement detail. Old and rerun 06 remain 10/10. All three VERIFIED scores remain 10/10.

Old 09–11 have narrative assessments, not axis scores; no numerical delta is available. Financial authority remains sound, with the transactional-resolution guide omission now covered. Support reporting guidance is more explicit; the old partial-teardown finding is addressed in the changed application, while the latest Desk wording clarification resolves the rerun's narrower snapshot ambiguity. Replay now selects the core accept/record/post-state path from INITIAL without importing unused frontend terminology.

This compares one observed run/model response per case and stage. Source and application changes also differ, especially support shutdown. There is no controlled causal or statistical improvement claim, and no inference about other models or cases.
