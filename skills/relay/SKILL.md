---
name: relay
description: Serve and call typed MCP tools with Relay over stdio or Streamable HTTP. Use for shared tool contracts, resources, prompts, completion, discovery, mounting, bearer verification, call controls, and delivery evidence in Gleam applications.
---

# Relay

Choose Relay for MCP interoperability on Erlang: one typed tool definition supplies declaration, server decoding, and client calling. Internal operations need only functions; preserve a fitting MCP SDK. The inspected API implements revision `2026-07-28`; verify peer capabilities. Applications own business effects, durable execution, and retries.

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
5. Close clients, endpoints, and listeners the application created, including when later setup fails.

Use `try_define` for runtime-built definitions so invalid names or schemas return typed errors. Source-authored `define` treats invalid definitions as programmer errors. Refuse discovered schemas outside the supported profile rather than weakening their contract.

For resources, prompts, or completion, configure `server.with_resources`, `server.with_prompts`, or `server.with_completion` using their public contracts. These expose peer-facing capabilities without turning ordinary application functions into tools.

## Choose the transport honestly

- Use `http.handle` for a buffered `gleam_http` mount. It drops progress, cannot observe peer disconnects, and rejects `subscriptions/listen` with 406.
- Use `http.mist_handler`, a listener, or the supervised streaming endpoint for those capabilities.
- Use immutable per-call client views for deadlines, cancellation, headers, and correlation over a shared connection.
- Treat cancellation as stopping owned work. Detached children and remote effects need their own lifecycle or reconciliation contract.

## Separate identity and delivery

- Protect HTTP with `http.new_protected` when bearer admission is required. The verifier owns token signature, expiry, and issuer checks; the application owns business permissions.
- Treat stdio as relying on a trusted parent. It supplies no bearer authorization boundary.
- Inspect `client.kind(error)` and `client.evidence(error)` before retrying. Relay never retries automatically; `MaybeSent` can mean a mutating handler ran without a usable reply.
- Carry a stable idempotency key scoped to the authenticated principal when repetition must be safe. The application must implement duplicate suppression; the metadata alone does not.
- Keep request id, invocation id, correlation, and effect identity distinct. Correlation and client keys are untrusted input.
- Trust behavior hints only through a known peer contract. A discovered read-only annotation cannot prove a mutation safe to retry.

## Red flags

- Retrying a lost mutation under a new key.
- Returning transport success as business success despite `ToolFailed`.
- Promising progress or disconnect cancellation from a buffered mount.
- Using continuation state as proof of tenant or principal authorization.
- Assuming every MCP revision, OAuth flow, extension, or JSON Schema is supported.

## Verify

Check the consuming manifest and the relevant usage module. Validate changed protocol claims with the pinned schema or focused conformance cases; a passing server case does not establish client or authorization interoperability.

## Sources

[Public API](https://github.com/gleam-dream/relay/tree/8d588eb45659779bc26db1e32711a21336b3741d/src/relay) · [Usage topics](https://github.com/gleam-dream/relay/tree/8d588eb45659779bc26db1e32711a21336b3741d/examples/relay_usage) · [MCP specification](https://modelcontextprotocol.io/specification/2026-07-28)
