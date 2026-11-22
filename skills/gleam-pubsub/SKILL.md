---
name: gleam-pubsub
description: Design and debug application notifications with Whisper and Roar. Use for local topics, subscriptions, buffers, callbacks, BEAM cluster distribution, cleanup, and delivery limits.
---

# Gleam pub/sub

Use ephemeral fanout when several independent consumers should react to a change, such as views notified to reread an entity. A callback or subject suffices for one known recipient. Keep authoritative state elsewhere so missed notifications can be repaired by rereading it.

## Abstraction decision tree

```text
What delivery contract does the application require?
├─ Durable receipt, replay, or required command → Durable store/protocol
├─ Diagnostic observation on BEAM → Telemetry
└─ Ephemeral application notification → Choose scope
   ├─ Local Erlang or JavaScript → Whisper candidate; qualify target/version
   └─ BEAM cluster → Roar candidate; establish a compatible pair first
```

## Check compatibility before selection

- Inspect the resolved manifest and public API. Both packages are experimental. Roar's release calls Whisper's router API (`whisper.new`, `whisper.on(roar.local, …)`), which the topic API replaced, yet its range admits the topic API, so the pair does not compile.
- Never invent a working downgrade. Establish a normally resolved, compiled pair before selecting Roar for a new application.
- Qualify Whisper alone on the selected target and resolved graph.
- With the topic API, `new_topic` returns a checked topic value; `subscribe` and `on` receive that value directly.

## Own topics and subscriptions

- Define one application-owned payload contract per topic name. The BEAM registry is node-wide and the JavaScript registry is module-wide; a topic is not request-private merely because its value is local.
- Keep topic definitions and handles under one owner. `Whisper(a)` does not establish a global schema registry or validate foreign message representations.
- Retain cancellation closures and invoke them when the consumer ends. Close topics only through their owner; normal consumer exit does not guarantee subscription cleanup.
- Distinguish `Message`, `Empty`, and `Closed` in Whisper receive results. An empty buffer is not a closed subscription; polling it does not provide backpressure.
- Avoid reusing a closed topic name while stale handles remain. Topic handles address names; an old handle can address a replacement. On JavaScript, old subscription closures can also affect replacement subscribers.

## Bound work and preserve recovery

- Set buffer capacity from expected bursts and acceptable loss. Old messages are dropped when a subscription fills; this bounds that buffer, not all mailboxes or total application memory.
- Keep callbacks short and failure-aware. Whisper's JavaScript callbacks execute inside `publish`; BEAM callbacks execute inside the topic server. Blocking and exceptions affect those owners and can disrupt delivery.
- Check BEAM startup ownership. The registry and topics start linked; do not assume an independently supervised service or isolated callback crashes.
- Treat `publish` returning as notification submission, without a durable receipt. Keep authoritative state elsewhere and define how a subscriber recovers from missed notifications.
- For Roar, use bounded trusted scopes: its Erlang FFI turns them into permanent atoms. Scope membership is not authorization.
- Before promising distributed behavior, verify cleanup, duplicates, disconnects, and reconnects on the chosen pair. Roar's buffered bridge exposes no bridge-cancellation handle; documentation alone cannot establish complete cleanup or exactly-once delivery.

## Red flags

- Roar examples written for a Whisper API other than the resolved one.
- A dropped notification used as the sole record of a required action.
- Buffer capacity presented as a mailbox or system memory bound.
- Topic names treated as authorization or globally checked payload types.
- Uncancelled subscriptions or names reused with stale handles.
- User-created Roar scopes allocating unbounded atoms.
- Exactly-once cluster claims inferred from a local test.

## Sources

[Whisper source](https://github.com/webermarci/whisper), [Roar source](https://github.com/webermarci/roar), [Roar overview](https://hexdocs.pm/roar/).
