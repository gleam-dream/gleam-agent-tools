---
name: hellhound
description: Integrate OIDC login, OAuth tokens, and access-token validation with Hellhound on Erlang/OTP. Use for authorization-code callbacks, token custody, refresh, permission checks from current claims, resource servers, introspection, durable authentication stores, and logout.
metadata:
  library: gleam-dream/hellhound
  library-ref: 13c65db507acabaef7e5515ca2e6bcce5561fdce
---

# Hellhound

Choose Hellhound to sign users in or hold provider tokens; it handles discovery, key rotation, shared refresh, and custody. Applications own accounts, sessions, permissions, and resource retries. Keep adequate existing integrations.

## Abstraction decision tree

- OIDC browser login: relying-party login helpers.
- Service-to-service OAuth: `client_credentials` and an application-owned token cache.
- RFC 9068 JWT access tokens: `hellhound/resource`.
- Provider token state or opaque tokens: `introspect`, handling availability.
- Sessions surviving a store restart: durable custody and a stable sealing key.
- Permissions from roles in ID claims: `current_identity` with a `claims_age`.

Add the latest `hellhound` on Erlang. For PostgreSQL, add `hellhound_postgres` from Git (`integrations/hellhound_postgres`), pinned to the newest `hellhound_postgres-v*` tag accepting the resolved core. Hellhound is uncertified; deployment needs a security review.

## Configure clients, complete the login

- Register the exact callback URI; build configuration from trusted settings, keeping HTTPS defaults.
- Call `hellhound.new` once per configuration, reusing the handle, started directly or under `hellhound.supervised`.
- Handle `ProviderNotReady` during supervised discovery; a restarted handle keeps no metadata or memory sessions.
- `begin_login` seals the pending login into the cookie `login_response` sets. On the callback, call `complete_login`, then pass any response through `callback_response`, which only expires that cookie. Never recreate state, nonce, or PKCE.
- Map the verified `(issuer, subject)` to a principal, keep `session_reference` in a protected session, and check permission and origin per protected route.
- Get `access_token` before each outgoing request; repeating a resource request after a 401 is a separate decision.
- For JWT assertions or discovery-free token requests, supervise a `hellhound/exchange` client; `perform` sends at most one request, and the application owns reuse and retries.
- In a signing JWK for `hellhound/assertion`, omit an unused `alg` or `kid`.

## Authorize from current claims

- Decide claim-based permissions through `current_identity(client, session, claims_age)`, typed on `Current`; `session_identity` decides nothing. A missing roles claim means no roles.
- Build each bound once with its own client's `claims_age`; request `offline_access` so a stale read can renew.
- Confirm the provider re-evaluates claims and returns an ID token on refresh, or stale reads are denied.
- Recheck a long-lived connection per message; close it once its claims pass the bound.

## Preserve recovery authority

- Match every `Action`: `Reauthenticate`, `RetryLater`, `Recover`, `FixConfiguration`, `RejectRequest`. Keep the full error for recovery; call `logout` before re-login, else keep the session.
- Pass carried recovery to `recover_custody` or `recover_refresh`; never resend a possibly consumed code or refresh token.
- Diagnose with `describe_*`; never log token, session, or recovery values.
- On logout, end the application's session; custody removal, revocation, and redirection are separate.

## Own storage and shutdown

- Use memory defaults when restart loss is acceptable, otherwise durable custody storage. Share one stable sealing key across nodes that start or complete logins or read custody; rotate through `with_previous_sealing_keys`, keeping each old key for a login lifetime and while custody records sealed with it exist.
- With `hellhound_postgres`, the application owns migration, pool lifetime, capacity, backups, and key custody.
- For a custom store, honor the atomic conditional-write contract: check deadlines under exclusive write authority after waiting, and keep uncertain commits. `testing.check_store` replaces no lock-wait tests.
- Stop admission before shutdown, and supervised clients through their parent; a returned `stop` does not prove workers finished, so keep captured pools alive.
- Test login and recovery against `hellhound/testing`, and resource audience, scope, and availability separately; local validation cannot show revocation.

## Red flags

- Using email as the account key, or treating login or `session_identity` as permission.
- Converting `Recover` into a fresh token exchange.
- Repeating a resource POST because refresh succeeded.

## Sources

[HexDocs](https://hexdocs.pm/hellhound/) · [README](https://github.com/gleam-dream/hellhound/blob/main/README.md), [responsibilities](https://github.com/gleam-dream/hellhound/blob/main/consumer/src/hellhound_reference/usage/responsibilities.gleam), [authorization](https://github.com/gleam-dream/hellhound/blob/main/consumer/src/hellhound_reference/usage/authorization.gleam), [store](https://github.com/gleam-dream/hellhound/blob/main/src/hellhound/store.gleam).
