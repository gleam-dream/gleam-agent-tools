# Support desk shutdown review

Independent read-only review of the uncommitted repair in `/code/gleam-dream/oversight`, based on HEAD `15aceae5e73a0d1c4b943a0898291f5a8933259e` plus the working changes. No material issue found in the reviewed scope.

## Adherence

Clean for the inspected lifecycle boundary. The change follows the composition design's separate execution, settlement and cleanup intervals, borrowed-resource lifetime rule, and preservation of unresolved effects. Application cleanup remains in Oversight; Fabric and Saga retain their own execution authority. The new execution tracker records application ownership rather than introducing a competing workflow engine.

Read `AGENTS.md`, the root design, composition/application vocabularies and relevant design sections, context map, coverage and ADRs 0002–0006 and 0018. The carried-over verification entries remain pending; this review does not certify the complete design layer or sibling-library implementation.

## Spec

Clean against the supplied accepted repair brief: normal shutdown closes Fabric admission and drains runners; a separate wait preserves the lifetime of independently settling Saga work; uncertain cleanup fails before borrower release; refused startup unwinds acquired resources. The listener, recorders, ledger, telemetry registrations/collector, Fabric store and execution tracker all have explicit application cleanup paths.

`app.stop` now returns a checked result, and its executable callers check it. `desk.stop` documents its drain-phase role and the App's later tracker ownership. These are fixture-application changes; no sibling API or lockfile changed. No standalone tracker issue was supplied or found under `issues/`.

## Standards

Clean in the inspected changed code and callers. The recipe uses public Fabric/Saga modules, the application keeps its lifecycle decisions in typed Gleam, and the native additions are thin: one Erlang exit primitive plus test-only ownership-link and telemetry-registry inspection. `git diff --check` passed during this review. No repository edits, builds or live services were performed by this reviewer.

## Craft

No actionable defect found after tracing startup failure, suspended shutdown, normal active refund completion, forced Fabric drain and independent Saga reporting:

- Invocation registration is acknowledged before Saga launch. Once Fabric has stopped its tool bodies, no new tracked invocation can begin. A body lost during registration/startup can conservatively leave cleanup unconfirmed; it cannot cause borrowers to be released early.
- Only a complete terminal Saga report or a reporting error with `NotStarted` effect status releases an invocation. Unknown report loss retains it. Duplicate terminal release is harmless. The late callback releases ownership before attempting Fabric settlement, so refusal by the retired Fabric store does not strand otherwise confirmed cleanup.
- The final `await_idle` uses one `selector_receive(20_000)` with both reply and process monitor. Its unnamed subject still yields the dead owner's PID, whose monitor supplies an error; the owner lookup assertion does not turn ordinary tracker death into a panic. Timeout and tracker loss return errors, and `app.stop` exits before releasing borrowed resources. A timed-out waiter is removed.
- Listener exit trapping belongs to its owner process. Listener shutdown waits for the owned subtree before its recorder stops. Startup cleanup is registered after each acquisition, and a failed agent build also stops the newly acquired execution tracker.
- The source does not infer prevented payment, successful compensation or remote-effect reversal from local worker cancellation or resource shutdown.

The final helper and `desk.stop` clarification were reread after the parent's source-stability notice. Final helper SHA-256: `59733ad769544196d719ee3b80d3780a981af4c45366e9c6df19aa4815e2ec9b`.

## Evidence and limits

Inspected every changed source/test file, the new listener/executions modules and test FFI, their application callers, and pinned public contracts: Fabric `815fc5971e0ae8e7783f122e1ee00a7e50c08de7`, Saga `c09b7a7c72148fcaf73fea96cb595ccf16a56e7b`, Gleam OTP 1.3.0 and relevant process primitives. Also checked Warden/HTTP shutdown contracts where they constrain the application.

The parent reports the actual-tree application profile passed all 26 tests after the helper change. This review inspected those tests but did not independently execute them. Their public lifecycle checks cover owned-process retirement, listener/client refusal after stop, telemetry detachment, rejected-configuration cleanup, suspended-store retirement and borrower availability through both normal and forced-drain Saga termination. That is local scripted evidence, not live-provider or remote-effect qualification.

The twenty-second bound covers the Saga-report observation phase, not total `app.stop` wall time. Fabric drain, listener cleanup and upstream stop operations have separate contracts. Warden explicitly allows its stop call to return after a five-second wait without proving every hidden worker stopped; this repair cannot strengthen that upstream guarantee through its public interface. A permanently lost Saga terminal report intentionally prevents successful teardown and retains resources.

Optional enrichment, not a delivery defect: a future regression could exercise lost-report/tracker failure while asserting borrower retention. The present success-path and forced-drain tests do not execute that error branch; the branch's ordering and failure behavior were checked directly against source.
