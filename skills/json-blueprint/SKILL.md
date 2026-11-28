---
name: json-blueprint
description: Define JSON codecs and schema contracts with JSON Blueprint. Use for bidirectional encoding, strict decoding, optional fields, exact numbers, runtime schema validation, generated or combinator codecs, codecs sent between processes, and wire-format migration.
metadata:
  library: gleam-dream/json_blueprint
  library-ref: ad73271fb49b6fb075b8695299138f59c59ed7b6
  not-in-library: context.source
---

# JSON Blueprint

Modern codecs align typed JSON encoding, decoding and schema; `gleam/json` suffices for one-way input. Add the latest `json_blueprint` release (`gleam add json_blueprint`).

## Abstraction decision tree

```text
What JSON boundary does the application need?
├─ Known input without schema/encoding → gleam/json decoder
├─ Recursive types → value.parse, then walk the Value
├─ Typed values ↔ JSON and schema
│  ├─ Fixed shape the generator supports; codec hot, long-lived
│  │  or held by other processes → json/blueprint/codegen
│  └─ Otherwise (run-time labels, unions, a generator gap, one-off)
│     → json/blueprint/codec combinators
├─ Native records from a closed-object schema
│  → schema-driven generator (emits combinator code)
├─ Exact JSON numbers → number API
└─ Runtime schema within the supported profile → contract API
```

## Establish the API and wire contract

- Codecs write unions as `tag`, plus `value` for a payload variant, and enums as bare strings. Read legacy envelopes (`type`/`data`, `{"enum": …}`) from stored data or peers with an application reader, or migrate both before switching writers.
- Build records with `field`, `optional_field` and `success`, getters passed with `get:`. Keep callbacks synchronous and pure; schema discovery runs them with placeholders.
- Distinguish omission, null and a value: `optional_field` over `nullable` yields `None`, `Some(None)` and `Some(Some(value))`.
- Check runtime-derived definitions with `codec.check`; duplicate names, repeated labels and invalid bounds otherwise panic when used.
- Return only the tagged values a union's own variants make from its `match`; a value tagged by another union panics when encoded.

## Codecs and processes

The `gleam-otp` skill owns the general rule: a process copy loses sharing, so bound what crosses. For codecs:

- Each combinator holds its inputs once, so a codec copies at about its in-heap size. A child codec bound with `let` before a `use … <- codec.field` chain, or passed in as a parameter, is fine.
- Build a run-time enum once, before the chain, and run `codec.check` where its labels arrive; an enum built inside its field is rebuilt on every conversion.
- A value used in several places of your own terms is copied once per place. Bound the `erts_debug:flat_size/1` of codec-holding terms sent between processes in an Erlang test, as a ratio to their in-heap size.
- Generated codecs, module functions and literals, copy smaller and convert faster.
- The typed generator lacks `float`, exact `Number` and `number_between`, run-time enums, unions, shared or recursive definitions, aliases, `custom`, `value`, arbitrary `try_map` and `String`-valued enums (use a custom type with `imap`). Its object codecs cannot finish a record continuation.
- Generated modules import `gleam/json`, so declare `gleam_json` directly. Their `decode_<name>_json` uses the strict parser and its limits.

## Bounds, numbers, and schemas

- Parse untrusted text within `value.default_limits()`: 1 MiB and 128 nesting levels. Change one bound with `value.with_max_bytes` or `value.with_max_depth`; handle `DepthLimitExceeded`. The application owns count policy.
- `codec.decoder` consumes parsed data; its producer owns duplicate keys, precision and limits.
- Use `number` for exact values; JavaScript `codec.int()` rejects unsafe integers.
- Treat `contract` as a finite Draft 2020-12 profile: annotation keywords load and are ignored; `$ref`, `$defs`, `format`, `pattern` and untagged unions are refused. Build `contract.decoder` once for many validated values.
- Read schemas with `codec.view`, handling `OtherSchema`.
- Run the included generators from an explicit build task; regenerate, format and compile output on each target.

## Red flags

- Changing union envelopes while claiming wire compatibility.
- Effectful codec construction, or placeholder values stored as data.
- Codecs kept across a hot code upgrade or stored with `term_to_binary`: rebuild them.
- Strict parsing without native parser hooks: JavaScript `JSON.parse` `context.source`, or Erlang's `json` module.

## Sources

[Codec practice guide](https://github.com/gleam-dream/json_blueprint/blob/main/docs/CODEC-PRACTICE.md) · [HexDocs](https://hexdocs.pm/json_blueprint/) · [Source](https://github.com/gleam-dream/json_blueprint), [wire-format migration](https://github.com/gleam-dream/json_blueprint/blob/main/docs/MIGRATION.md).
