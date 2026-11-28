---
name: http-gun
description: Send and debug outgoing HTTP with HTTP Gun on Erlang/OTP. Use for pooled requests, streamed response bodies, deadlines, cancellation, destination policy, client certificates, and HTTP recording or playback.
metadata:
  library: gleam-dream/http_gun
  library-ref: 7e71650d390d3b48989969b6e388924b7401ace0
  not-in-library: buffered.response buffered.truncated
---

# HTTP Gun

Choose HTTP Gun on Erlang when shared pooling, bounded response reads, owned body lifetimes, or live/playback exchanges justify a managed client; otherwise a simpler or existing client suffices. Applications interpret statuses, decode payloads, and decide repetition.

## Abstraction decision tree

| Need                                                            | Choose                                                                      |
| --------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Redirects, decompression, proxies, or streamed uploads required | Select a transport exposing those capabilities                              |
| Small complete response                                         | `send` with a body limit                                                    |
| Incremental response                                            | `with_response` and `body.next`                                             |
| Body lifetime extends beyond one callback                       | `open`, with an explicit owner and `body.close`                             |
| Several independent requests                                    | `batch` with explicit concurrency; results retain input order               |
| Deterministic HTTP tests                                        | `testing.playback`, then `testing.verify`; cassettes for captured exchanges |

Add the latest `http_gun` release on Erlang and retain the resolved manifest; it provides no generic SSE parsing.

## Configure once, reuse the client

- Start from `config.default()`. Use `http_gun.supervised(settings, name)` and `http_gun.named(name)` for shared use. `start` links the client to its caller; stop supervised clients through their parent.
- Build a `Request(BitArray)`, call `send`, then inspect `buffered.response.status` before decoding `buffered.response.body`. An `Ok` transport result can contain a 404 or 503.
- Use pool-sharing client views for per-call deadline, body limit, cancellation, destination, and correlation; a destination view narrows authority, never enlarges it.
- Every call ends at a caller-enforced deadline, `with_timeout` (30 s by default) or `with_deadline`, also on `named` handles. Reopen long streams under a long timeout.
- Enable loopback explicitly for local services and tests. Keep verified TLS and destination policy; a client identity does not replace server verification. A server accepting only TLS 1.2 CBC suites needs `config.with_cipher_suites(settings, config.OtpDefaultsAndTls12Cbc)`, not weaker verification.
- Set collection limits to the accepted payload; with truncation, check `buffered.truncated` before treating bytes as complete.

## Keep the body with its reader

- Prefer `with_response` for lexical streaming; it closes the body on callback return or exception.
- Read an explicit body from the process that opened it; copies share one cursor and transfer no read ownership.
- Close every body from `open`, even after EOF or failed collection; any holder may close, and local cancellation cannot undo remote effects.
- `body.next_within` returning `None` is an expired local wait, not EOF; the stream stays readable.
- Bound application work separately; the deadline never interrupts decoding or sink work, inside a `with_response` callback or after completion.

## Retry from evidence

- Inspect failure kind and submission evidence; `NotSent` and `MaybeSent` differ in authority. Call `error.is_retryable(failure, idempotent:)` with the request's actual idempotency.
- Apply backoff and attempt limits in the application; HTTP Gun never retries. Cancellation or `DeadlineExceeded` does not prove the server did nothing.
- Retain `error.status` and `error.headers` after a body-collection failure.
- Configure recording redaction before startup. Defaults remove common credential headers and replace listed credential query and form/JSON fields; add provider headers with `with_headers`, fields with `with_query_parameters` or `with_body_fields`, and `with_body` for other bodies.
- `cassette.encode` does not redact: run `cassette.redact(script, policy)` on a hand-built or parsed script that can hold credentials. To replay answers exactly, use `redaction.request_fields_only`: it keeps response bodies as received unless `with_body` rewrites them; redact tokens before saving.
- Choose recording or playback at startup. Finish a recording explicitly and handle its result; HTTP success does not confirm cassette publication. Handle `NotAnswered` from `testing.verify`.

## Red flags

- A shared client started by a short-lived request process.
- A worker reading a body opened by its parent.
- Retrying every timeout or decoding a truncated response as complete JSON.
- Treating default cassette redaction as removal of every secret.

## Sources

[HexDocs](https://hexdocs.pm/http_gun/) · [API and consumers](https://github.com/gleam-dream/http_gun/blob/main/README.md), [body ownership](https://github.com/gleam-dream/http_gun/blob/main/src/http_gun/body.gleam), [retry evidence](https://github.com/gleam-dream/http_gun/blob/main/src/http_gun/error.gleam).
