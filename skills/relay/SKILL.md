---
name: relay
description: Serve and call typed MCP tools with Relay over stdio or Streamable HTTP. Use for shared tool contracts, resources, prompts, completion, discovery, mounting, bearer verification, call controls, and delivery evidence in Gleam applications.
---

# Relay

Choose Relay for MCP interoperability on Erlang: one typed tool definition supplies declaration, server decoding, and client calling. Relay implements revision `2026-07-28`; applications own business effects, durable execution, and retries.

Use Hex `relay` 0.2 with `json_blueprint >= 2.1.1`; retain the resolved `manifest.toml`.

## Abstraction decision tree

```text
Need a protocol shared with MCP peers? → Relay
├── Trusted parent launches a local tool process → stdio
└── HTTP endpoint
    ├── Buffered request/response only → Wisp mount
    └── Progress, subscriptions, disconnect handling → streaming Mist mount
Need only an internal application operation? → Plain typed function
```

## Define, bind, call

1. Build one `tool.Definition(input, output)` from Blueprint codecs. Reuse it for server decoding and typed client calling.
2. Bind native handlers with `tool.handle` or call-aware handlers when identity and request metadata matter. Put bound tools in `server.new`.
3. Start or mount the endpoint; connect a client with HTTP or stdio configuration.
4. Call the typed definition and distinguish `Succeeded`, `ToolFailed`, input-required results, and client errors.
5. Close the clients, endpoints, and listeners you created, also when later setup fails.

Use `try_define` for runtime-built definitions; source-authored `define` panics on invalid ones. Refuse discovered schemas outside the supported profile rather than weakening their contract.

Expose resources, prompts, or completion with `server.with_resources`, `server.with_prompts`, or `server.with_completion`.

## Keep the catalog out of process copies

After 0.2.1, Relay holds the server, with its tool codecs and handlers, once in `persistent_term`; requests and tool workers read it uncopied. Relay 0.2.1 copies it several times per HTTP request and per call: keep its catalog small.

- Per request and per call Relay copies the body, arguments and the context your builder returns. Keep catalogues, clients and codecs out of the context.
- `register_tool` holds a new snapshot and scans the node; reserve it for rare changes.
- `client.call` encodes and decodes in the caller. Never send a `Definition` or codec to another process per operation.
- Follow the [json_blueprint codec practice](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md): child codecs inside their fields, generated codecs for fixed shapes.
- Guard with `erts_debug:flat_size(Term) * wordsize` of your context and anything you send.

## Choose the transport honestly

- Use `http.handle` for a buffered `gleam_http` mount. It drops progress, cannot observe peer disconnects, and rejects `subscriptions/listen` with 406.
- Use `http.mist_handler`, a listener, or the supervised streaming endpoint for those capabilities.
- Use per-call client views for deadlines, cancellation, headers, and correlation.
- Cancellation stops owned work; detached children and remote effects need their own reconciliation.

## Separate identity and delivery

- Protect HTTP with `http.new_protected` when bearer admission is required. The verifier checks tokens; the application owns business permissions.
- Stdio trusts its parent; it has no bearer authorization.
- Inspect `client.kind(error)` and `client.evidence(error)` before retrying; Relay never retries, and `MaybeSent` means a mutation may have run.
- Carry a stable idempotency key scoped to the authenticated principal when repetition must be safe; the application suppresses duplicates.
- Keep request id, invocation id, correlation, and effect identity distinct; correlation and client keys are untrusted.
- Trust behavior hints only through a known peer contract.

## Red flags

- Retrying a lost mutation under a new key.
- Returning transport success as business success despite `ToolFailed`.
- Promising progress or disconnect cancellation from a buffered mount.
- Using continuation state as proof of tenant or principal authorization.
- Assuming every MCP revision, OAuth flow, extension, or JSON Schema is supported.

## Verify

Check the consuming manifest and the relevant usage module. Validate protocol claims with the pinned schema or focused conformance cases; a passing server case proves no client or authorization interoperability.

## Sources

[HexDocs](https://hexdocs.pm/relay/0.1.0/) · [Public API](https://github.com/gleam-dream/relay/tree/bb72ae21644ce58718659161a42c55e998f4be46/src/relay) · [Usage topics](https://github.com/gleam-dream/relay/tree/bb72ae21644ce58718659161a42c55e998f4be46/examples/relay_usage) · [MCP specification](https://modelcontextprotocol.io/specification/2026-07-28)
