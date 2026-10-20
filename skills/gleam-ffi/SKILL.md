---
name: gleam-ffi
description: Design and debug thin, narrowly scoped Gleam interfaces to Erlang, Elixir, and JavaScript. Use for typed composable entry points, foreign representations, promises, exceptions, handles, and cleanup. Keep domain logic and workflow policy in Gleam.
---

# Gleam FFI

Expose narrow external capabilities through thin, type-sound, composable Gleam entry points. Keep the logic that combines them in Gleam.

## Governing rule

Limit FFI to required native calls, representation conversion, and necessary runtime mechanics. Put domain validation, decisions, state transitions, and workflow policy in checked Gleam. A typed wrapper around a foreign workflow does not establish this boundary.

## Abstraction decision tree

```text
Why does this operation need foreign code?
├── Existing suitable typed dependency → Use its public contract
├── Runtime/platform access or required foreign library → Thin wrapper for one narrow capability
├── Claimed performance benefit → Measure first; keep the native boundary narrow
└── Domain validation, branching, or state transitions → Implement in Gleam
```

## Trace the whole operation

- Inspect the declaration, implementation, callers, resolved dependency, compiler, and supported runtimes. Confirm the foreign module/export actually exists.
- Locate validation, state transitions, sequencing, retries, cancellation, persistence, and recovery decisions. A wrapper around a foreign workflow leaves those decisions foreign.
- Expose small typed operations that compose in Gleam. Keep only necessary native sequencing and resource mechanics foreign; move domain logic and workflow orchestration into Gleam. Judge the boundary by its responsibility, not the number of externals.

## Represent the actual values

- An external declaration is a promise the compiler cannot verify. Check that the implementation honors its representation, failure, and lifetime contract through the public Gleam API.
- Use narrow accepted input types and specific foreign handle types. Use `Dynamic` for genuinely untyped ingress and decode before domain logic. Avoid generic returns that conceal an unchecked cast.
- Match the selected compiler's documented Erlang/Elixir/JavaScript representations. Construct actual Gleam `Result`, list, and variant values through the supported interop API; native lookalikes are insufficient.
- Map expected native failures to the declared failure value. Preserve unexpected failure evidence and verify exception behavior instead of assuming Gleam will catch a foreign exception.
- Model a JavaScript Promise or callback explicitly. An `async` export declared to return `Int` still returns a Promise; Gleam does not implicitly await it.
- Account for numeric representation differences. JavaScript integers beyond its safe range can lose distinctions that BEAM integers retain. Choose an explicit range or wire representation for exact domains.

## Own the lifetime

- State the owner of each handle, callback registration, connection, and buffer. Specify callback execution context, cancellation, cleanup, and whether callbacks can arrive after cancellation.
- Keep return timing honest: starting an operation, receiving a response, and committing application state are different boundaries.
- Scope target-only declarations appropriately. For multi-target externals or a Gleam fallback, verify the implementation selected on each supported target. Node and browser APIs require separate runtime checks.
- Use documented interop helpers instead of inspecting generated variant internals. Resolve prelude imports relative to the foreign file's generated location.

## Verification

Use a focused public-API probe for the claim in question: success, expected failure, malformed return, promise completion, callback ordering, or resource cleanup. Compilation checks the declaration's use; runtime evidence checks its implementation. A source-reading claim and an executed observation are different evidence.

## Red flags

- A native value merely declared to be a checked domain value.
- `Dynamic` or a type variable used to accept every possible handle.
- A thin-looking wrapper delegates domain logic or an entire workflow to foreign code.
- Cancellation or timeout interpreted as proof that an effect never happened.
- A platform port claimed from compilation alone.

## Sources

[Externals and runtime representations](https://gleam.run/documentation/externals/), [multi-target externals](https://tour.gleam.run/advanced-features/multi-target-externals/), [compatibility](https://gleam.run/documentation/compatibility-reference/).
