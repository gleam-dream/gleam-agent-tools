---
name: grind
description: Build and debug durable PostgreSQL jobs with Grind. Use for typed workers, scheduling, retries, transactional submission, cancellation, uncertain effects, recovery, and retention.
---

# Grind

Choose Grind when work on Erlang/OTP and PostgreSQL must survive its request, become available on a schedule, and retain typed outcomes. Preserve a suitable existing queue. Use supervised in-memory work when loss is acceptable, and a workflow for dependent effects.

Its recovery model preserves uncertainty: an abandoned effect can require investigation and an attributed resolution before replay. Plan for that operational work.

## Abstraction decision tree

```text
Does work need durable admission and retained outcomes?
├─ No → Plain function or supervised in-memory work
└─ Yes → Erlang/OTP and PostgreSQL fit?
   ├─ No → Keep the project's suitable queue
   └─ Yes → Grind
      ├─ Caller transaction → submit_in
      ├─ Lost admission reply → reconcile_submission
      └─ Unknown handler effect → Investigate, then resolve
```

## Define and own the runtime

- Inspect `gleam.toml`, the manifest, and public APIs. Use Hex `grind` 0.2.2 on Erlang with Gleam >=1.18. Retain the manifest and narrow Pog/pgo ranges.
- Define stable worker identities and versions with typed input/output/error codecs. Keep old stored jobs readable across deployments; changing callback meaning can require a version change even with matching types.
- Register workers with `with_worker`; add `supervised` to the application supervisor. Pair script-owned `start` with `stop`.
- Keep worker values small: each job copies a closure over the whole worker definition three times, and its handler keeps one while it runs. Apply the `gleam-otp` process-copy rule to the worker value.
- Budget `admin.settle_due` copying its queue's settlement closures into the caller; since 0.2.2 no other call copies workers.
- Let Grind own its pool. Borrow `connection` when useful. Budget one extra reserved renewal connection per used queue; queue capacity is local to a consumer.
- Select one migration owner: package migrations or Cigogne mirrors. Install the schema before starting consumers; use startup migration only where that role owns DDL.

## Submission and recovery

- Use one submission key, stable across retries, for one exact command. Uniqueness selects an occupying job; receipts recover the original admission decision.
- Retain `PendingSubmission` from `CommitUnknown` and call `reconcile_submission`. A lost reply does not authorize a new command or a fresh key.
- Use `submit_in` with the caller's open READ COMMITTED transaction in the same database. Propagate errors to its owner. Its reply is staged admission; only the outer commit settles business writes.
- Give effectful providers an application idempotency key they enforce. Admission deduplication cannot prevent repeated external effects.
- Preserve `Uncertain` after an abandoned or possibly completed effect. Investigate authoritative evidence, then issue an attributed `admin.resolution` to confirm the outcome or authorize replay.
- Use `admin.resolve_uncertain_in` when resolution and application acknowledgment must commit together: same-database READ COMMITTED transaction, supplied transaction connection. Keep investigation outside held locks and propagate errors. Its staged reply proves no outer commit; after a lost commit reply, read the durable application acknowledgment.
- Treat cancellation as cooperative intent. It cannot retract an effect or settle uncertainty; its intent forbids replay authorization.
- Read durable outcomes for correctness. `await` returning `Pending` does not cancel work; its final read can exceed the wait budget. Telemetry is best effort.
- Set retention deliberately. Pruning removes receipts and ends submission recovery/deduplication; preserve permanent business idempotency elsewhere.

## Red flags

- New submission key after a timeout or `CommitUnknown`.
- Treating a uniqueness window as a permanent business ledger.
- A staged reply presented as proof of the caller's commit.
- Replaying `Uncertain` work because the process died.
- Assuming cancellation means no effect happened.
- A worker closure that captures an environment, catalogue or agent.
- Treating local queue limits as a cluster quota.
- Promising cron, batch coordination, or dependency workflows, which Grind lacks.

## Sources

[HexDocs](https://hexdocs.pm/grind/0.2.2/) · [Consumer API and examples](https://github.com/gleam-dream/grind/tree/v0.2.2), [transactional resolution](https://github.com/gleam-dream/grind/blob/v0.2.2/src/grind/admin.gleam), [runtime and recovery design](https://github.com/gleam-dream/grind/blob/v0.2.2/docs/design/design.typ).
