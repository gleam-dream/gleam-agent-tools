---
name: grind
description: Build and debug durable PostgreSQL jobs with Grind. Use for typed workers, scheduling, retries, transactional submission, cancellation, uncertain effects, recovery, and retention.
---

# Grind

Choose Grind when work on Erlang/OTP and PostgreSQL must survive its request, become available on a schedule, and retain typed outcomes; use a workflow for dependent effects.

Its recovery model preserves uncertainty: an abandoned effect can require investigation and an attributed resolution before replay. Plan for that operational work.

## Abstraction decision tree

```text
Does work need durable admission and retained outcomes?
├─ No → Plain function or supervised in-memory work
└─ Yes → Erlang/OTP and PostgreSQL fit?
   ├─ No → Keep the project's suitable queue
   └─ Yes → Grind
      ├─ Caller transaction → submit_in
      ├─ Several jobs, one transaction → submit_many
      ├─ Lost admission reply → reconcile_submission
      └─ Unknown handler effect → Investigate, then resolve
```

## Define and own the runtime

- Add the latest `grind` release on Erlang; inspect public APIs, retain the manifest, and narrow Pog/pgo ranges.
- Give workers stable identities, versions, and typed input/output/error codecs. Keep old stored jobs readable across deployments; changing callback meaning can require a new version even with matching types.
- Register workers with `with_worker`; add `supervised` to your supervisor. Pair script-owned `start` with `stop`.
- Keep worker values small: each job copies a closure over the whole worker definition three times, and its handler keeps one while it runs.
- Budget `admin.settle_due` copying its queue's settlement closures into the caller; no other call copies workers.
- Let Grind own its pool and borrow `connection` when useful. Budget one extra reserved renewal connection per used queue; queue capacity is local to a consumer.
- Select one migration owner: package migrations or Cigogne mirrors. Install the schema before starting consumers; use startup migration only where that role owns DDL. Run `grind.migrate` on a session-mode connection; never wrap Cigogne files in one transaction.

## Submission and recovery

- Use one submission key, stable across retries, per exact command. Uniqueness selects an occupying job; receipts recover the original admission decision.
- Retain each `PendingSubmission` from `CommitUnknown` or `BatchCommitUnknown` and call `reconcile_submission`; a lost reply authorizes no new command or fresh key.
- Use `submit_in` with the caller's open READ COMMITTED transaction in the same database and propagate errors to its owner. Its reply is staged admission; only the outer commit settles business writes.
- Give effectful providers an application idempotency key they enforce. Admission deduplication cannot prevent repeated external effects.
- Preserve `Uncertain` after an abandoned or possibly completed effect. Investigate authoritative evidence, then issue an attributed `admin.resolution` to confirm the outcome or authorize replay. Match every `abandoned.cause`, `HandlerCrashed` included, and keep job data out of stored panic messages.
- Use `admin.resolve_uncertain_in` when resolution and application acknowledgment must commit together, in a same-database READ COMMITTED transaction, passing its connection. Keep investigation outside held locks and propagate errors. Its staged reply proves no outer commit; after a lost commit reply, read the durable acknowledgment.
- Treat cancellation as cooperative intent: it cannot retract an effect or settle uncertainty and forbids replay authorization.
- Read durable outcomes for correctness; telemetry is best effort. `await` returning `Pending` cancels nothing, and its final read can exceed the wait budget.
- Set retention deliberately: pruning removes receipts and ends submission recovery/deduplication; preserve permanent business idempotency elsewhere.

## Red flags

- New submission key after a timeout or `CommitUnknown`.
- Treating a uniqueness window as a permanent business ledger.
- A staged reply presented as proof of the caller's commit.
- Replaying `Uncertain` work because the process died.
- Assuming cancellation means no effect happened.
- A worker closure that captures an environment, catalogue or agent.
- Treating local queue limits as a cluster quota.
- Promising cron or dependency workflows beyond Grind's public API.

## Sources

[HexDocs](https://hexdocs.pm/grind/) · [Consumer API and examples](https://github.com/gleam-dream/grind), [transactional resolution](https://github.com/gleam-dream/grind/blob/main/src/grind/admin.gleam), [runtime and recovery design](https://github.com/gleam-dream/grind/blob/main/docs/design/design.typ).
