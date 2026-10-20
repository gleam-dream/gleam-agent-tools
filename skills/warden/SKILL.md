---
name: warden
description: Integrate OIDC login, OAuth tokens, and access-token validation with Warden on Erlang/OTP. Use for authorization-code callbacks, token custody, refresh, resource servers, introspection, durable authentication stores, and logout.
---

# Warden

Use checked protocol evidence and managed user-token custody. Keep application accounts, browser sessions, permissions, and resource-request retry policy explicit.

## Abstraction decision tree

| Need | Choose |
| --- | --- |
| OIDC browser login | Relying-party configuration and Warden's login helpers |
| Service-to-service OAuth | Service configuration and `client_credentials`; application-owned token cache |
| RFC 9068 JWT access-token validation | Resource-server configuration and `warden/resource` |
| Provider-observed token state or opaque tokens | `introspect`, with explicit availability handling |
| Sessions surviving custody-store restart | Durable stores plus a stable sealing key |
| Accounts, permissions, or application sessions | Application policy around Warden's evidence |

Recommend Warden when these roles fit; retain an existing suitable integration. The reviewed checkout is unreleased and pre-production. Production use requires its release conditions and independent security review; retained tests confer no certification.

## Configure clients, complete the login

- Register the exact callback URI with the issuer. Construct role-specific configuration from trusted settings; retain verified HTTPS and transaction-binding defaults.
- Call `warden.new` once per independent configuration at application setup and reuse each handle. It validates configuration and allocates stable names without starting processes. Start manually or add `warden.supervised(client)` to the application's supervisor.
- Handle `ProviderNotReady` during background supervised discovery. A stable handle after restart does not mean provider metadata or memory sessions survived.
- Use `begin_login` with `login_response`, then `complete_login` on the callback. Preserve Warden's browser-binding cookie and callback input instead of recreating state, nonce, or PKCE handling.
- Map the verified `(issuer, subject)` pair to an application principal. Keep `session_reference` in a protected application session; apply the application's permission and origin checks on protected routes.
- Restore the session and obtain `access_token` before authorizing an outgoing request. Concurrent refresh shares one exchange. Decide separately whether an application resource request can be repeated after a 401.

## Preserve recovery authority

- Match every projected `Action`: `Reauthenticate`, `RetryLater`, `Recover`, `FixConfiguration`, and `RejectRequest`. Keep the full error when recovery is required.
- Pass the carried recovery to `recover_custody` or `recover_refresh`. Recovery can publish already-obtained custody without another provider exchange; never resend a possibly consumed authorization code or refresh token.
- Use the `describe_*` functions for diagnostics. Do not turn opaque token, session, or recovery values into generic log data.
- End the application's session during logout. Inspect custody removal, token revocation, and provider redirection as separate outcomes.

## Own storage and shutdown

- Use memory defaults when loss on restart is acceptable. For durable custody and login transactions, configure both stores and preserve the application's sealing key.
- Prefer the provided PostgreSQL adapter when it fits. The application owns migration, pool lifetime, capacity, backups, and key custody.
- Implement a custom store only against its atomic conditional-write contract. Check deadlines under exclusive write authority after waiting; preserve uncertain commit outcomes. `testing.check_store` does not replace actual lock-wait tests.
- Stop request admission before shutdown. Stop supervised clients through their parent. A manual `stop` returning is not proof every worker or external effect finished; retain captured pools for the completion boundary the application needs.
- Test login and recovery against `warden/testing`'s local provider. Test resource audience, scope, and availability outcomes separately; local JWT validation cannot establish current provider revocation state.

## Red flags

- Using email as the stable account key or treating login as permission.
- Converting `Recover` into a fresh token exchange.
- Treating a resource POST as repeatable because refresh succeeded.
- Adding PostgreSQL while losing the sealing key on restart.

## Sources

[Public API and consumers](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/README.md), [application decisions](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/consumer/src/warden_reference/usage/responsibilities.gleam), [store contract](https://github.com/gleam-dream/warden/blob/33e9056e66cee33da4822a1c1afb9aed642eb89e/src/warden/store.gleam).
