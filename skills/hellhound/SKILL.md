---
name: hellhound
description: Integrate OIDC login, OAuth tokens, and access-token validation with Hellhound on Erlang/OTP. Use for authorization-code callbacks, token custody, refresh, resource servers, introspection, durable authentication stores, and logout.
---

# Hellhound

Choose Hellhound to sign users in or manage provider tokens while it handles discovery, key rotation, shared refresh, and token custody. Applications own accounts, browser sessions, permissions, and resource-request retries. Keep adequate existing integrations.

## Abstraction decision tree

| Need                                           | Choose                                                                        |
| ---------------------------------------------- | ----------------------------------------------------------------------------- |
| OIDC browser login                             | Relying-party configuration and Hellhound's login helpers                     |
| Service-to-service OAuth                       | Service configuration and `client_credentials`; application-owned token cache |
| RFC 9068 JWT access-token validation           | Resource-server configuration and `hellhound/resource`                        |
| Provider-observed token state or opaque tokens | `introspect`, with explicit availability handling                             |
| Sessions surviving custody-store restart       | Durable stores plus a stable sealing key                                      |
| Accounts, permissions, or application sessions | Application policy around Hellhound's evidence                                |

Add the latest `hellhound` release (`gleam add hellhound`) on Erlang; for PostgreSQL stores only, install `hellhound_postgres` from Git (`gleam-dream/hellhound`, `integrations/hellhound_postgres`): pin the newest `hellhound_postgres-v*` tag whose gleam.toml accepts the resolved core, by its commit. Hellhound is uncertified; deployment needs independent security review.

## Configure clients, complete the login

- Register the exact callback URI with the issuer. Build role configuration from trusted settings; retain verified HTTPS and transaction-binding defaults.
- Call `hellhound.new` once per configuration at setup and reuse each handle; it starts no processes. Start the handle or supervise it with `hellhound.supervised(client)`.
- Handle `ProviderNotReady` during supervised discovery; a stable handle after restart does not mean metadata or memory sessions survived.
- Use `begin_login` with `login_response`, then `complete_login` on the callback. Preserve its browser-binding cookie and callback input; never recreate state, nonce, or PKCE.
- Map the verified `(issuer, subject)` to a principal. Keep `session_reference` in a protected session; check permission and origin on protected routes.
- Restore the session and obtain `access_token` before an outgoing request; concurrent refresh shares one exchange. Decide separately whether to repeat a resource request after a 401.
- For JWT assertions or discovery-free token requests, use `hellhound/assertion` and `hellhound/exchange`. Create the client with `exchange.new`, supervise it with `exchange.supervised(client)` before `perform`, which sends at most one request; the application owns reuse, expiry, and retries.
- In a signing JWK for `hellhound/assertion`, omit an unused `alg` or `kid`.

## Preserve recovery authority

- Match every projected `Action`: `Reauthenticate`, `RetryLater`, `Recover`, `FixConfiguration`, and `RejectRequest`. Keep the full error for recovery.
- Pass the carried recovery to `recover_custody` or `recover_refresh`. Recovery can publish obtained custody without another exchange; never resend a possibly consumed authorization code or refresh token.
- Diagnose with `describe_*`; never log opaque token, session, or recovery values.
- On logout, end the application's session; custody removal, token revocation, and provider redirection are separate outcomes.

## Own storage and shutdown

- Use memory defaults when restart loss is acceptable; otherwise configure durable custody and transaction stores and preserve the sealing key.
- With the PostgreSQL adapter for PostgreSQL stores, the application owns migration, pool lifetime, capacity, backups, and key custody.
- For a custom store, honor its atomic conditional-write contract: check deadlines under exclusive write authority after waiting, and preserve uncertain commits. `testing.check_store` does not replace lock-wait tests.
- Stop request admission before shutdown, and supervised clients through their parent. A returned manual `stop` does not prove workers or external effects finished; keep captured pools alive until they have.
- Test login and recovery against `hellhound/testing`'s local provider. Test resource audience, scope, and availability outcomes separately; local JWT validation cannot show current revocation.

## Red flags

- Using email as the stable account key or treating login as permission.
- Converting `Recover` into a fresh token exchange.
- Treating a resource POST as repeatable because refresh succeeded.
- Adding PostgreSQL while losing the sealing key on restart.

## Sources

[HexDocs](https://hexdocs.pm/hellhound/) · [Public API and consumers](https://github.com/gleam-dream/hellhound/blob/main/README.md), [application decisions](https://github.com/gleam-dream/hellhound/blob/main/consumer/src/hellhound_reference/usage/responsibilities.gleam), [store contract](https://github.com/gleam-dream/hellhound/blob/main/src/hellhound/store.gleam).
