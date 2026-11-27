---
name: correio
description: Deliver transactional email and verify passwordless challenges with Correio on Erlang. Use for SMTP, Postmark, captured-mail tests, magic links, email codes, and challenge recovery.
---

# Correio

Choose Correio for one `Message -> Outcome` sender across SMTP, Postmark, and test capture, or for typed passwordless challenges. Delivery and verification are independent. Applications own templates, accounts, scheduling, browser policy, and sessions; retain suitable existing integrations.

## Abstraction decision tree

| Need                               | Choose                                                     |
| ---------------------------------- | ---------------------------------------------------------- |
| Transactional email                | Validated `Message` and an injected `delivery.Sender`      |
| SMTP submission                    | `smtp.starttls` or implicit TLS configuration              |
| Postmark submission                | `correio_postmark` with a caller-owned HTTP Gun client     |
| Test email flows                   | Owned `capture` and `testing` checkpoint                   |
| Magic link or email code           | `passwordless` over an application-native subject type     |
| Shared durable challenge authority | `correio_postgres` with a named Pog pool and subject codec |

Add the latest `correio` release on Erlang; adapters install from Git (`gleam-dream/correio`, path `adapters/<name>`): pin the newest `<name>-v*` tag whose gleam.toml accepts the resolved core (and, for `correio_postmark`, `http_gun`), by its commit. Addresses exclude SMTPUTF8 mailboxes, quoted local parts, and address literals.

## Construct once, inject delivery

- Build addresses and messages through checked constructors, handling user input through `Result`.
- Inject `delivery.Sender` at setup; keep provider selection outside business code.
- Use verified TLS for SMTP; loopback plaintext is for local tests, without credentials. SMTP configuration starts no process; each send is one bounded exchange.
- Handle all four outcomes: `Accepted` records provider submission, `NotSent` proves no submission (including `AuthenticationFailed`), `Rejected` distinguishes temporary and permanent refusal, and `OutcomeUnknown` preserves possible submission.
- Correct the cause before retrying `NotSent`, schedule temporary refusals by policy, and never retry possibly transmitted mail automatically. Acceptance does not prove arrival. A receipt's `message_id` (absent from Postmark receipts) matches bounces but does not deduplicate.
- Let Postmark's adapter interpret responses. Before starting or recording its HTTP client, add `postmark.redact_token` and body redaction for content and addresses.

## Inspect the application's actual mail

- Start a bounded capture and inject `capture.sender`; checkpoint before the flow, then await a matching message and inspect its public projection.
- Isolate parallel captures or match correlation; stop each capture with its owner.
- Mount `correio_mailbox` only behind development access policy; it exposes content and blind recipients, starts no listener, and owns no server.

## Issue, deliver, consume

- Construct the passwordless service with the authoritative store, scope, purpose, and a stable cryptographically random key; a length check cannot establish entropy.
- Issue for an application-native subject and trusted current destination, then deliver the answer; issuance sends no email. Choose `MagicLink` or `EmailCode` per interaction.
- Collect a magic-link answer on landing GET and verify only after intentional confirmation on an application-protected POST. Apply account and session policy only after `verify` returns confirmed evidence.
- Retain `IssueUnknown`, `VerifyUnknown`, and `RevokeUnknown` handles and call the matching `recover_*`; a fresh issue or verify is a different operation.
- If session publication fails, retry it with the confirmed evidence, keyed by `verification_id`; never re-verify the consumed answer.
- Revoke explicitly when resend policy withdraws older challenges; a new issue revokes nothing.
- Use memory when restart loss is acceptable: supervise `memory.supervised` and build ports with `memory.store`, both from one startup name. A restarted store is empty and old issue handles expire (`IssueExpired`).
- For PostgreSQL, migrate at deployment, call bounded cleanup explicitly, and keep the borrowed pool alive. `IncompatibleData` is a schema fault. Recovery handles have no stable persistence format; cross-restart recovery needs application design.

## Red flags

- Retrying a timed-out email without inspecting its submission outcome.
- Verifying a magic link on GET or treating verification as account permission.
- Reissuing a challenge to resolve a lost acknowledgement.
- Assuming Postmark's HTTP 2xx alone proves acceptance.

## Sources

[HexDocs](https://hexdocs.pm/correio/) · [Consumers](https://github.com/gleam-dream/correio/blob/main/README.md), [passwordless](https://github.com/gleam-dream/correio/blob/main/src/correio/passwordless.gleam), [Postmark](https://github.com/gleam-dream/correio/blob/main/adapters/correio_postmark/README.md).
