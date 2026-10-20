---
name: wisp
description: Build and debug Erlang/OTP HTTP handlers and middleware with Wisp and Mist. Use for routing, request bodies, forms, uploads, responses, cookies, browser protections, streaming, and WebSocket boundaries. Use http-gun for outbound HTTP; applications own accounts and permissions.
---

# Wisp

Translate an inbound HTTP request into a checked application operation and an explicit response.

## Governing rule

Read the request body once. Pass the parsed value onward instead of asking another layer to consume the stream again.

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
- Keep domain decisions in Gleam application functions and storage behind explicit application capabilities. Let handlers parse requests and map results so HTTP behavior can be tested independently.
- Use framework response/cookie helpers. Escape untrusted text when constructing HTML, and validate redirect destinations according to application policy.

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
- An uploaded temporary path is retained after the request ends.
- Signed cookies treated as permission to access any resource.
- GET performs a mutation while the application relies on origin/SameSite protections.

## Sources

[Wisp request and middleware API](https://wisp.hexdocs.pm/wisp.html), [Mist adapter](https://wisp.hexdocs.pm/wisp/wisp_mist.html), [Mist transport API](https://mist.hexdocs.pm/mist.html).
