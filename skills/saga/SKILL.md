---
name: saga
description: Build and debug typed workflows with Saga. Use for dependent steps, parallel work, retries, undo, compensation, cancellation, checkpointing, and interrupted-effect recovery.
---

# Saga

Choose Saga when dependent effects need coordinated scheduling, parallel branches, undo, compensation, or retained partial progress. Use ordinary `Result` sequencing for short operations and one database transaction for changes it can cover.

For example, reserve inventory, charge, then release a known reservation if the charge fails. Typed ports connect outputs to inputs without a result-name dictionary; unknown charge outcomes still require evidence before recovery.

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

- Inspect the resolved revision and public modules. Use Hex `saga` 0.2.0 on Erlang with Gleam >=1.18; install `saga_postgres` 0.1.0 from Git ref `saga_postgres-v0.1.0`, path `integrations/saga_postgres`.
- Build a reusable workflow with `define`. Its builder runs once; supply each request as run input. Connect steps through typed ports, using `perform`, `both`, `all`, and `choose`.
- Keep external clients and application policy in supplied callbacks. Use `effect` when a step needs its `EffectKey`; send its stable idempotency key to a provider that enforces it.
- `undo` reverses known completed work; `compensate` chooses a failed attempt's retry, replacement, abort, or hold.
- Mark possibly completed failures with `unknown_when`. Select an explicit uncertainty policy; a transport timeout alone cannot justify replay or rollback.
- Retain the typed terminal report, including cleanup failures and unknown-effect evidence. Render `outcome.summary` for display only. Treat a `CoordinatorCrashed` cause as uncertain.
- Since 0.2.0, run and step bounds above about 49.7 days are refused; lift one with `Infinity`.

## Own execution and recovery

- Own unfinished local `start` handles: cancel and `await` before dropping them. With `start_reporting`, receive the terminal report and monitor the coordinator; `await` returns `NotOwner`.
- Use `reporting.run_owned` inside a per-invocation worker; its receiver monitors after return. `on_stopped` runs in a separate guarded worker. `rollback_within` bounds owner-loss startup waits and notification, not total execution; keep captured resources alive.
- Add versioned root/step codecs and recovery resolvers for durable execution. Give one business execution one stable ID; use `start_or_reconnect` with compatible definition and identical encoded input.
- Resolve interrupted admitted actions from authoritative evidence. `Completed` restores a result; `NotSent` must prove absence; `MaybeSent` suspends. A missing or eventually consistent lookup proves nothing.
- Keep effect keys stable across attempts and recovery. A fresh local run has its own identity and does not deduplicate another run's effects.
- Keep application commits and checkpoint commits separate, even on the same database. An absent checkpoint cannot prove the application write rolled back.
- Own wakeups, unfinished-run discovery, and redelivery. Durable storage starts no scheduler; a drive timeout stops that driver without cancelling saved execution.
- Upgrade every node before 0.2.0 writes checkpoints; 0.1.0 reads `CoordinatorCrashed` checkpoints as malformed.
- Match storage to the failure model. Memory loses progress with its store/VM; file storage requires an existing canonical absolute directory and one VM, without power-loss durability.
- With `saga_postgres`, own and supervise the borrowed pool, migrate once, and plan retention. Use a pooled handle, not a transaction-scoped connection.

## Red flags

- Step names used as an untyped result dictionary.
- Request-specific state captured in a shared definition builder.
- Refunding a possibly completed charge without evidence.
- Retrying an interrupted callback because no checkpoint exists.
- New execution IDs on every delivery.
- Claiming atomicity because effects and checkpoints share a pool.

## Sources

[HexDocs](https://hexdocs.pm/saga/0.2.0/) · [Public workflow and consumer](https://github.com/gleam-dream/saga/tree/v0.2.0), [reporting lifetime](https://github.com/gleam-dream/saga/blob/v0.2.0/src/saga/reporting.gleam), [durability contract](https://github.com/gleam-dream/saga/blob/v0.2.0/src/saga/durable.gleam), [PostgreSQL adapter](https://github.com/gleam-dream/saga/tree/saga_postgres-v0.1.0/integrations/saga_postgres).
