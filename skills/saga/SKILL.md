---
name: saga
description: Build and debug typed workflows with Saga. Use for dependent steps, parallel work, retries, undo, compensation, cancellation, checkpointing, and interrupted-effect recovery.
metadata:
  library: gleam-dream/saga
  library-ref: 39490d2fff1ed8e06baa4beee040689f1c1ad00a
---

# Saga

Choose Saga when dependent effects need coordinated scheduling, parallel branches, undo, compensation, or retained partial progress. Use `Result` sequencing for short operations and one database transaction for changes it covers.

## Abstraction decision tree

```text
Does the operation need workflow coordination?
├─ Short sequence → Result composition
├─ All changes fit one database transaction → Transaction
└─ Coordinated effects or partial-effect recovery → Saga
   ├─ Owner-bound execution → saga/execution; no storage or codecs
   └─ Execution must outlive its owner → saga/durable
      ├─ Store lifetime only → Memory storage
      ├─ One VM and restartable files → File storage
      └─ Shared PostgreSQL persistence → saga_postgres
```

## Define once, execute with input

- Add the latest `saga` release on Erlang; inspect the resolved revision and public modules.
- For PostgreSQL, add `saga_postgres` from Git (`gleam-dream/saga`, path `integrations/saga_postgres`), pinned by commit to the newest `saga_postgres-v*` tag accepting the resolved core.
- Build a reusable workflow with `define`, whose builder runs once; supply each request as input. Connect steps through typed ports with `perform`, `both`, `all`, and `choose`.
- Keep external clients and policy in supplied callbacks. Use `effect` when a step needs its `EffectKey`; pass its idempotency key to an enforcing provider.
- Use `undo` for known completed work and `compensate` to choose a failed attempt's retry, replacement, abort, or hold.
- Mark possibly completed errors with `unknown_when`; crashes and timeouts are already unknown. A `compensate` decision still applies: `Abort` rolls back. When no decision settles an unknown outcome, `on_unknown` does: default `Reconcile` ends the run `Unresolved` without undo; `RollBack` undoes. A timeout alone cannot justify replay or rollback.
- Retain the typed terminal report with its cleanup failures and unknown-effect evidence; match each `AttemptFailure` an `Unresolved` holds. Render `outcome.summary` only for display; a `CoordinatorCrashed` cause is uncertain.
- Keep every `Config` and step bound under 49.7 days; longer ones fail as `DurationTooLong` or, at `define`, `InvalidTimeout`. `execution.Infinity` lifts only the run deadline and default step timeout.

## Own execution and recovery

- Cancel and `await` unfinished local `start` handles before dropping them. With `start_reporting`, receive the terminal report and monitor the coordinator; `await` returns `NotOwner`.
- Use `reporting.run_owned` inside a per-invocation worker; its receiver monitors after return. `on_stopped` runs in a separate guarded worker. `rollback_within` bounds owner-loss startup waits and notification, not total execution; keep captured resources alive.
- For durable execution, add versioned root/step codecs and recovery resolvers, give one business execution one stable ID, and call `start_or_reconnect` with compatible definition and identical encoded input.
- Resolve interrupted admitted actions from authoritative evidence: `Completed` restores a result, `NotSent` must prove absence, `MaybeSent` suspends. A missing or eventually consistent lookup proves nothing.
- Keep effect keys stable across attempts and recovery; a fresh local run's keys deduplicate no other run's effects.
- Keep application and checkpoint commits separate, even on one database; an absent checkpoint cannot prove the application write rolled back.
- Own wakeups, `durable.list` discovery per phase, and redelivery; durable storage starts no scheduler. A drive timeout kills its in-flight attempts; the next `drive` resumes from the last checkpoint.
- Match storage to the failure model. Memory loses progress with its store/VM; file storage requires an existing canonical absolute directory and one VM, without power-loss durability. With `saga_postgres`, own and supervise the borrowed pool, migrate once, and plan retention. Use a pooled handle, not a transaction-scoped connection.

## Red flags

- Step names used as an untyped result dictionary.
- Request-specific state captured in a shared definition builder.
- Refunding a possibly completed charge without evidence.
- Retrying an interrupted callback because no checkpoint exists.
- New execution IDs on every delivery.
- Claiming atomicity because effects and checkpoints share a pool.

## Sources

[HexDocs](https://hexdocs.pm/saga/) · [Consumer](https://github.com/gleam-dream/saga), [reporting](https://github.com/gleam-dream/saga/blob/main/src/saga/reporting.gleam), [durability](https://github.com/gleam-dream/saga/blob/main/src/saga/durable.gleam), [PostgreSQL](https://github.com/gleam-dream/saga/tree/main/integrations/saga_postgres), [upgrades](https://github.com/gleam-dream/saga/blob/main/docs/MIGRATION.md).
