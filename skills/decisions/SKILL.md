---
name: decisions
description: Build and debug decision points with Decisions, where a policy lets a recommendation proceed or asks a person and a gated tool receives it at most once. Use for policies, verdicts, consults, bundles, and the stores.
metadata:
  library: gleam-dream/decisions
  library-ref: c822fa66400765034c782ae304013dfbecee0986
  not-in-library: grind.submit_in
---

# Decisions

Choose Decisions where an output must not reach the world unchecked: some cases proceed, the rest go to a person, and an append-only record shows who decided. Workflows belong to Saga, jobs to Grind, agent loops to Fabric.

## Terms and stores

- A point declares the output codec, verdicts, and readable facts. A desk binds it to a gated tool, a policy, and a storage port.
- A policy is versioned data: ordered rules and `otherwise`, who is asked by default. A recommendation (an output with signals) becomes one occurrence.
- A verdict is given on a card from `decisions.open` or `decisions.resume`. A consult asks another point first. A bundle groups occurrences.

```text
Which store holds the record?
├─ Tests in one process → decisions/memory
├─ Processes; rows lost when the owner stops → decisions_otp/store, runtime after it under RestForOne
└─ Durable record → decisions_postgres, with Grind running its workers
```

## Declare, decide, release

- Add `decisions = ">= 0.3.0 and < 0.4.0"` from Hex; take `decisions_otp` at tag `decisions_otp-v0.3.0` and `decisions_postgres` at tag `decisions_postgres-v0.4.0` from `gleam-dream/decisions`, path `integrations/<package>`.
- Give each fact one source: `decisions.fact` (output), `decisions.signal` (recommendation), or `decisions.answer` (consulted point); `recommend` refuses others (`InvalidFacts`).
- Build policies with `policy.new`; check `decisions.publishable` before storing. A condition over an absent or mistyped fact stops the reading and asks `otherwise`; proceeding needs a rule that holds.
- `policy.known` is never unknown: `All([policy.known(x), ..])` skips its rule when `x` is absent; `When(Not(policy.known(answer)), Consult(point))` consults until answered.
- Wire `decisions.consulting`; the consulted point's tool calls `decisions.inform`.
- Admit with `recommend_once` under a key from the trigger, prefixed per point; call `decisions.happened`, then `decisions.expect`, in its transaction.
- Release only through the executor: it receives an opaque `Released` at most once, in the verb's transaction. Write the tool's rows on that transaction; for outside effects, write an instruction keyed by `decisions.key` and record its fate with `decisions.report`.
- Put world checks in `decisions.checking`, thresholds in the policy. A tool stops with `Refuse`, `Unsure` or `Contended`; `decisions.stop_for` maps a nested refusal. Keep `ToolRefused` with `decisions.record_refusal` in a second transaction; retry `ToolUnsure`.
- `decisions.showing` is the rule `open` uses to repeat a showing; a verdict ends it, so `open` then refuses.
- Read client text with `view.verdict` or `wire.parse`.
- Build each bundle item with `vocabulary.item`, which refuses an empty name or a slash. Admit bundles with `decisions.recommend_bundle` or, across points, `decisions.recommend_member`. A member's id is `decisions.member_key`, "bundle/item"; percent-encode it in a URL path. The follower reads `decisions.members` and, once `decisions.is_complete` holds, recommends the follow-on under a key from the bundle.

## Transactions and runtimes

- Run every verb inside a helper's opaque `Tx`: `memory.transaction`, decisions_otp's `store.transaction`, or `decisions_postgres.transaction`, `decisions_postgres.transaction_with`, `decisions_postgres.refusing`, `decisions_postgres.decide`. Helpers take the store or `Pool`, never a `Tx`; inside a body they open a separate transaction.
- Put your own statements, and `grind.submit_in`, in `transaction_with`, on `decisions_postgres.connection`.
- Roll back on every refusal; redeliver through `decisions.handling`.
- Read a committed head outside verbs with `store.head` or `decisions_postgres.head`; `inspection().head` is test-only.
- Run `decisions_postgres.migrate` at deploy with a DDL role, before any node writes (migration 2). Migrate Grind apart.
- Register `decisions_postgres.wake_worker`, and `decisions_postgres.settlement_worker` for points from `decisions_postgres.following`, before Grind starts; then `decisions_postgres.sweep`. Followers use `decisions.read_record`.
- Run verbs in your worker's Grind settlement through `decisions_postgres.with_settlement`.
- Call models through `isolated.model`.

## Red flags

- A later proceeding rule expected to catch an unknown fact.
- A blind retry of an uncertain effect.
- A node writing to a database at migration 1.
- Routing cards through `inspection()`.
- `decisions/memory` shared across processes.

## Sources

[HexDocs](https://hexdocs.pm/decisions/) · [README](https://github.com/gleam-dream/decisions), [migration](https://github.com/gleam-dream/decisions/blob/main/docs/MIGRATION.md), [ADRs](https://github.com/gleam-dream/decisions/tree/main/docs/adr).
