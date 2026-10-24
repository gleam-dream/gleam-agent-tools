---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, generation, and wire-format migration.
---

# JSON Blueprint

Choose a modern Blueprint codec when one native type and definition should keep JSON encoding, decoding, and schema aligned. An ordinary `gleam/json` decoder suffices for one-way input without a schema. Check installed source before choosing imports: published 1.7.1 lacks the checkout's modern codec API despite the same version field.

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Decode known input without schema/encoding → Existing gleam/json decoder
├─ Existing legacy wire format or recursive decoding → json/blueprint
│  └─ Legacy Decoder is one-way; encoding uses separate helpers
├─ Typed values ↔ JSON and schema → json/blueprint/codec, unreleased source
├─ Exact JSON numbers → Modern number API
├─ Runtime schema within supported profile → Modern contract API
└─ Generated native types → Separate development-time generator
```

## Establish the API and wire contract

- Inspect the dependency source, revision, and imports. The researched checkout still declares 1.7.1 but contains unreleased work toward 2.0. Installing published 1.7.1 does not supply that modern codec API.
- Preserve an existing 1.x wire contract unless migration is intended. Legacy unions use `type`/`data` and enums use `enum`; modern unions use `tag`/`value`, with tag-only unit variants.
- Use modern `field`, `optional_field`, and `success` for records; pass getters with `get:`. Keep callbacks synchronous and pure: schema description evaluates construction with placeholders. Perform I/O outside codecs; callback types enforce neither purity nor resource lifetime.
- Distinguish omission, null, and a value. `optional_field` accepts absence and delegates present values to its inner codec. For a non-null inner codec, wrapping it in `nullable` preserves all three as `None`, `Some(None)`, and `Some(Some(value))`.
- Expect built-in modern record codecs to reject undeclared fields. Strict text decoding also rejects duplicate keys and wrong types; treat those failures as boundary decisions.
- Check runtime-derived definitions with `codec.check`. Static duplicate field names, repeated enum labels, and invalid bounds are definition errors that otherwise panic when used.
- Keep domain validation in pure Gleam `try_map` or conversion functions. Schema metadata cannot express every predicate performed by custom callbacks.

## Bounds, numbers, and schemas

- Parse untrusted text with explicit limits. Modern defaults bound UTF-8 text to 1 MiB, depth to 64, and values to 262,144, with separate number limits. Raising one does not raise the others or bound heap allocation.
- Remember parser ownership at bridges. `codec.decoder` consumes already parsed data; its producer owns duplicate keys, numeric precision, and resource limits. `contract.validate` adds no independent parse bound.
- Use `number` for exact large values and checked native conversions. JavaScript `codec.int()` rejects integers outside its safe range; a `Float` round trip cannot preserve arbitrary JSON numbers.
- Treat `contract` as a finite Draft 2020-12 profile. Modern runtime contracts exclude recursive references, untagged unions, and string patterns; a dialect label cannot admit arbitrary schemas.
- Inspect opaque schemas with `codec.view` and decide explicitly about `OtherSchema`. Preserve unknown supported documents only where the receiving protocol accepts them.
- Keep source generation a development dependency. Check generated code against the selected runtime; generated native decoders and strict parsers have different limits.
- Validate legacy schemas with the actual receiving validator. The legacy renderer labels Draft-07 while using some later keywords.

## Red flags

- Importing modern modules after installing published 1.7.1.
- Changing union envelopes while claiming wire compatibility.
- Collapsing omitted and null fields accidentally.
- Effectful codec construction or placeholder values stored as data.
- Assuming a JSON bridge preserves exact numbers or strict parser guarantees.
- Accepting arbitrary JSON Schema because it says Draft 2020-12.
- Raising only the byte limit for a deeply nested document.

## Sources

[Inspected runtime, examples, and design](https://github.com/lostbean/json_blueprint/tree/45b361628af9d464a1670e8789b82a4dc310604f), [published package](https://hex.pm/packages/json_blueprint), [published API](https://hexdocs.pm/json_blueprint/1.7.1/).
