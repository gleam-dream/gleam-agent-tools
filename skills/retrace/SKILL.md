---
name: retrace
description: Record safe application transitions and reconstruct sessions with Retrace. Use for typed checkpoints, Lustre capture, durable frontend delivery, archive ownership, historical replay, and recording compatibility in Gleam applications.
---

# Retrace

Use Retrace for selected application-message recording and reconstruction. The application owns safe projections, reducer determinism, clocks, authorization, and resource lifetimes. Preserve an existing recorder when its guarantees fit.

## Abstraction decision tree

```text
Need logs or metrics only? → Telemetry
Need typed state reconstruction from accepted events? → retrace
├── Portable recording and replay only → core package
├── Browser/Tauri delivery or Lustre capture/viewer → retrace_frontend
└── PostgreSQL admission and object archival → retrace_server
```

Declare only imported packages and pin all Retrace packages to the same Git revision. Core supports Erlang and JavaScript; frontend targets JavaScript and server targets Erlang. Select browser or native adapters explicitly.

## Record accepted, safe transitions

1. Define safe model and message projections before recording or encoding. Exclude credentials and private values at capture time.
2. Start with a session identity and contract identity. Use a monotonic elapsed clock and a separate session identity for each concurrent writer.
3. Record accepted domain messages and retain the returned recorder cursor. `record` numbers an event; it does not acknowledge persistence.
4. If crash recovery matters, commit cursor/checkpoint and outbox consistently before resuming from them.
5. For Lustre, connect capture once and call `capture.observe` with the pre-transition model. Keep capture coordination messages outside the recorded domain stream.

Handle capture failure separately from domain updates: recording can stop while the application continues. Surface that recording status when users depend on capture.

## Deliver and archive explicitly

- Start and stop the frontend client with its application owner. Retain and call disposers returned by replay or viewer mounting.
- Distinguish local save, collector acknowledgement, and object archival. Verify the expected session and final cursor before removing queued data.
- Account for rejected batches: fixed-delay retries do not resolve a permanently invalid first batch.
- Supply the server's database pool and object store. Own migrations, archive workers, authentication, consent, and retention policy.
- Use `accept` for atomic admission. Use `accept_in_transaction` only inside a caller-owned transaction; do not nest transactions blindly.
- Drive `erase` with `Eraser(remove, quiesced)` and match `Erasing`, `AwaitingWriters`, or `Erased`. Fencing prevents new upload admission; pre-admitted attempts may still dispatch. Prove no future local dispatch and no issued request can publish before declaring an in-flight attempt quiescent. Worker death, timeout, or DELETE alone is insufficient.
- Check schema compatibility before deployment. The write-attempt schema refuses earlier tombstone layouts and has no in-place upgrade path.

## Reconstruct without live effects

- Supply a deterministic reducer and an inert view. Record externally produced values as messages instead of reissuing network or native effects during replay.
- Match typed failures for gaps, duplicates, contract mismatch, backwards time, and reducer errors. A failed step leaves the prior player usable; fetch missing ranges or deduplicate explicitly.
- Retain historical replay artifacts under their build identity. Refuse missing or incompatible artifacts; do not substitute today's reducer or application build.
- Keep contract compatibility, build identity, artifact integrity, and viewer authorization separate. A matching identity string is not an authenticity proof.

## Red flags

- Recording an authenticated model, then hiding its secrets only in the viewer.
- Passing the post-transition model to `capture.observe`.
- Calling `record` durable storage or allowing concurrent writers to share a cursor.
- Replaying events through a live effectful update path.
- Assuming browser, native shell, and backend checks establish the same behavior.

## Verify

Check the consuming revisions. Validate changed core invariants on both supported targets; verify frontend delivery, browser behavior, and database archival only when claims depend on those boundaries.

## Sources

[Erasure contract](https://github.com/gleam-dream/retrace/blob/31352e53c7673fd948540e2f7cbe921a9903b203/packages/retrace_server/README.md) · [Usage topics](https://github.com/gleam-dream/retrace/tree/31352e53c7673fd948540e2f7cbe921a9903b203/examples) · [Public core API](https://github.com/gleam-dream/retrace/blob/31352e53c7673fd948540e2f7cbe921a9903b203/src/retrace.gleam)
