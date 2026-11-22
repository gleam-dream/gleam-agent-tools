---
name: retrace
description: Reconstruct frontend sessions from safe models and accepted messages with Retrace, especially Lustre updates. Use for typed checkpoints, capture, inert replay, historical builds, frontend delivery, and optional server archival.
---

# Retrace

Choose Retrace to understand how a user reached a frontend state: record safe model checkpoints and accepted messages, then reconstruct transitions through an inert view. Lustre's updates fit directly.

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

Add the latest release of each imported package (`gleam add retrace`, `retrace_frontend`, `retrace_server`); retain `manifest.toml`. Core supports Erlang/JavaScript; frontend targets JavaScript and server Erlang. Preserve a suitable existing recorder.

The unpublished [`retrace_collector`](https://github.com/gleam-dream/retrace/blob/main/support/collector/README.md) installs from Git (`gleam-dream/retrace`, path `support/collector`, a `retrace_collector-v*` release tag). `RETRACE_ALLOWED_ORIGINS` replaces the default browser origins (empty admits none) but filters only requests carrying `Origin`; without `RETRACE_COLLECTOR_TOKEN`, any local process can use every route. The packaged transport and viewer send no token; with one, use a custom transport, source, or proxy.

## Record accepted, safe transitions

1. Project safe models and messages before capture/encoding; exclude credentials and private values. `capture.observe_projected` handles fallible projections: failure stops capture without recording the error.
2. Use session and contract identities, a monotonic elapsed clock, and separate sessions for concurrent writers.
3. With core, accept through the reducer, `record` the event, `checkpoint` the result, and retain the returned recorder. `resume` trusts the recovered checkpoint and grants no exclusive writer.
4. In Lustre, run capture's startup effect and process its connection message through `capture.update` before observing; an early observation stops capture. Pass the pre-transition model to `capture.observe`; exclude coordination messages from the domain stream.
5. Frontend capture requires storage and an upload transport; for local-only recording/export, use core with application-owned storage (the viewer is independent). Never fake upload success for export.
6. `record` numbers events without acknowledging persistence; commit cursor/checkpoint and outbox together for crash recovery.

Handle capture failure apart from domain updates and surface stopped recording to dependent users.

## Reconstruct without live effects

- Supply a deterministic reducer and inert view. Record external results as messages; never repeat live effects during replay.
- Match failures for gaps, duplicates, contract mismatch, backwards time, and reducer errors. Failed steps preserve the prior player; fetch missing ranges or deduplicate explicitly.
- Retain historical replay artifacts under their build identity. Refuse missing/incompatible artifacts; never substitute today's reducer.
- Keep contract compatibility, build identity, artifact integrity, and viewer authorization separate. Identity strings do not prove authenticity.

## Deliver and archive explicitly

- Own frontend client startup/shutdown and invoke replay/viewer disposers.
- Distinguish local save, collector acknowledgement, and object archival. Verify session and final cursor before removing queued data; retries cannot repair an invalid first batch.
- With the server, supply pool/object store and own migrations, archive workers, authentication, consent, and retention. Use `accept` for atomic admission; `accept_in_transaction` belongs in a caller-owned transaction.
- For server erasure, drive `erase` with `Eraser(remove, quiesced)`; match `Erasing`, `AwaitingWriters`, and `Erased`. Fencing stops new upload admission; admitted attempts may still dispatch. Quiescence requires no future local dispatch or issued request able to publish. Worker death, timeout, or DELETE alone is insufficient.

## Red flags

- Redacting only in the viewer after recording secrets.
- Passing the post-transition model to capture or sharing a writer cursor.
- Replaying through a live effectful update path.

## Verify

Verify core claims on both targets, and browser, native, or archival claims in their own runtime.

## Sources

[HexDocs](https://hexdocs.pm/retrace/) · [Capture and replay examples](https://github.com/gleam-dream/retrace/tree/main/examples) · [Core API](https://github.com/gleam-dream/retrace/blob/main/src/retrace.gleam) · [Server and erasure](https://github.com/gleam-dream/retrace/blob/main/packages/retrace_server/README.md)
