---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, generation, and wire-format migration.
---

# JSON Blueprint

Choose a modern Blueprint codec when one native type and definition should keep JSON encoding, decoding, and schema aligned. An ordinary `gleam/json` decoder suffices for one-way input without a schema. Check installed source before choosing imports: published 1.7.1 provides the legacy API, while the 2.0 package also includes modern codecs, contracts, and generators.

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Decode known input without schema/encoding → Existing gleam/json decoder
├─ Existing legacy wire format or recursive decoding → json/blueprint
│  └─ Legacy Decoder is one-way; encoding uses separate helpers
├─ Typed values ↔ JSON and schema → json/blueprint/codec in 2.0
├─ Exact JSON numbers → Modern number API
├─ Runtime schema within supported profile → Modern contract API
└─ Generated native types → Included generator invoked by an explicit build task
```

## Establish the API and wire contract

- Inspect the dependency source, revision, and imports. The release candidate declares 2.0.0. Installing published 1.7.1 does not supply the modern codec API; use a selected Git revision while the required 2.x release is unpublished.
- Preserve an existing 1.x wire contract unless migration is intended. Legacy unions use `type`/`data` and enums use `enum`; modern unions use `tag`/`value`, with tag-only unit variants.
- Use modern `field`, `optional_field`, and `success` for records; pass getters with `get:`. Keep callbacks synchronous and pure: schema discovery may evaluate construction with placeholders, while cached metadata and generated paths can change callback counts. Perform I/O outside codecs; callback types enforce neither purity nor resource lifetime.
- Distinguish omission, null, and a value. `optional_field` accepts absence and delegates present values to its inner codec. For a non-null inner codec, wrapping it in `nullable` preserves all three as `None`, `Some(None)`, and `Some(Some(value))`.
- Expect built-in modern record codecs to reject undeclared fields. Strict text decoding also rejects duplicate keys and wrong types; treat those failures as boundary decisions.
- Check runtime-derived definitions with `codec.check`. Static duplicate field names, repeated enum labels, and invalid bounds are definition errors that otherwise panic when used.
- Keep domain validation in pure Gleam `try_map` or conversion functions. Schema metadata cannot express every predicate performed by custom callbacks.

## Bounds, numbers, and schemas

- Parse untrusted text with explicit limits. Modern defaults bound UTF-8 text to 1 MiB through `value.default_limits()` and `value.with_max_bytes`. Global depth, value-count and numeric-token limits and their setters have been removed; enforce required structural policies in the application. The byte bound is not a heap allocation quota.
- Remember parser ownership at bridges. `codec.decoder` consumes already parsed data; its producer owns duplicate keys, numeric precision, and resource limits. `contract.validate` adds no independent parse bound.
- Use `number` for exact large values and checked native conversions. JavaScript `codec.int()` rejects integers outside its safe range; a `Float` round trip cannot preserve arbitrary JSON numbers.
- Treat `contract` as a finite Draft 2020-12 profile. Modern runtime contracts exclude recursive references, untagged unions, and string patterns; a dialect label cannot admit arbitrary schemas.
- Inspect opaque schemas with `codec.view` and decide explicitly about `OtherSchema`. Preserve unknown supported documents only where the receiving protocol accepts them.
- Use the included `json/blueprint/codegen` and `json/blueprint/codegen/schema` modules from an explicit build task. Remove the separate unpublished generator dependency. Regenerate, format and compile output against the selected runtime on each intended target; strict and standard-native entry points retain distinct admission contracts.
- Validate legacy schemas with the actual receiving validator. The legacy renderer labels Draft-07 while using some later keywords.

## Red flags

- Importing modern modules after installing published 1.7.1.
- Changing union envelopes while claiming wire compatibility.
- Collapsing omitted and null fields accidentally.
- Effectful codec construction or placeholder values stored as data.
- Assuming a JSON bridge preserves exact numbers or strict parser guarantees.
- Accepting arbitrary JSON Schema because it says Draft 2020-12.
- Assuming a byte limit also establishes a depth, element-count or heap bound.
- Using strict JavaScript parsing without JSON.parse reviver `context.source` support, or Erlang parsing below OTP 27.

## Sources

[Inspected runtime, examples, and design](https://github.com/lostbean/json_blueprint/tree/e8955222b7bf123d808ea1497cd3bbec98e22923), [published package](https://hex.pm/packages/json_blueprint), [published legacy API](https://hexdocs.pm/json_blueprint/1.7.1/), [2.0 migration and runtime requirements](https://github.com/lostbean/json_blueprint/blob/e8955222b7bf123d808ea1497cd3bbec98e22923/docs/MIGRATION.md).
