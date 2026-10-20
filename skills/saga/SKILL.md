---
name: saga
description: Build and debug typed workflows with Saga. Use for dependent steps, parallel work, retries, undo, compensation, cancellation, checkpointing, and interrupted-effect recovery.
---

# Saga

Connect typed steps and preserve the evidence needed to recover partial effects.

## Abstraction decision tree

```text
Does the operation need workflow coordination?
├─ Short sequential calculation → Result composition
└─ Typed dependencies or partial-effect recovery → Saga
   ├─ Owner-bound execution → saga/execution; no storage or codecs
   └─ Execution must outlive its owner → saga/durable
      ├─ Store lifetime only → Memory storage
      ├─ One VM and restartable files → File storage
      └─ Shared PostgreSQL persistence → saga_postgres
```

## Define once, execute with input

- Inspect the resolved revision and public modules. The researched 0.1.0 is unpublished, targets Erlang, and requires Gleam >=1.18.
- Build a reusable workflow with `define`. Its builder runs once; supply each request as run input. Connect steps through typed ports, using `perform`, `both`, `all`, and `choose` as needed.
- Keep external clients and application policy in supplied callbacks. Use `effect` when a step needs its `EffectKey`; send its stable idempotency key to a provider that enforces it.
- Use `undo` to reverse known completed work. Use `compensate` to choose a failed attempt's retry, replacement, abort, or hold. They own different decisions.
- Mark possibly completed failures with `unknown_when`. Select an explicit uncertainty policy; a transport timeout alone cannot justify replay or rollback.
- Retain the typed terminal report, including cleanup failures and unknown-effect evidence. Render `outcome.summary` for display without replacing the report.

## Own execution and recovery

- For a local `start` run, cancel and `await` before dropping an unfinished handle. For `start_reporting`, receive the terminal report and monitor the coordinator; `await` returns `NotOwner`. Use `reporting.run_owned` when a dedicated owner must retain the report.
- Add versioned root/step codecs and recovery resolvers for durable execution. Give one business execution one stable ID; use `start_or_reconnect` with compatible definition and identical encoded input.
- Resolve interrupted admitted actions from authoritative evidence. `Completed` restores a result; `NotSent` must prove absence; `MaybeSent` suspends. A missing or eventually consistent lookup is insufficient proof.
- Keep effect keys stable across attempts and recovery. A fresh local run has a fresh run identity; it does not deduplicate another run's effects.
- Keep application commits and checkpoint commits separate, even on the same database. An absent checkpoint cannot prove the application write rolled back.
- Own wakeups, unfinished-run discovery, and redelivery. Durable storage does not start a permanent scheduler; a drive timeout stops that driver without cancelling saved execution.
- Match storage to the failure model. Memory loses progress with its store/VM; file storage requires an existing canonical absolute directory and one VM. It promises no directory power-loss durability.
- With `saga_postgres`, own and supervise the borrowed pool, migrate once, and plan retention. Use a pooled handle rather than retaining a transaction-scoped connection.

## Red flags

- Step names used as an untyped result dictionary.
- Request-specific state captured in a shared definition builder.
- Refunding a possibly completed charge without evidence.
- Retrying an interrupted callback because no checkpoint exists.
- New execution IDs on every delivery.
- Claiming atomicity because effects and checkpoints share a pool.
- Assuming driver timeout cancelled the saved workflow.

## Sources

[Public workflow and consumer](https://github.com/gleam-dream/saga/tree/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b), [durability contract](https://github.com/gleam-dream/saga/blob/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b/src/saga/durable.gleam), [PostgreSQL adapter](https://github.com/gleam-dream/saga/tree/c09b7a7c72148fcaf73fea96cb595ccf16a56e7b/integrations/saga_postgres).
