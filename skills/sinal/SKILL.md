---
name: sinal
description: Instrument Gleam applications with Sinal telemetry. Use for typed events, native telemetry interoperability, handler lifetime, spans, correlation, bounded forwarding, and observation overhead.
---

# Sinal

Choose Sinal to emit typed observations independently of optional consumers. A library describes what happened; the application attaches metrics, logging, an exporter, or nothing. Native BEAM telemetry interoperability avoids coupling producers to an exporter or JSON format.

Use a direct protocol when another component must act successfully, ordinary logs for a single diagnostic, pub/sub for application notifications, and durable work for required execution.

## Abstraction decision tree

```text
What must the event accomplish?
├─ Required application delivery → Give that protocol its own owner
└─ Diagnostic observation on BEAM → Sinal
   ├─ Small synchronous handler → observe or attach
   ├─ Temporary registrations → with_subscriptions
   ├─ Measure one call → span
   └─ Isolate handler work → Supervised bounded forwarder
```

## Define and observe

- Check the resolved source. Use Hex `sinal` 0.1.0 on Erlang with Gleam >=1.18 and native telemetry >=1.4.2 and <2.
- Define one event name with separate measurement and metadata codecs; reuse that definition in emitters and observers. Compose record fields through `fields.include` and `fields.success`.
- Keep custom getters/encoders total: they run in the producer and can raise before dispatch, even without observers or with forwarding. Optional observation does not make encoding infallible.
- Write event names, field keys, and route prefixes in trusted source. They create permanent atoms. Put request IDs and other unbounded values in metadata values.
- Choose `observe` for an infallible handler, or `subscription`/`handler` plus `attach` for a registration plan. Retain attachments and detach them; use subscription scopes for temporary work.
- Allocate stable handler IDs deliberately. Registrations are node-local; a copied old attachment can address a replacement that reuses its ID.
- Keep unrouted handlers short. They execute synchronously in the emitting process; handler order is unspecified. Callback I/O becomes emitter latency.
- Check enum field codecs against every constructor; an exhaustive naming function does not prove the supplied list is complete.
- Distinguish malformed foreign maps from callback failure. Malformed data skips that occurrence and normally preserves registration; a callback error or catchable exception removes the handler through native telemetry.

## Forwarding and spans

- Let the application supervise a forwarder and install routes at startup. Routes are node-global setup policy; changing them per request is unsuitable.
- Budget capacity for queued plus executing events. A full or unavailable forwarder drops and counts the event, with no inline fallback or retry. Shutdown does not drain.
- Forwarding isolates handler work; it supplies neither whole-application memory bounds nor producer backpressure.
- Treat forwarder acceptance and drop reports as best-effort diagnostics, never a durable receipt. Required commands and business outcomes need another authority.
- Carry context in event metadata. Forwarded handlers execute in the forwarder; producer process-dictionary context is absent. Per-producer FIFO does not establish global ordering.
- Keep spans around one local call. Spans bypass forwarding routes; a returned business `Error` is normal completion, while a raised call emits exception and re-raises.
- Convert native durations with explicit units. Use correlation to join observations; correlation alone supplies neither trace parentage nor authorization.

## Red flags

- Event names or field keys derived from user input.
- Database writes or network calls in a handler on a hot path.
- Assuming every skipped event means the handler detached.
- Leaking attachments after tests or request scopes.
- Treating forwarding as lossless delivery or shutdown draining.
- Relying on the emitter's process identity after forwarding.
- Using telemetry to decide whether a business commit happened.

## Sources

[HexDocs](https://hexdocs.pm/sinal/0.1.0/) · [Sinal public API and consumer examples](https://github.com/gleam-dream/sinal/tree/3b66f83855a3ce4e0979b3045dbd26888aea5065), [forwarder contract](https://github.com/gleam-dream/sinal/blob/3b66f83855a3ce4e0979b3045dbd26888aea5065/src/sinal/forwarder.gleam), [native telemetry](https://telemetry.hexdocs.pm/1.4.2/telemetry.html).
