---
name: gleam-lib
description: Design and evolve bounded, composable Gleam libraries. Use for defined scope, composable configuration and operations, sans-I/O, typed ports, ecosystem interoperability, resource ownership, and public compatibility. Package-specific skills guide applications consuming those packages.
---

# Gleam libraries

Give each library a well-defined scope and a simple, modular public contract that composes with other ecosystem libraries.

## Governing rule

Make configuration and usage composable so callers can assemble complex solutions from simple parts. Expose meaningful choices, derive repeated facts, and keep application policy with the application.

## Abstraction decision tree

```text
What justifies the proposed boundary?
├── One application-specific operation → Ordinary function/module
├── Reusable responsibility with its own invariants → Library boundary
│   ├── Construction can violate an invariant → Opaque type + checked constructor
│   └── Ordinary configuration/data → Public record when useful
├── Caller must choose I/O → Sans-I/O core or narrow typed ports
├── Other concrete variation → Narrow callback or adapter contract
└── No demonstrated variation → Keep the implementation concrete
```

## Design from a consumer

- State the capability, invariant owner, and exclusions. Group code around hidden decisions; file length and execution phases do not determine boundaries.
- Design the common consumer path first. Minimize concepts, conversions, repeated facts, and hidden call ordering.
- Preserve application-native input, output, and error types. Bind typed operations before hiding heterogeneous parameters; avoid dynamic dispatchers.
- Reuse ecosystem types and public contracts. Let applications translate different vocabularies; ordinary composition must not depend on peer internals.
- Choose targets and runtimes from purpose; verify each promised path and its dependencies. Preserve the different execution models of synchronous BEAM I/O and JavaScript promises.

## Compose configuration and operations

- Use sans-I/O when protocol decisions can be separate from execution: consume values, return decisions or requests, and let callers perform I/O and supply results.
- Define ports as narrow typed callbacks or records for caller-supplied capabilities. Supply adapters for concrete integrations; keep core rules independent of those implementations. Add ports for actual variation, not every function.
- Let configured values and operations combine through ordinary typed functions. Reuse a combined operation through the same contract where its meaning permits; avoid hidden global state and mandatory framework adoption.

## Expose policy and ownership

- Compose configuration through explicit values and value-first functions. Allow independent instances; separate validation from resource allocation.
- Require each argument to affect behavior. A bound operation should carry its own name/codecs instead of asking callers to repeat them at every use.
- Give the common task one obvious path. Add an advanced path only for a distinct capability.
- Specify who creates, shares, cancels, and closes resources. State where limits are enforced and what return values establish. A callback type cannot prove purity, bounded work, or safe captured state.
- Keep common validation and lifecycle rules in the library when offering extensions. State exactly what an adapter author must supply and which guarantees depend on that implementation.
- Return actionable structured failures. Reserve deliberate crashes for a documented supervision/recovery contract.

## Verify the public contract

Compile an external consumer using public imports. Exercise ordinary usage, customization, expected failure, and two independent instances where relevant. Check ownership when composing with another package.

Treat exported constructors, fields, variants, module paths, and behavior as compatibility surface. Check downstream consumers. `internal_modules` marks instability, not access control. Use the package's own namespace.

## Red flags

- A library takes over application policy or forces unrelated capabilities into its scope.
- Configuration or usage requires global state, peer internals, or repeated conversion glue.
- The caller repeats facts or imports internals for ordinary work.
- Builders, extension protocols, or constructor families with no distinct use case.
- A public signature exposes implementation-state type parameters.
- Internal tests pass while public constructors or behavior break consumers.

## Sources

[Gleam conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/), [multi-target I/O](https://tour.gleam.run/advanced-features/multi-target-externals/), [internal modules](https://gleam.run/documentation/gleam-toml-reference/#internal_modules), [Ousterhout on modular design](https://web.stanford.edu/~ouster/cgi-bin/cs190-winter18/lecture.php?topic=modularDesign).
