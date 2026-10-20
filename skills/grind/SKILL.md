---
name: grind
description: Build and debug durable PostgreSQL jobs with Grind. Use for typed workers, scheduling, retries, transactional submission, cancellation, uncertain effects, recovery, and retention.
---

# Grind

Choose Grind when work must survive its request, become available on a schedule, and retain typed outcomes, with Erlang/OTP and PostgreSQL fitting that lifecycle. Preserve a suitable existing queue. Use supervised in-memory work when loss is acceptable, and a workflow for dependent effects.

Its recovery model preserves uncertainty: an abandoned effect can require investigation and an attributed resolution before replay. Plan that operational responsibility alongside durable admission.

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

- Inspect `gleam.toml`, the manifest, and public APIs first. The researched 0.1.0 is unpublished and requires Gleam >=1.18 on Erlang. Pin the Git revision; preserve its narrow Pog/pgo ranges.
- Define stable worker identities and versions with typed input/output/error codecs. Keep old stored jobs readable across deployments; changing callback meaning can require a version change even when the types match.
- Register workers with `with_worker`; add `supervised` to the application's supervision tree. Pair script-owned `start` with `stop`.
- Let Grind own its pool. Borrow `connection` when useful. Budget one additional reserved renewal connection per used queue; queue capacity is local to a consumer.
- Select one migration owner: package migrations or Cigogne mirrors. Install the schema before starting consumers; use startup migration only where that role owns DDL.

## Submission and recovery

- Use one submission key for one exact command. Keep it stable across retries. Uniqueness selects an occupying job; submission receipts recover the original admission decision.
- Retain `PendingSubmission` from `CommitUnknown` and call `reconcile_submission`. A lost reply does not authorize a new command or a fresh key.
- Use `submit_in` with the caller's open READ COMMITTED transaction in the same database. Propagate errors to its owner. Its reply is staged admission; only the outer commit settles business writes.
- Give effectful providers an application idempotency key they actually enforce. Job admission deduplication alone cannot prevent repeated external effects.
- Preserve `Uncertain` after an abandoned or possibly completed effect. Investigate authoritative evidence, then issue an attributed `admin.resolution` to confirm the outcome or authorize replay.
- Treat cancellation as cooperative intent. It cannot retract an effect or settle uncertainty; cancellation intent forbids replay authorization.
- Read durable outcomes for correctness. `await` returning `Pending` does not cancel work; its final read can exceed the requested wait budget. Telemetry is best effort.
- Set retention deliberately. Pruning removes receipts and ends submission recovery/deduplication; preserve permanent business idempotency elsewhere.

## Red flags

- New submission key after a timeout or `CommitUnknown`.
- Treating a uniqueness window as a permanent business ledger.
- A staged reply presented as proof of the caller's commit.
- Replaying `Uncertain` work because the process died.
- Assuming cancellation means no effect happened.
- Treating local queue limits as a cluster quota.
- Promising cron, batch coordination, or dependency workflows from intended design alone.

## Sources

[Consumer API and examples](https://github.com/gleam-dream/grind/tree/bcd4b9205392596bbb3c60cd94d0c251e5072110), [runtime and recovery design](https://github.com/gleam-dream/grind/blob/bcd4b9205392596bbb3c60cd94d0c251e5072110/docs/design/design.typ).
