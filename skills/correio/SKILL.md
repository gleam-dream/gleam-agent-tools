---
name: correio
description: Deliver transactional email and verify passwordless challenges with Correio on Erlang. Use for SMTP, Postmark, captured-mail tests, magic links, email codes, and challenge recovery.
metadata:
  library: gleam-dream/correio
  library-ref: ffd4836c1ec425af41de098d402d5b24ff9c868a
---

# Correio

Choose Correio when application email should use one `Message -> Outcome` sender across SMTP, Postmark, and test capture, or when typed passwordless challenges fit. Delivery and verification are independent. Applications own templates, accounts, scheduling, browser policy, and sessions; retain suitable existing integrations.

## Abstraction decision tree

| Need                               | Choose                                                     |
| ---------------------------------- | ---------------------------------------------------------- |
| Transactional email                | Validated `Message` and an injected `delivery.Sender`      |
| SMTP submission                    | `smtp.starttls` or implicit TLS configuration              |
| Postmark submission                | `correio_postmark` with a caller-owned HTTP Gun client     |
| Test application email flows       | Owned `capture` and `testing` checkpoint                   |
| Magic link or email code           | `passwordless` over the application's native subject type  |
| Shared durable challenge authority | `correio_postgres` with a named Pog pool and subject codec |

Add the latest `correio` release (`gleam add correio`) on Erlang; adapters install from Git (`gleam-dream/correio`, path `adapters/<name>`): pin the newest `<name>-v*` tag whose gleam.toml accepts the resolved core, by its commit. Addresses exclude SMTPUTF8 mailboxes, quoted local parts, and address literals.

## Construct once, inject delivery

- Parse addresses and construct messages through checked constructors. Handle user input through `Result`.
- Inject `delivery.Sender` at setup; keep provider selection outside business code.
- Use verified TLS for SMTP. The explicit loopback plaintext constructor is for local tests; it cannot carry credentials. SMTP configuration starts no process, and each send owns one bounded exchange.
- Handle all four outcomes: `Accepted` records provider submission, `NotSent` proves no submission, `Rejected` distinguishes temporary and permanent refusal, and `OutcomeUnknown` preserves possible submission.
- Correct the cause before retrying `NotSent`; schedule temporary refusals by application policy. Never automatically retry possibly transmitted mail. Acceptance does not prove inbox arrival; Message-ID does not deduplicate.
- Let Postmark's adapter interpret responses. Before starting or recording its HTTP client, add `postmark.redact_token` and body redaction for content and addresses.

## Inspect the application's actual mail

- Start a bounded capture and inject `capture.sender`. Checkpoint before triggering the flow, then await a matching message and inspect its public projection.
- Isolate parallel captures or match application correlation. Stop each capture when its owner finishes.
- Mount `correio_mailbox` only behind explicit development access policy. It exposes message content and blind recipients; it starts no listener and owns no server.

## Issue, deliver, consume

- Construct the passwordless service with the authoritative store, scope, purpose, and a stable cryptographically random application key. A length check cannot establish entropy.
- Issue for an application-native subject and trusted current destination. Deliver the returned answer explicitly; issuance sends no email. Choose `MagicLink` or `EmailCode` per interaction.
- Collect a magic-link answer on landing GET and require intentional confirmation on an application-protected POST. Apply account and session policy only after `verify` returns confirmed opaque evidence.
- Retain `IssueUnknown`, `VerifyUnknown`, and `RevokeUnknown` handles and call the corresponding `recover_*` operation. Recovery resolves the original command; a fresh issue or verify is a different operation.
- Retain confirmed verification evidence if session publication fails. Retry application publication with `verification_id` as its idempotency identity; never re-verify the consumed answer.
- Revoke explicitly when resend policy withdraws older challenges. Issuing a new challenge does not revoke a previous one.
- Use memory when restart loss is acceptable. For PostgreSQL, migrate during deployment and call bounded cleanup explicitly; keep the borrowed pool alive. Recovery handles have no stable persistence format, so cross-restart recovery needs application design.

## Red flags

- Retrying a timed-out email without inspecting its submission outcome.
- Verifying a magic link on GET or treating verification as account permission.
- Reissuing a challenge to resolve a lost acknowledgement.
- Assuming Postmark's HTTP 2xx alone proves acceptance.

## Sources

[HexDocs](https://hexdocs.pm/correio/) · [Public API and consumers](https://github.com/gleam-dream/correio/blob/main/README.md), [passwordless evidence](https://github.com/gleam-dream/correio/blob/main/src/correio/passwordless.gleam), [Postmark ownership](https://github.com/gleam-dream/correio/blob/main/adapters/correio_postmark/README.md).
