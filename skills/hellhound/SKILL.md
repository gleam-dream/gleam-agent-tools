---
name: hellhound
description: Integrate OIDC login, OAuth tokens, and access-token validation with Hellhound on Erlang/OTP. Use for authorization-code callbacks, token custody, refresh, resource servers, introspection, durable authentication stores, and logout.
---

# Hellhound

Choose Hellhound to sign users in or manage provider tokens while it handles discovery, key rotation, shared refresh, and token custody. Applications own accounts, browser sessions, permissions, and resource-request retries. Preserve an adequate existing integration.

## Abstraction decision tree

| Need                                           | Choose                                                                        |
| ---------------------------------------------- | ----------------------------------------------------------------------------- |
| OIDC browser login                             | Relying-party configuration and Hellhound's login helpers                     |
| Service-to-service OAuth                       | Service configuration and `client_credentials`; application-owned token cache |
| RFC 9068 JWT access-token validation           | Resource-server configuration and `hellhound/resource`                        |
| Provider-observed token state or opaque tokens | `introspect`, with explicit availability handling                             |
| Sessions surviving custody-store restart       | Durable stores plus a stable sealing key                                      |
| Accounts, permissions, or application sessions | Application policy around Hellhound's evidence                                |

Use Hex `hellhound` 0.2.3 on Erlang; install `hellhound_postgres` 0.1.0 from Git ref `hellhound_postgres-v0.1.0`, path `integrations/hellhound_postgres`. Deployment requires independent security review; Hellhound is not certified.

## Configure clients, complete the login

- Register the exact callback URI with the issuer. Construct role-specific configuration from trusted settings; retain verified HTTPS and transaction-binding defaults.
- Call `hellhound.new` once per independent configuration at application setup and reuse each handle. It validates and allocates stable names without starting processes. Start manually or add `hellhound.supervised(client)` to the application's supervisor.
- Handle `ProviderNotReady` during background supervised discovery; a stable handle after restart does not mean metadata or memory sessions survived.
- Use `begin_login` with `login_response`, then `complete_login` on the callback. Preserve its browser-binding cookie and callback input; never recreate state, nonce, or PKCE handling.
- Map the verified `(issuer, subject)` pair to an application principal. Keep `session_reference` in a protected application session; apply permission and origin checks on protected routes.
- Restore the session and obtain `access_token` before an outgoing request. Concurrent refresh shares one exchange. Decide separately whether a resource request can be repeated after a 401.
- For JWT assertions or token requests without discovery, use `hellhound/assertion` and `hellhound/exchange`. `perform` sends one request at most; the application owns reuse, expiry, and retries.
- Since 0.2.0, JWK `alg` or `kid` set to `null` is rejected; omit them.

## Preserve recovery authority

- Match every projected `Action`: `Reauthenticate`, `RetryLater`, `Recover`, `FixConfiguration`, and `RejectRequest`. Keep the full error for recovery.
- Pass the carried recovery to `recover_custody` or `recover_refresh`. Recovery can publish already-obtained custody without another provider exchange; never resend a possibly consumed authorization code or refresh token.
- Diagnose with the `describe_*` functions; never log opaque token, session, or recovery values.
- End the application's session during logout. Inspect custody removal, token revocation, and provider redirection as separate outcomes.

## Own storage and shutdown

- Use memory defaults when restart loss is acceptable. For durable custody and login transactions, configure both stores and preserve the sealing key.
- Prefer the PostgreSQL adapter when it fits. The application owns migration, pool lifetime, capacity, backups, and key custody.
- If implementing a custom store, honor its atomic conditional-write contract. Check deadlines under exclusive write authority after waiting; preserve uncertain commits. `testing.check_store` does not replace lock-wait tests.
- Stop request admission before shutdown, and supervised clients through their parent. A returned manual `stop` does not prove workers or external effects finished; keep captured pools alive until they have.
- Test login and recovery against `hellhound/testing`'s local provider. Test resource audience, scope, and availability outcomes separately; local JWT validation cannot show current revocation.

## Red flags

- Using email as the stable account key or treating login as permission.
- Converting `Recover` into a fresh token exchange.
- Treating a resource POST as repeatable because refresh succeeded.
- Adding PostgreSQL while losing the sealing key on restart.

## Sources

[HexDocs](https://hexdocs.pm/hellhound/0.2.3/) · [Public API and consumers](https://github.com/gleam-dream/hellhound/blob/v0.2.3/README.md), [application decisions](https://github.com/gleam-dream/hellhound/blob/v0.2.3/consumer/src/hellhound_reference/usage/responsibilities.gleam), [store contract](https://github.com/gleam-dream/hellhound/blob/v0.2.3/src/hellhound/store.gleam).
