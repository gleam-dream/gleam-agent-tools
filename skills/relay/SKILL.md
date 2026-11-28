---
name: relay
description: Serve and call typed MCP tools with Relay over stdio or Streamable HTTP. Use for shared tool contracts, resources, prompts, completion, discovery, mounting, bearer verification, call controls, and delivery evidence in Gleam applications.
metadata:
  library: gleam-dream/relay
  library-ref: 2491ebb65713e05a50917fe1747d18b5cc370be9
---

# Relay

Choose Relay for MCP interoperability on Erlang: one typed tool definition supplies declaration, server decoding, and client calling. Relay implements the one MCP revision its [README](https://github.com/gleam-dream/relay/blob/main/README.md) names; applications own business effects, durable execution, and retries.

Add the latest `relay` and `json_blueprint` releases and retain `manifest.toml`.

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

1. Build one `tool.Definition(input, output)` from Blueprint codecs; reuse it for server decoding and client calls.
2. Bind native handlers with `tool.handle` or call-aware handlers when identity and request metadata matter. Put bound tools in `server.new`.
3. Start or mount the endpoint; connect a client over HTTP or stdio.
4. Call the typed definition and distinguish `Succeeded`, `ToolFailed`, input-required results, and client errors.
5. Close every client, endpoint, and listener you created, even after failed setup.

Use `try_define` for runtime-built definitions; source-authored `define` panics on invalid ones. Refuse discovered schemas outside the supported profile instead of weakening them.

Expose resources, prompts, or completion with `server.with_resources`, `server.with_prompts`, or `server.with_completion`.

## Keep the catalog out of process copies

HTTP endpoints and stdio servers hold the server, codecs and handlers included, once in `persistent_term`; requests and tool workers read it uncopied. In-process clients and `runtime.start` copy the called tool per call.

- Relay copies the body, arguments and context per request and call. Keep catalogues, clients and codecs out of the context.
- `register_tool` frees the previous snapshot, which scans the node; register rarely.
- A json_blueprint codec copies at about its own size; build a run-time enum once, before the chain ([codec practice](https://github.com/gleam-dream/json_blueprint/blob/main/docs/CODEC-PRACTICE.md)).

## Choose the transport honestly

- Use `http.handle` for a buffered `gleam_http` mount. It drops progress, cannot observe peer disconnects, and rejects `subscriptions/listen` with 406.
- Use `http.mist_handler`, a listener, or the supervised streaming endpoint for those capabilities.
- Per-call client views set deadlines, cancellation, headers, and correlation.
- Reopen an HTTP `listen` subscription ended by `TimedOut`.
- Cancellation stops owned work; detached children and remote effects need separate reconciliation.

## Separate identity and delivery

- Protect HTTP with `http.new_protected` for bearer admission. The verifier checks tokens; the application owns business permissions.
- Stdio trusts its parent, without bearer authorization.
- Start a stdio server's VM with `-noinput`. Keep its standard output for frames.
- A `client.stdio` child gets only allow-listed variables of the environment at launch; a concurrent `os:putenv` is not excluded. Add others with `client.with_environment`.
- Inspect `client.kind(error)` and `client.evidence(error)` before retrying. Relay never retries; `MaybeSent` can mean a mutation ran.
- Carry a stable idempotency key scoped to the authenticated principal when repetition must be safe; the key alone suppresses nothing.
- Keep request id, invocation id, correlation, and effect identity distinct; correlation and client keys are untrusted.
- Trust behavior hints only through a known peer contract; a discovered read-only hint cannot prove a retry safe.

## Red flags

- Retrying a lost mutation under a new key.
- Returning transport success as business success despite `ToolFailed`.
- Promising progress or disconnect cancellation from a buffered mount.
- Using continuation state as proof of tenant or principal authorization.
- Assuming every MCP revision, OAuth flow, extension, or JSON Schema is supported.

## Verify

Check the relevant usage module. Validate protocol claims with the implemented revision's schema or focused conformance cases; a passing server case proves no client or authorization interoperability.

## Sources

[HexDocs](https://relay.hexdocs.pm/) · [Public API](https://github.com/gleam-dream/relay/tree/main/src/relay) · [Usage](https://github.com/gleam-dream/relay/tree/main/examples/relay_usage) · [MCP revision](https://github.com/gleam-dream/relay/blob/main/README.md#relay)
