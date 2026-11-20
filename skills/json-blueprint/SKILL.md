---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, generated or combinator codecs, codecs sent between processes, and wire-format migration.
---

# JSON Blueprint

Modern codecs align typed JSON encoding, decoding and schema; `gleam/json` suffices for one-way input. Require Hex `json_blueprint >= 2.1.1`: 1.7.1 lacks modern codecs; 2.0–2.1.0 multiply nested codecs' copy size.

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Known input without schema/encoding → gleam/json decoder
├─ Legacy wire format or recursive decoding → json/blueprint (one-way Decoder)
├─ Typed values ↔ JSON and schema
│  ├─ Fixed shape; codec hot, long-lived or held by other processes
│  │  → typed-definition generator (json/blueprint/codegen)
│  └─ Run-time labels, unions, recursion, custom/value/try_map, one-off
│     → json/blueprint/codec combinators
├─ Native records from a closed-object schema
│  → schema-driven generator (emits combinator code)
├─ Exact JSON numbers → number API
└─ Runtime schema within the supported profile → contract API
```

## Establish the API and wire contract

- Preserve a 1.x wire contract unless migrating: legacy unions use `type`/`data`, modern ones `tag`/`value`.
- Build records with `field`, `optional_field` and `success`, getters passed with `get:`. Keep callbacks synchronous and pure; schema discovery runs them with placeholders.
- Distinguish omission, null and a value: `optional_field` over `nullable` yields `None`, `Some(None)` and `Some(Some(value))`.
- Expect records to reject undeclared fields, and strict text decoding duplicate keys.
- Check runtime-derived definitions with `codec.check`; duplicate names, repeated labels and invalid bounds otherwise panic when used.
- Keep domain validation in pure `try_map` functions; schemas cannot express every predicate.

## Codecs and processes

A process copy does not preserve sharing, so codecs, and values holding them, cost their flat size to send. Sending decoded data is unaffected.

- In combinators, build each child codec in its field, directly or by calling a function there. Never `let`-bind a child codec or other large value before a `use … <- codec.field` chain for a later field; every continuation captures it.
- For run-time enums, capture the label pairs and call `codec.string_enum` inside the field.
- Send builder inputs, not combinator codecs or agents and tools holding them, to other processes per operation; generated codecs are cheap to send.
- Bound the `erts_debug:flat_size/1` of codec-holding terms sent between processes in an Erlang test.
- The typed generator lacks `float`, exact `Number` and `number_between`, run-time enums, unions, shared or recursive definitions, aliases, `custom`, `value`, arbitrary `try_map` and `String`-valued enums (use a custom type with `imap`). Its object codecs cannot finish a record continuation.
- Generated modules import `gleam/json`, so declare `gleam_json` directly. Up to 2.1.1, an enum naming every constructor warns `Unreachable pattern` and fails `--warnings-as-errors`.

## Bounds, numbers, and schemas

- Parse untrusted text with `value.default_limits()` and `value.with_max_bytes` (1 MiB default). Enforce depth and count policies in the application; the byte bound is not a heap quota.
- `codec.decoder` consumes parsed data; its producer owns duplicate keys, precision and limits.
- Use `number` for exact values; JavaScript `codec.int()` rejects unsafe integers.
- Treat `contract` as a finite Draft 2020-12 profile: no recursive references, untagged unions or patterns.
- Read schemas with `codec.view`, handling `OtherSchema` explicitly.
- Run the included generators from an explicit build task; regenerate, format and compile output on each target.
- Validate legacy schemas with the receiving validator; they mix Draft-07 and later keywords.

## Red flags

- Importing modern modules on published 1.7.1, or changing union envelopes while claiming wire compatibility.
- Effectful codec construction, or placeholder values stored as data.
- Assuming a JSON bridge keeps strict parser guarantees, or a byte limit bounds depth.
- Accepting arbitrary JSON Schema because it says Draft 2020-12.
- Strict JavaScript parsing without JSON.parse `context.source` support, or Erlang parsing below OTP 27.

## Sources

[Codec practice guide](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md) · [HexDocs](https://hexdocs.pm/json_blueprint/) · [Inspected 2.1.1 source](https://github.com/lostbean/json_blueprint/tree/323f133ebe4c82eb753e77a5e3ceba11339c2134), [2.0 migration](https://github.com/lostbean/json_blueprint/blob/323f133ebe4c82eb753e77a5e3ceba11339c2134/docs/MIGRATION.md).
