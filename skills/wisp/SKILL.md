---
name: wisp
description: Build and debug Erlang/OTP HTTP handlers and middleware with Wisp and Mist. Use for routing, request bodies, forms, uploads, responses, cookies, browser protections, streaming, and WebSocket boundaries. Use http-gun for outbound HTTP; applications own accounts and permissions.
---

# Wisp

Choose Wisp for Erlang HTTP endpoints composed from ordinary request/response functions and small middleware. Translate checked input into a Gleam application operation, then map its result to HTTP. Use Mist's transport API when connection-level behavior is required.

## Governing rule

Let middleware refine requests and handlers translate protocols; keep domain decisions in Gleam application functions. Read a body once and pass its parsed value onward.

## Abstraction decision tree

```text
What HTTP responsibility is needed?
├── Route, middleware, parsed body, ordinary response → Wisp
├── Listen and adapt Wisp responses → Wisp's Mist integration
├── Streaming or WebSocket mechanics → Check Mist's public transport API
├── Outbound request → HTTP Gun or the existing outbound client
└── Business decision → Application function called by the handler
```

## Build the handler

- Inspect the resolved Wisp/Mist versions and existing middleware. Match method and path deliberately, parse input, invoke the application, then map its result into status, headers, and body.
- Keep expected malformed input and domain failures on ordinary response paths. Use crash recovery for unexpected failures without returning private diagnostics to clients.
- Use the selected `require_*` body/form helpers and share their result. Wisp's body helpers do not cache the consumed stream; repeated reads may hang or return an incorrect value.
- Check content type and decoding separately from domain validation. Choose body and upload limits at the adapter that enforces them.
- Pass existing application functions and storage capabilities explicitly; add a port only for a real variation. Test HTTP mapping independently from domain behavior.
- Use framework response/cookie helpers. Escape untrusted text when constructing HTML, and validate redirect destinations according to application policy.

## Keep the handler out of connection copies

Mist 6.0.3 copies the builder given to `mist.start`, with its handler and `after_start` callback, into every connection's process. What those functions capture, such as route tables, codecs, catalogs, schemas and config, is copied once per open connection and kept while the connection lives; module literals and binaries over 64 bytes are not. A handler capturing a 320 kB list holds 384 kB in each connection, and the listener's supervisors hold about 18 more copies from start.

- Reach large data from inside the handler through module constants, `persistent_term` written once at start, or a named process that answers lookups; none is copied into the connection. A named process copies its reply, so ask it for the entry, not the table.
- Build inside the handler only what is cheap: a composed route table, codec or catalog built there is rebuilt on every request. Build it once at start and keep it in `persistent_term`.
- Bound the copy size of the builder passed to `mist.start` in a test. The `gleam-otp` skill holds the general process-copy rule.

## Preserve request and resource ownership

- Apply method overrides before route dispatch where required. Preserve the request returned by middleware so later handlers use its checked or modified headers.
- Treat cookie decoding, sign-in, origin checks, and resource permission as separate decisions. Authorize the requested operation with application-owned policy.
- With `csrf_known_header_protection`, keep GET/HEAD free of business mutations. Missing origin/referer can cause cookies to be stripped; consume the middleware's returned request. Choose the policy deliberately for routes intended for other origins.
- Move uploaded files into application-owned storage before request completion when they must survive it. Mist and compliant adapters clean temporary files at completion; other adapters require explicit cleanup.
- For streaming/WebSockets, specify connection ownership, disconnect handling, send limits, and cleanup using the actual transport contract. A buffered handler does not establish stream backpressure.

## Verification

Exercise method/path matching, malformed input, expected domain failure, and relevant headers through the public handler. Use a real adapter for claims about consumed bodies, upload lifetime, streaming, or disconnects. A constructed request alone cannot establish those transport behaviors.

## Red flags

- Authentication and body middleware consume different copies of a checked request.
- Two layers independently read the same body stream.
- A handler closure that captures a catalog, codec set or route table.
- A route table or codec built inside the handler on every request.
- An uploaded temporary path is retained after the request ends.
- Signed cookies treated as permission to access any resource.
- GET performs a mutation while the application relies on origin/SameSite protections.

## Sources

[Wisp request and middleware API](https://wisp.hexdocs.pm/wisp.html), [Mist adapter](https://wisp.hexdocs.pm/wisp/wisp_mist.html), [Mist transport API](https://mist.hexdocs.pm/mist.html), [glisten 9.0.1 connection spawn](https://github.com/rawhat/glisten/blob/v9.0.1/src/glisten/internal/acceptor.gleam).
