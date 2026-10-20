---
name: gleam
description: Write and refactor idiomatic Gleam functions, types, and modules. Use for pattern matching, Result handling, decoding, control flow, module organization, dependencies, and project verification. Use gleam-lib for reusable public APIs and gleam-ffi for foreign implementations.
---

# Gleam

Preserve caller-visible behavior while making domain decisions explicit in types and functions.

## Governing rule

Use ordinary values and functions until a concrete requirement justifies another abstraction. A module boundary does not require a process.

## Abstraction decision tree

```text
What needs representing?
├── Known alternatives → Custom type and exhaustive case
├── Fallible operation → Result(value, error)
├── Genuine absence in data → Option(value)
├── Untyped external data → Decode into a domain value
└── Runtime coordination or lifetime → Choose a process with gleam-otp
```

## Write the boundary first

- Inspect `gleam.toml`, `manifest.toml`, repository instructions, and the selected compiler. Read the resolved dependency's public API before using a remembered function. A nearby checkout can differ from the consumer's lock.
- Annotate every module function's arguments and return type, including private functions. Qualify imported functions and constants through their module.
- Use `snake_case` names and `PascalCase` types/variants. Use singular module segments, treat acronyms as words, and name fallible operations for their action; reserve `try_` for a distinct error-propagating counterpart.
- Return expected failures through `Result`. Reserve `Option` for absence. Preserve omitted values, explicit false, empty values, and failures when they have different meanings.
- Prefer a custom type when a boolean or optional fields conceal mutually exclusive states. Use checked constructors and opacity for actual invariants; types alone do not validate foreign data or concurrent history.

## Keep the operation readable

- Match once instead of checking a predicate and asserting the same shape. Name known variants when a new variant should force a new decision.
- Use multi-subject `case` for related alternatives. Pipe value-first transformations; use `use` when its callback scope makes a chain clearer. It is callback syntax, not an early-return mechanism.
- Reuse compatible core types and packages. Keep a coherent domain API together; split modules when responsibilities change independently.
- Preserve observable errors, ordering, and effects during refactoring. A shorter expression is an improvement only when those behaviors survive.
- Put shipped code in `src/`, tests in `test/`, and development helpers in `dev/`. Keep static development-tool configuration under `tools.<name>` in `gleam.toml` when the tool supports it.

## Verification

Use the project's existing checks and toolchain. Format changed Gleam files, build with warnings treated as errors, and run relevant behavior tests. Inspect the test entry point: `gleam test` invokes that module's `main`.

Check each supported target/runtime affected by the change. JavaScript compilation or Node success does not establish browser compatibility. Report commands actually run and any remaining failures.

## Red flags

- Catch-all branches silently accepting new domain variants.
- `panic` or `let assert` handling routine external failure in a library.
- New processes, modules, or generic machinery added only for organization.
- Replacing a shared ecosystem type with an incompatible local equivalent.
- Passing tests that never invoke the changed behavior.

## Sources

[Gleam conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/), [use expressions](https://tour.gleam.run/advanced-features/use/), [project configuration](https://gleam.run/documentation/gleam-toml-reference/), [CLI](https://gleam.run/documentation/command-line-reference/).
