---
name: http-gun
description: Send and debug outgoing HTTP with HTTP Gun on Erlang/OTP. Use for pooled requests, streamed response bodies, deadlines, cancellation, destination policy, client certificates, and HTTP recording or playback.
---

# HTTP Gun

Choose HTTP Gun on Erlang when shared pooling, bounded response reads, owned body lifetimes, or live/playback exchanges justify a managed client. A simpler or existing client suffices without those needs. Applications interpret statuses, decode payloads, and decide repetition.

## Abstraction decision tree

| Need                                                            | Choose                                                                      |
| --------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Redirects, decompression, proxies, or streamed uploads required | Select a transport exposing those capabilities                              |
| Small complete response                                         | `send` with a body limit                                                    |
| Incremental response                                            | `with_response` and `body.next`                                             |
| Body lifetime extends beyond one callback                       | `open`, with an explicit owner and `body.close`                             |
| Several independent requests                                    | `batch` with explicit concurrency; results retain input order               |
| Deterministic HTTP tests                                        | `testing.playback`, then `testing.verify`; cassettes for captured exchanges |

Use Hex `http_gun` 0.2.0 on Erlang; retain the resolved manifest. Generic SSE parsing is not provided.

## Configure once, reuse the client

- Start from `config.default()`. Use `http_gun.supervised(settings, name)` and `http_gun.named(name)` for shared application use. `start` links the client to its caller; stop supervised clients through their parent.
- Build a `Request(BitArray)`, call `send`, then inspect `buffered.response.status` before decoding `buffered.response.body`. An `Ok` transport result can contain a 404 or 503.
- Use client views for per-call timeout, deadline, body limit, cancellation, destination, and correlation. Views share the pool. A destination view can narrow its authority, never enlarge it.
- Enable loopback explicitly for local services and tests. Keep verified TLS and the intended destination policy; a client identity does not replace server verification. A server accepting only TLS 1.2 CBC suites needs `config.with_cipher_suites(config.OtpDefaultsAndTls12Cbc)`, not weaker verification.
- Set collection limits to the payload the application accepts. If selecting truncation, inspect `buffered.truncated` before treating the bytes as a complete document.

## Keep the body with its reader

- Prefer `with_response` for lexical streaming; it closes the body on callback return or exception.
- Read an explicit body from the process that opened it. Copies share one cursor; they do not transfer read ownership or create independent streams.
- Close every body obtained through `open`, including after EOF or failed collection. Any holder may close; local cancellation cannot undo remote effects.
- Distinguish `body.next_within` returning `None` from EOF. A local wait expiring leaves the stream available for a later read.
- Bound application work separately. An HTTP timeout does not interrupt arbitrary decoding or sink computation after HTTP completion.

## Retry from evidence

- Inspect failure kind and submission evidence. `NotSent` and `MaybeSent` have different authority; call `error.is_retryable(failure, idempotent:)` with the application's actual request semantics.
- Apply backoff and attempt limits in the application. HTTP Gun never retries automatically. Cancellation or a timeout does not establish that the server did nothing.
- Retain `error.status` and `error.headers` after a body-collection failure; the response head can still inform handling.
- Configure recording redaction before startup. Defaults remove common credential headers and replace listed credential query and form/JSON fields; add provider names, and `with_body` for other bodies.
- `cassette.encode` applies no redaction: run `cassette.redact(script, policy)` on a hand-built or parsed script first.
- 0.2.0 reads only schema 3 cassettes; convert 0.1.x files on the commit its changelog names.
- Choose recording or playback at startup. Finish a recording explicitly and handle its result; HTTP success alone does not confirm cassette publication.

## Red flags

- A shared client started by a short-lived request process.
- A worker reading a body opened by its parent.
- Retrying every timeout or decoding a truncated response as complete JSON.
- Treating default cassette redaction as removal of every secret.
- Encoding a parsed or hand-built script without `cassette.redact`.

## Sources

[HexDocs](https://hexdocs.pm/http_gun/0.2.0/) · [Public API and consumers](https://github.com/gleam-dream/http_gun/blob/v0.2.0/README.md), [body ownership](https://github.com/gleam-dream/http_gun/blob/v0.2.0/src/http_gun/body.gleam), [retry evidence](https://github.com/gleam-dream/http_gun/blob/v0.2.0/src/http_gun/error.gleam).
