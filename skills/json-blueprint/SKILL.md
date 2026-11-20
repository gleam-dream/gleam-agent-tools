---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, choosing generated or combinator codecs, codecs sent between processes, and wire-format migration.
---

# JSON Blueprint

Modern codecs align typed JSON encoding, decoding and schema. `gleam/json` suffices for one-way input. 2.x includes legacy decoders, modern codecs, contracts and generators. The [codec practice guide](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md) is the canonical source for choosing and writing codecs.

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Decode known input without schema/encoding → Existing gleam/json decoder
├─ Existing legacy wire format or recursive decoding → json/blueprint
│  └─ Legacy Decoder is one-way; encoding uses separate helpers
├─ Typed values ↔ JSON and schema
│  ├─ Shape fixed at build time; hot, long-lived or crossing processes
│  │  (stored, queued, API or decision payloads) → typed-definition generator
│  └─ Run-time labels, unions, shared or recursive definitions,
│     custom/value/try_map, or one-off → json/blueprint/codec combinators
├─ Exact JSON numbers → Modern number API
├─ Runtime schema within supported profile → Modern contract API
└─ Generated native types → Included generator invoked by an explicit build task
```

## Establish the API and wire contract

- Require Hex `json_blueprint >= 2.1.1` and inspect resolved imports; 1.7.1 lacks modern codecs, and 2.1.0 or earlier multiplies a nested codec's copy size per layer.
- Preserve an existing 1.x wire contract unless migration is intended. Legacy unions use `type`/`data` and enums use `enum`; modern unions use `tag`/`value`, with tag-only unit variants.
- Use modern `field`, `optional_field`, and `success` for records; pass getters with `get:`. Keep callbacks synchronous and pure: schema discovery may evaluate construction with placeholders, while cached metadata and generated paths can change callback counts. Perform I/O outside codecs; callback types enforce neither purity nor resource lifetime.
- Distinguish omission, null, and a value. `optional_field` accepts absence and delegates present values to its inner codec. For a non-null inner codec, wrapping it in `nullable` preserves all three as `None`, `Some(None)`, and `Some(Some(value))`.
- Expect built-in modern record codecs to reject undeclared fields. Strict text decoding also rejects duplicate keys and wrong types; treat those failures as boundary decisions.
- Check runtime-derived definitions with `codec.check`. Static duplicate field names, repeated enum labels, and invalid bounds are definition errors that otherwise panic when used.
- Keep domain validation in pure Gleam `try_map` or conversion functions. Schema metadata cannot express every predicate performed by custom callbacks.

## Codecs and processes

A process copy (message, spawn argument, child specification) does not preserve sharing; a term costs its flat size to send.

- Generate fixed-shape payload codecs with `json/blueprint/codegen`: module functions and literals are not copied between processes and convert faster.
- In combinators, build each child codec in its field, directly or through a function call there. Never `let`-bind a child codec or other large value before a `use … <- codec.field` chain for a later field; each continuation captures it.
- For run-time enums, capture the label pairs and call `codec.string_enum` inside the field; run `codec.check` where the labels arrive.
- Send builder inputs, not built codecs or agents, tools and servers holding them, to other processes per operation.
- Bound the `erts_debug:flat_size/1` of every term sent to another process in an Erlang test.
- Check the guide's generator gaps first. Generated modules import `gleam/json`, so declare `gleam_json` directly; up to 2.1.1 a complete generated enum warns `Unreachable pattern`.

## Bounds, numbers, and schemas

- Parse untrusted text with `value.default_limits()` and `value.with_max_bytes` (default 1 MiB UTF-8). Depth, value-count and numeric-token setters are removed; enforce structural policies in the application. The byte bound is not a heap quota.
- Remember parser ownership at bridges. `codec.decoder` consumes already parsed data; its producer owns duplicate keys, numeric precision, and resource limits. `contract.validate` adds no independent parse bound.
- Use `number` for exact large values and checked native conversions. JavaScript `codec.int()` rejects integers outside its safe range; a `Float` round trip cannot preserve arbitrary JSON numbers.
- Treat `contract` as a finite Draft 2020-12 profile. Modern runtime contracts exclude recursive references, untagged unions, and string patterns; a dialect label cannot admit arbitrary schemas.
- Inspect opaque schemas with `codec.view` and decide explicitly about `OtherSchema`. Preserve unknown supported documents only where the receiving protocol accepts them.
- Use the included `json/blueprint/codegen` and `json/blueprint/codegen/schema` modules from an explicit build task. Remove any separate generator dependency. Regenerate, format and compile output against the selected runtime on each intended target; strict and standard-native entry points retain distinct admission contracts.
- Validate legacy schemas with the actual receiving validator. The legacy renderer labels Draft-07 while using some later keywords.

## Red flags

- Importing modern modules after installing published 1.7.1.
- Changing union envelopes while claiming wire compatibility.
- Collapsing omitted and null fields accidentally.
- Effectful codec construction or placeholder values stored as data.
- A child codec or a prebuilt enum bound with `let` before a `use … <- codec.field` chain and used by a later field.
- Codecs, or values holding them, sent to other processes without a copy-size test.
- Assuming a JSON bridge preserves exact numbers or strict parser guarantees.
- Accepting arbitrary JSON Schema because it says Draft 2020-12.
- Assuming a byte limit also establishes a depth, element-count or heap bound.
- Using strict JavaScript parsing without JSON.parse reviver `context.source` support, or Erlang parsing below OTP 27.

## Sources

[Codec practice guide](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md) · [HexDocs](https://hexdocs.pm/json_blueprint/) · [Inspected runtime, examples, and design](https://github.com/lostbean/json_blueprint/tree/632f569623a6c47608d2d4c2449f48cce3bfc8d9), [published package](https://hex.pm/packages/json_blueprint), [published legacy API](https://hexdocs.pm/json_blueprint/1.7.1/), [2.0 migration and runtime requirements](https://github.com/lostbean/json_blueprint/blob/632f569623a6c47608d2d4c2449f48cce3bfc8d9/docs/MIGRATION.md).
