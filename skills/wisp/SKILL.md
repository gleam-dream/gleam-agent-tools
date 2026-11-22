---
name: wisp
description: Build and debug Erlang/OTP HTTP handlers and middleware with Wisp and Mist. Use for routing, request bodies, forms, uploads, responses, cookies, browser protections, streaming, and WebSocket boundaries. Use http-gun for outbound HTTP; applications own accounts and permissions.
---

# Wisp

Choose Wisp for Erlang HTTP endpoints built from request/response functions and small middleware: translate checked input into an application operation and map its result to HTTP.

## Governing rule

Let middleware refine requests and handlers translate protocols; keep domain decisions in Gleam application functions.

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

- Inspect the resolved Wisp, Mist and existing middleware. Match method and path deliberately, parse input, call the application, and map its result to status, headers, and body.
- Answer malformed input and domain failures as ordinary responses; reserve crash recovery for unexpected failures, without private diagnostics to clients.
- Read the body once with a `require_*` helper and share the result; Wisp does not cache the stream, so a second read can hang or return a wrong value.
- Check content type and decoding separately from domain validation. Choose body and upload limits at the adapter that enforces them.
- Pass existing application functions and storage capabilities explicitly; add a port only for a real variation. Test HTTP mapping apart from domain behavior.
- Use framework response/cookie helpers. Escape untrusted text in HTML, and validate redirect destinations by application policy.

## Keep the handler out of connection copies

Mist copies the builder given to `mist.start`, with its handler and `after_start` callback, into every connection's process. What they capture (route tables, codecs, catalogs, schemas, config) is copied per open connection and held while it lives; module literals and binaries over 64 bytes are not.

- Reach large data from the handler through module constants, `persistent_term` written once at start, or a named lookup process; none is copied into the connection. Ask a named process for the entry, not the table: its reply is copied.
- Build only cheap values inside the handler; a route table, codec or catalog built there is rebuilt per request, so build it once at start into `persistent_term`.
- Bound the copy size of the builder passed to `mist.start` in a test.

## Preserve request and resource ownership

- Apply method overrides before route dispatch. Pass on the request middleware returns, so later handlers see its checked headers.
- Treat cookie decoding, sign-in, origin checks, and resource permission as separate decisions; authorize each operation with application policy.
- With `csrf_known_header_protection`, keep GET/HEAD free of business mutations and consume the returned request; a missing origin/referer can strip cookies. Choose deliberately for routes serving other origins.
- Move uploads that must outlive the request into application storage before it completes. Mist and compliant adapters clean temporary files then; others need explicit cleanup.
- For streaming/WebSockets, specify connection ownership, disconnect handling, send limits, and cleanup from the actual transport contract. A buffered handler gives no stream backpressure.

## Verification

Exercise method/path matching, malformed input, expected domain failure, and relevant headers through the public handler. Use a real adapter for claims about consumed bodies, upload lifetime, streaming, or disconnects.

## Red flags

- Authentication and body middleware consume different copies of a checked request.
- A handler closure that captures a catalog, codec set or route table.
- Signed cookies treated as permission to access any resource.
- GET performs a mutation while the application relies on origin/SameSite protections.

## Sources

[Wisp request and middleware API](https://wisp.hexdocs.pm/wisp.html), [Mist adapter](https://wisp.hexdocs.pm/wisp/wisp_mist.html), [Mist transport API](https://mist.hexdocs.pm/mist.html), [glisten connection spawn](https://github.com/rawhat/glisten/blob/master/src/glisten/internal/acceptor.gleam).
