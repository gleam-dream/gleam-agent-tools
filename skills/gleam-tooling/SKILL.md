---
name: gleam-tooling
description: Resolve Gleam compiler, dependency, and language-server behavior through the project's toolchain. Use for Git or path dependencies, upgrades, signature-first development, semantic navigation, code actions, and refactoring tools.
---

# Gleam tooling

Use compiler and dependency evidence when a remembered API or text search cannot answer a type, reference, or compatibility question. Reuse the project's compiler and existing language-server connection; ordinary edits need no new tooling infrastructure.

## Abstraction decision tree

```text
What evidence is needed?
├── Resolved package or compiler behavior → Project compiler, manifest, and source
├── Unpublished dependency → Git dependency pinned to a commit
├── Packages under active joint development → Local path dependency
├── Types, references, rename, or code actions → Existing Gleam LSP connection
└── Build or behavioral acceptance → Repository gate, independent of LSP
```

## Establish the actual toolchain

- Read repository instructions, `gleam.toml`, and `manifest.toml`. Run `gleam --version` through the declared environment. Use that compiler for formatting, checking, and `gleam lsp`; do not substitute a global installation.
- Inspect resolved packages with `gleam deps list` and their public source. Match documentation to the resolved version; a nearby checkout or current website can describe a different API.
- Choose targets and runtimes from purpose. A language-server diagnostic does not establish browser, native dependency, or deployed compatibility.

## Choose and change dependencies

- Keep a suitable existing dependency. For a new candidate, compare behavior, target support, maintenance, licence, and dependency cost within the host's authorization.
- Use Hex constraints for published packages. Use `{ git = "https://github.com/owner/package.git", ref = "FULL_COMMIT_SHA" }` for a Git dependency; add `path = "packages/adapter"` for a package in a subdirectory. Publication and manual checkout bootstrap are unnecessary for consumption.
- Use `{ path = "../package" }` while developing packages together. Do not confuse a local checkout with the dependency the consumer resolves.
- `gleam deps update` works within declared constraints. Widen constraints deliberately through `gleam add package@version` or configuration edits. Resolve again, inspect and commit the manifest with the dependency change, then run the project gate.

## Work from typed boundaries

- Define domain types, error variants, and public signatures before implementing bodies. Temporary `todo as "reason"` boundaries let the compiler analyze the intended shape; they panic if executed and must not survive acceptance.
- Run `gleam check` after structural changes. Use supported annotation, exhaustive-pattern, label, and missing-definition actions where they clarify the design.
- Discover the connected server's capabilities and current code actions before choosing an operation. Prefer semantic rename and reference navigation when supported; inspect returned edits and their scope before applying them.
- Reuse a working LSP bridge. Bridge installation, Nix configuration, MCP registration, and machine-specific workarounds belong to environment setup. Do not add them merely to follow this guide.
- Fall back to source search and compiler checks for unsupported methods. Finish with formatting, a warnings-as-errors build, and relevant tests; tool success does not replace the repository gate.

## Red flags

- Mutable Git refs treated as reproducible pins.
- Updating a checkout while the application consumes another revision.
- Installing a second compiler or bridge without checking the existing setup.
- Assuming every bridge exposes every Gleam LSP feature.
- Accepting a semantic edit without checking changed files or unfinished `todo` boundaries.

## Sources

[Dependencies](https://gleam.run/documentation/gleam-toml-reference/#dependencies), [CLI](https://gleam.run/documentation/command-line-reference/), [language server](https://gleam.run/documentation/language-server-reference/), [todo](https://tour.gleam.run/advanced-features/todo/).
