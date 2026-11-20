---
name: gleam-lib
description: Design and evolve bounded, composable Gleam libraries. Use for defined scope, composable configuration and operations, sans-I/O, typed ports, ecosystem interoperability, resource ownership, and public compatibility. Package-specific skills guide applications consuming those packages.
---

# Gleam libraries

Extract shared responsibilities and rules into libraries with defined scope and composable public contracts. Keep application-specific sequencing in ordinary modules.

## Governing rule

Compose configuration and usage through simple parts. Expose meaningful choices, derive repeated facts, and keep application policy with the application.

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
- Design the common consumer path first. Minimize concepts, conversions, and hidden call ordering.
- Test depth: removing the abstraction should force callers to reproduce meaningful rules, not rename calls.
- Preserve application-native input, output, and error types. Bind typed operations before hiding heterogeneous parameters; avoid dynamic dispatchers.
- Reuse ecosystem types and public contracts. Let applications translate different vocabularies; ordinary composition must not depend on peer internals.
- Choose targets and runtimes from purpose; verify each promised path and its dependencies. Preserve the different execution models of synchronous BEAM I/O and JavaScript promises.

## Compose configuration and operations

- Use sans-I/O when protocol decisions can be separate from execution: consume values, return decisions or requests, and let callers perform I/O.
- Define ports as narrow typed callbacks or records for caller-supplied capabilities. Supply adapters for concrete integrations; keep core rules independent of those implementations.
- Combine configured values and operations through ordinary functions. Preserve the same contract where meaning permits; avoid global state and mandatory frameworks.

## Expose policy and ownership

- Supply defaults through explicit configuration values and value-first functions. Prefer record updates over a setter per field. Allow independent instances; validate configuration before allocation.
- Require each argument to affect behavior. A bound operation should carry its own name/codecs instead of asking callers to repeat them at every use.
- Give common tasks one obvious path; advanced paths need distinct capabilities.
- Specify who creates, shares, cancels, and closes resources. Enforce allocation limits before allocation; a pull-shaped API alone proves no backpressure. State what returns establish. Callback types cannot prove purity, bounded work, or safe captured state.
- Keep common validation and lifecycle rules in the library when offering extensions. State exactly what an adapter author must supply and which guarantees depend on it.
- Return actionable structured failures. Reserve deliberate crashes for a documented supervision/recovery contract.
- BEAM copies each message and spawned closure in full. Never capture a built codec or large value in a closure your API hands to another process; hold static data in module constants. Test the copy size (`erts_debug:flat_size * wordsize`) of each crossing term; see the [codec guide](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md).

## Verify the public contract

Compile an external consumer using public imports. Exercise ordinary usage, customization, expected failure, and independent instances. Check ownership when composing with another package.

Treat exported constructors, fields, variants, module paths, and behavior as compatibility surface. Check downstream consumers. `internal_modules` marks instability, not access control. Use the package's own namespace.

## Red flags

- A library takes over application policy or forces unrelated capabilities into its scope.
- Builders or extension protocols without distinct use cases.
- A public signature exposes implementation-state type parameters.

## Sources

[Gleam conventions](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/), [multi-target I/O](https://tour.gleam.run/advanced-features/multi-target-externals/), [internal modules](https://gleam.run/documentation/gleam-toml-reference/#internal_modules), [Ousterhout on modular design](https://web.stanford.edu/~ouster/cgi-bin/cs190-winter18/lecture.php?topic=modularDesign).
