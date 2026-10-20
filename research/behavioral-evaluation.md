# Behavioral evaluation and shutdown repair

Evaluated on October 20, 2026. All 19 guides were selected across the original eleven fresh-agent tasks. The accepted follow-up changed only Retrace, Grind, Saga and Sinal guidance, then reran six affected tasks with new agents and unchanged prompts. Oversight's support-desk lifecycle was repaired separately. No dependency lock, sibling library, installed skill or design verification ledger changed.

## Guide changes

| Guide | Clarification | Current words / lines |
| --- | --- | --- |
| Retrace | Core accept → record → resulting-state checkpoint; trusted resume; connected capture versus local-only export. | 607 / 63 |
| Grind | Borrowed transactional uncertainty resolution with application acknowledgment, staged results and outer-commit readback. | 603 / 57 |
| Saga | Per-invocation reporting owner, independent callback lifetime and the narrow meaning of rollback_within. | 634 / 59 |
| Sinal | Producer-side getters/encoders can raise before dispatch, with no observers or with forwarding. | 614 / 58 |

All 19 remain independent, single-file skills, at most 650 words and 80 lines. Structural checks passed with 23 unique exact-revision local source paths; refreshed Retrace provenance remains separately recorded. [Current validation](validation.json).

## Fresh-agent reruns

Each worker started with `fork_turns=none`, the same available default model configuration, catalog discovery and no prior answers/findings. INITIAL was saved before primary-source checking, then VERIFIED appended. A fresh independent adjudicator froze its grades before reading the previous adjudication. [Exact inputs, hashes and method](evaluations/2026-10-20/after/run.json), [rubric](evaluations/2026-10-20/after/rubric.json), [full adjudication](evaluations/2026-10-20/after/adjudication.md).

| Scenario | Observed result |
| --- | --- |
| [Frontend](evaluations/2026-10-20/after/02-frontend.md) | INITIAL chose core local recording/export and optional inert frontend viewer; no upload-adapter assumption. |
| [Research agent](evaluations/2026-10-20/after/04-agent.md) | Preserved queue/Fabric/Saga authorities, native binding, uncertain effects and application incorporation. Source verification clarified fresh approval after runner incarnation loss. |
| [Observation](evaluations/2026-10-20/after/06-observation.md) | INITIAL preserved optional diagnostics, ephemeral refresh and required payments, including producer encoder failure without observers. |
| [Financial recovery](evaluations/2026-10-20/after/09-oversight-financial.md) | INITIAL selected transactional queue resolution plus application acknowledgment; retained separate financial settlement and Saga evidence. |
| [Support desk](evaluations/2026-10-20/after/10-oversight-support.md) | Understood per-invocation reporting and borrower lifetime; verified the repaired App shutdown path. Its early Desk ownership wording finding was resolved by the final drain-phase comment. |
| [Core replay](evaluations/2026-10-20/after/11-oversight-replay.md) | INITIAL correctly accepted before record and checkpointed resulting state; no frontend pre-state confusion or archive/runtime requirement. |

Independent architectural scores were 59/60 INITIAL and 60/60 VERIFIED. The one deduction concerned unstarted approved actions requiring a fresh reference after runner loss, not a failure in one of the four added clarifications. These are judgments of written designs, not generated applications or measured success rates.

For the three numerically comparable synthetic cases, frontend INITIAL changed from 9/10 to 10/10, research remained 9/10 with a different narrower omission, and observation remained 10/10. VERIFIED stayed 10/10 for all three. Prior Oversight tasks had narrative judgments, so no numeric improvement is fabricated. [Previous adjudication](evaluations/2026-10-20/before/adjudication.md). The earlier Warden configuration omission was outside the requested changes and was not rerun.

## Oversight lifecycle repair

Base: Oversight `15aceae5e73a0d1c4b943a0898291f5a8933259e`, plus the recorded [working-tree inputs](evaluations/2026-10-20/after/oversight-inputs.json). The App now drains Fabric admission/runners and waits for independent Saga terminal reporting before releasing borrowed resources. A tracker retains invocations until a full terminal report or proven NotStarted. Unknown reporting or tracker loss returns an error and retains dependencies. The report observation uses one monitored twenty-second wait; this is not an overall shutdown deadline.

The listener, request recorders, ledger, telemetry collector/attachments, Fabric store and invocation tracker now have owned cleanup paths. Expected startup failures unwind acquired resources in reverse order. `app.stop` returns `Result(Nil, String)`, and ordinary callers check it. `desk.stop` documents its role as App's drain phase; App retains the tracker through remaining fallible cleanup so retry remains possible. Private `desk.build` has no other repository callers.

Five public regressions cover repeated resource/listener retirement, refused-startup cleanup, suspended runs, active refund completion with live borrowers, and forced Fabric drain while Saga cancellation/reporting still uses them. The native additions are limited to a shutdown signal and test-only ownership/registration inspection; lifecycle policy remains in Gleam.

Original-source regression: 21 passed, five behavioral failures. The original Nil stop call was adapted only for the new tests; no Result-signature compilation failure is counted as red. [Raw baseline log](evaluations/2026-10-20/before/shutdown-regression.log).

Final actual-tree acceptance, independently rerun by the parent:

```sh
nix develop --command python3 -B scripts/ci.py application support_desk
```

Passed formatting, warnings-as-errors build, native helper compilation and all 26 tests with Gleam 1.19.2 / OTP 29. [Receipts](evaluations/2026-10-20/after/acceptance-receipts.json) and [retained logs/provenance](evaluations/2026-10-20/after/runtime/). A final comment-only clarification passed a separate format check. Both repositories passed `git diff --check`.

The same two-cycle public start/stop VM probe changed from 43 newly live processes to zero. It now also requires both stop Results to succeed. [Before](evaluations/2026-10-20/before/support-stop-probe.log), [after](evaluations/2026-10-20/after/support-stop-probe.log), [probe](evaluations/2026-10-20/after/probe_support_stop.py). This observation covers repeated idle lifetimes; active and forced-drain behavior are covered by the application regressions.

Independent [shutdown review](evaluations/2026-10-20/after/shutdown-review.md) found no material issue after checking ownership, registration/termination races, lost-report retention, deadlines, listener isolation and the final source. The reviewer inspected tests but did not claim to have executed the parent's checks.

## Limits

There is one response per task, no no-skill control, no randomized repeats and no causal/statistical improvement claim. Some prompts explicitly name unsafe alternatives. Source-checking amendments remain visible. Runtime evidence is from existing scripted consumers and the focused lifecycle probe, not applications generated from the scenario answers. The earlier financial/replay runtime results remain historical; this repair's fresh executable acceptance targets support_desk.

Cancellation/resource shutdown does not reverse external effects. Unconfirmed Saga reporting intentionally prevents successful teardown. Upstream Warden stop may return after its own five-second wait without proving every hidden worker stopped; Oversight cannot strengthen that public guarantee. The repair does not certify live providers, remote-effect settlement, browser capture, cluster delivery, database failover or complete production shutdown under arbitrary faults. Research evidence is dated; it is not competing application design authority.
