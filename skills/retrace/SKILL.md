---
name: retrace
description: Reconstruct frontend sessions from safe models and accepted messages with Retrace, especially Lustre updates. Use for typed checkpoints, capture, inert replay, historical builds, frontend delivery, and optional server archival.
---

# Retrace

Choose Retrace to learn how a user reached a frontend state: record safe model checkpoints and accepted messages, then replay transitions through an inert view.

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

Add the latest release of each imported package and retain `manifest.toml`. Core runs on both targets, frontend on JavaScript, server on Erlang. Preserve a suitable existing recorder.

The unpublished [`retrace_collector`](https://github.com/gleam-dream/retrace/blob/main/support/collector/README.md) installs from Git (`gleam-dream/retrace`, path `support/collector`): pin by commit the newest `retrace_collector-v*` tag whose gleam.toml accepts the resolved core, or run such a checkout. `RETRACE_ALLOWED_ORIGINS` replaces the default origins (empty admits none) and filters only requests with `Origin`; without `RETRACE_COLLECTOR_TOKEN`, any local process can use every route. The packaged transport and viewer send no token; with one, use a custom transport, source, or proxy.

## Record accepted, safe transitions

1. Project safe models and messages, without credentials or private values, before capture or encoding. A failed `capture.observe_projected` projection stops capture without recording the error.
2. Use session and contract identities, a monotonic elapsed clock, and separate sessions for concurrent writers.
3. With core, accept through the reducer, `record` the event, `checkpoint` the result, and retain the returned recorder. `resume` trusts the recovered checkpoint and grants no exclusive writer.
4. In Lustre, start capture from `wire.Metadata` and a flush window, run its effects, and route its messages through `capture.update`. Transitions before the session opens go unrecorded. Pass the pre-transition model to `capture.observe`; exclude coordination messages from the domain stream.
5. Frontend capture needs storage and an upload transport; for local-only recording or export, use core with application-owned storage and never fake upload success.
6. `record` numbers events without acknowledging persistence; commit cursor/checkpoint and outbox together.

Handle capture failure apart from domain updates and tell dependent users.

## Reconstruct without live effects

- Supply a deterministic reducer and inert view; record external results as messages.
- Match gap, duplicate, contract-mismatch, backwards-time, and reducer failures. A failed step keeps the prior player; fetch missing ranges or deduplicate explicitly.
- Retain replay artifacts under their build identity; refuse missing or incompatible ones, never substituting today's reducer.
- Keep contract compatibility, build identity, artifact integrity, and viewer authorization separate. Identity strings do not prove authenticity.

## Deliver and archive explicitly

- Own client startup; stop through `capture.stop`'s effect, which saves the open batch first, and invoke replay/viewer disposers.
- Distinguish local save, collector acknowledgement, and object archival. A rejection no retry can change discards that session's queue; a custom transport marks only such refusals `rejected`.
- With the server, supply pool and object store; own migrations, archive workers, authentication, consent, and retention. Never log `open`'s write token. `accept` admits a `wire.Upload` atomically, `accept_in_transaction` inside a caller's transaction; answer `Unauthorized` like `NotFound`.
- For server erasure, drive `erase` with `Eraser(remove, quiesced)` and match `Erasing`, `AwaitingWriters`, and `Erased`. Fencing stops new admission; admitted attempts can still dispatch. Quiescence means no future local dispatch or issued request can publish, which worker death, timeout, or DELETE alone does not prove.

## Red flags

- Redacting only in the viewer after recording secrets.
- Passing the post-transition model to capture or sharing a writer cursor.
- Replaying through a live effectful update path.

## Verify

Verify core claims on both targets and browser, native, or archival claims in their runtime.

## Sources

[HexDocs](https://hexdocs.pm/retrace/) · [Examples](https://github.com/gleam-dream/retrace/tree/main/examples) · [Core API](https://github.com/gleam-dream/retrace/blob/main/src/retrace.gleam) · [Server](https://github.com/gleam-dream/retrace/blob/main/packages/retrace_server/README.md)
