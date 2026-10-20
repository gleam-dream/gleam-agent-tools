---
name: retrace
description: Reconstruct frontend sessions from safe models and accepted messages with Retrace, especially Lustre updates. Use for typed checkpoints, capture, inert replay, historical builds, frontend delivery, and optional server archival.
---

# Retrace

Choose Retrace to understand how a user reached a frontend state: record safe model checkpoints and accepted messages, then reconstruct their transitions through an inert view. Lustre's model/message updates fit this directly; the portable core is independent of Lustre.

## Abstraction decision tree

```text
What evidence is needed?
├── One diagnostic or aggregate behavior → Logs or metrics
├── Arbitrary screen/DOM recording → A different recorder
├── Authoritative business history → A business event store
└── Accepted frontend transitions and reconstruction → Retrace
   ├── Portable recording/replay or local-only export → core
   ├── Browser/Tauri delivery or Lustre capture/viewer → retrace_frontend
   └── PostgreSQL admission/object archival → retrace_server
```

Pin imported Retrace packages to one revision. Core supports Erlang/JavaScript; frontend targets JavaScript and server Erlang. Select browser/native adapters deliberately; preserve a suitable existing recorder.

## Record accepted, safe transitions

1. Project safe models and messages before capture/encoding; exclude credentials and private values.
2. Use session and contract identities, a monotonic elapsed clock, and separate sessions for concurrent writers.
3. With core, accept through the reducer, `record` the event, then `checkpoint` the resulting model. Retain the returned recorder. `resume` trusts the recovered checkpoint; it grants no exclusive writer ownership.
4. In Lustre, run capture's startup effect and process its connection message through `capture.update` before observing; an early observation stops capture. Pass the pre-transition model to `capture.observe`; exclude coordination messages from the domain stream.
5. Frontend capture requires storage and an upload transport. For local-only recording/export, use core with application-owned storage; the frontend viewer is independent. Do not fake upload success to implement export.
6. `record` numbers events without acknowledging persistence; commit cursor/checkpoint and outbox consistently when crash recovery matters.

Handle capture failure separately from domain updates; surface stopped recording when users depend on capture.

## Reconstruct without live effects

- Supply a deterministic reducer and inert view. Record external results as messages; never repeat live effects during replay.
- Match failures for gaps, duplicates, contract mismatch, backwards time, and reducer errors. Failed steps preserve the prior player; fetch missing ranges or deduplicate explicitly.
- Retain historical replay artifacts under their build identity. Refuse missing/incompatible artifacts rather than substituting today's reducer.
- Keep contract compatibility, build identity, artifact integrity, and viewer authorization separate. Identity strings do not prove authenticity.

## Deliver and archive explicitly

- Own frontend client startup/shutdown and invoke replay/viewer disposers.
- Distinguish local save, collector acknowledgement, and object archival. Verify session and final cursor before removing queued data; retries cannot repair a permanently invalid first batch.
- If using the server, supply pool/object store and own migrations, archive workers, authentication, consent, and retention. Use `accept` for atomic admission; `accept_in_transaction` belongs inside a caller-owned transaction.
- For server erasure, drive `erase` with `Eraser(remove, quiesced)`; match `Erasing`, `AwaitingWriters`, and `Erased`. Fencing stops new upload admission; admitted attempts may still dispatch. Quiescence requires no future local dispatch and no issued request able to publish. Worker death, timeout, or DELETE alone is insufficient.
- Before server deployment, check schema compatibility: the write-attempt schema refuses earlier tombstone layouts without an in-place upgrade.

## Red flags

- Redacting only in the viewer after recording secrets.
- Passing the post-transition model to capture or sharing a writer cursor.
- Replaying through a live effectful update path.

## Verify

Verify changed core claims on both targets. Exercise browser, native delivery, or archival in its own runtime when claimed.

## Sources

[Capture and replay examples](https://github.com/gleam-dream/retrace/tree/31352e53c7673fd948540e2f7cbe921a9903b203/examples) · [Core API](https://github.com/gleam-dream/retrace/blob/31352e53c7673fd948540e2f7cbe921a9903b203/src/retrace.gleam) · [Server and erasure](https://github.com/gleam-dream/retrace/blob/31352e53c7673fd948540e2f7cbe921a9903b203/packages/retrace_server/README.md)
