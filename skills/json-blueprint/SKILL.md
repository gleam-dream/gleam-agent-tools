---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, generated or combinator codecs, codecs sent between processes, and wire-format migration.
---

# JSON Blueprint

Modern codecs align typed JSON encoding, decoding and schema; `gleam/json` suffices for one-way input. Require Hex `json_blueprint >= 2.2.0`: 1.7.1 lacks modern codecs, and older 2.x codecs copy at many times their size.

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Known input without schema/encoding → gleam/json decoder
├─ Legacy wire format or recursive types → json/blueprint (one-way Decoder)
├─ Typed values ↔ JSON and schema
│  ├─ Fixed shape; codec hot, long-lived or held by other processes
│  │  → typed-definition generator (json/blueprint/codegen)
│  └─ Run-time labels, unions, shared definitions, custom/value/try_map,
│     one-off, or a fixed shape that is neither → codec combinators
├─ Native records from a closed-object schema
│  → schema-driven generator (emits combinator code)
├─ Exact JSON numbers → number API
└─ Runtime schema within the supported profile → contract API
```

## Establish the API and wire contract

- Preserve a 1.x wire contract unless migrating: legacy unions use `type`/`data`, modern ones `tag`/`value`.
- Build records with `field`, `optional_field` and `success`, getters passed with `get:`. Keep callbacks synchronous and pure; schema discovery runs them with placeholders.
- Distinguish omission, null and a value: `optional_field` over `nullable` yields `None`, `Some(None)` and `Some(Some(value))`.
- Check runtime-derived definitions with `codec.check`; duplicate names, repeated labels and invalid bounds otherwise panic when used.
- Return only the tagged values a union's own variants make from its `match`; a value tagged by another union panics when encoded.

## Codecs and processes

The `gleam-otp` skill owns the general rule: a process copy loses sharing, so bound what crosses. For codecs on 2.2.0:

- Each combinator holds its inputs once, so a codec copies at about its in-heap size. A child codec bound with `let` before a `use … <- codec.field` chain, or passed in as a parameter, is fine.
- Build a run-time enum once, before the chain, and run `codec.check` where its labels arrive; an enum built inside its field is rebuilt on every conversion.
- A value used in several places of your own terms is copied once per place. Bound the `erts_debug:flat_size/1` of codec-holding terms sent between processes in an Erlang test, as a ratio to their in-heap size.
- Generated codecs, module functions and literals, copy smaller and convert faster.
- The typed generator lacks `float`, exact `Number` and `number_between`, run-time enums, unions, shared or recursive definitions, aliases, `custom`, `value`, arbitrary `try_map` and `String`-valued enums (use a custom type with `imap`). Its object codecs cannot finish a record continuation.
- Generated modules import `gleam/json`, so declare `gleam_json` directly. Regenerate modules made before 2.2.0: their complete enums warn `Unreachable pattern`.

## Bounds, numbers, and schemas

- Parse untrusted text with `value.default_limits()` and `value.with_max_bytes` (1 MiB default). The application owns depth and count policies.
- `codec.decoder` consumes parsed data; its producer owns duplicate keys, precision and limits.
- Use `number` for exact values; JavaScript `codec.int()` rejects unsafe integers.
- Treat `contract` as a finite Draft 2020-12 profile: no recursive references, untagged unions or patterns.
- Read schemas with `codec.view`, handling `OtherSchema` explicitly.
- Run the included generators from an explicit build task; regenerate, format and compile output on each target.
- Validate legacy schemas with the receiving validator.

## Red flags

- Importing modern modules on published 1.7.1, or changing union envelopes while claiming wire compatibility.
- Effectful codec construction, or placeholder values stored as data.
- Codecs kept across a hot upgrade from 2.1.x, or stored with `term_to_binary`: rebuild them.
- Strict JavaScript parsing without JSON.parse `context.source` support, or Erlang parsing below OTP 27.

## Sources

[Codec practice guide](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md) · [HexDocs](https://hexdocs.pm/json_blueprint/) · [Inspected 2.2.0 source](https://github.com/lostbean/json_blueprint/tree/7ae91d9177c3f2d48cb91e467f641912908da172), [2.0 migration](https://github.com/lostbean/json_blueprint/blob/7ae91d9177c3f2d48cb91e467f641912908da172/docs/MIGRATION.md).
