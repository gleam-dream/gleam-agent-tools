---
name: gleam-pubsub
description: Design and debug application notifications with Whisper and Roar. Use for local topics, subscriptions, buffers, callbacks, BEAM cluster distribution, cleanup, and delivery limits.
---

# Gleam pub/sub

Choose notification scope and recovery before connecting publishers and subscribers.

## Abstraction decision tree

```text
What delivery contract does the application require?
├─ Durable receipt, replay, or required command → Durable store/protocol
├─ Diagnostic observation on BEAM → Telemetry
└─ Ephemeral application notification → Choose scope
   ├─ Local Erlang or JavaScript → Whisper
   └─ BEAM cluster → Roar candidate; establish a compatible pair first
```

## Check compatibility before selection

- Inspect the resolved manifest and public API. Both packages are experimental. Roar 0.1.0 uses Whisper's older router API and is source-incompatible with the inspected Whisper 0.2.0 API, despite its permissive dependency range.
- Do not recommend that combined installation or invent a working downgrade. Establish a normally resolved, compiled pair before selecting Roar for a new application.
- Keep old router examples separate from Whisper 0.2 topic examples. In 0.2, `new_topic` returns a checked topic value; `subscribe` and `on` receive that value directly.

## Own topics and subscriptions

- Define one application-owned payload contract per topic name. The BEAM registry is node-wide and the JavaScript registry is module-wide; a topic is not request-private merely because its value is local.
- Keep topic definitions and handles under one owner. `Whisper(a)` does not establish a global schema registry or validate foreign message representations.
- Retain cancellation closures and invoke them when the consumer ends. Close topics only through their owner; normal consumer exit does not guarantee subscription cleanup.
- Distinguish `Message`, `Empty`, and `Closed` in Whisper 0.2 receive results. An empty buffer is not a closed subscription; polling it does not provide backpressure.
- Avoid reusing a closed topic name while stale handles remain. Topic handles address names; an old handle can address a replacement. In the inspected JavaScript implementation, old subscription closures can also affect replacement subscribers.

## Bound work and preserve recovery

- Set buffer capacity from expected bursts and acceptable loss. Old messages are dropped when a subscription fills; this bounds that buffer, not all mailboxes or total application memory.
- Keep callbacks short and failure-aware. Whisper's JavaScript callbacks execute inside `publish`; BEAM callbacks execute inside the topic server. Blocking and exceptions affect those owners and can disrupt delivery.
- Check BEAM startup ownership. The inspected registry and topics start linked; do not assume an independently supervised service or isolated callback crashes.
- Treat `publish` returning as notification submission, without a durable receipt. Keep authoritative state elsewhere and define how a subscriber recovers from missed notifications.
- For Roar, use bounded trusted scopes: its Erlang FFI turns them into permanent atoms. Scope membership is not authorization.
- Before promising distributed behavior, verify cleanup, duplicates, disconnects, and reconnects on the chosen pair. The inspected buffered bridge has no exposed bridge-cancellation handle; documentation alone cannot establish complete cleanup or exactly-once delivery.

## Red flags

- Roar 0.1 examples compiled against Whisper 0.2.
- A dropped notification used as the sole record of a required action.
- Buffer capacity presented as a mailbox or system memory bound.
- Topic names treated as authorization or globally checked payload types.
- Uncancelled subscriptions or names reused with stale handles.
- User-created Roar scopes allocating unbounded atoms.
- Exactly-once cluster claims inferred from a local test.

## Sources

[Whisper source](https://github.com/webermarci/whisper/tree/d98a7fa9ded4f58706f767c519a1db3a099e76bc), [Roar source](https://github.com/webermarci/roar/tree/4852f5396459f93b389f8663538558301a4b0595), [Roar overview](https://hexdocs.pm/roar/).
