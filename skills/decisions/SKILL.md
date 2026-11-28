---
name: decisions
description: Build and debug decision points with Decisions, where a policy lets a recommendation proceed or asks a person and a gated tool receives it at most once. Use for policies, verdicts, consults, bundles, and the stores.
metadata:
  library: gleam-dream/decisions
  library-ref: c822fa66400765034c782ae304013dfbecee0986
  not-in-library: grind.submit_in
---

# Decisions

Choose Decisions where an output must not reach the world unchecked: some cases proceed, the rest go to a person, and a record shows who decided. Workflows belong to Saga, jobs to Grind, agents to Fabric.

## Terms and stores

- A point declares the output codec, verdicts, and readable facts. A desk binds it to a gated tool, a policy and a store.
- A policy is versioned data: ordered rules and `otherwise`, who is asked by default. A recommendation becomes one occurrence.
- A verdict is given on a card from `decisions.open` or `decisions.resume`. A consult asks another point first. A bundle groups occurrences.

```text
Which store holds the record?
├─ Tests in one process → decisions/memory
├─ Processes; rows lost when the owner stops → decisions_otp/store, runtime after it under RestForOne
└─ Durable record → decisions_postgres, with Grind running its workers
```

## Declare, decide, release

- Take `decisions` from Hex, `decisions_otp` and `decisions_postgres` by Git tag from `gleam-dream/decisions`, path `integrations/<package>`. The migration guide holds ranges and tags.
- Give each fact one source: `decisions.fact` (output), `decisions.signal` (recommendation), or `decisions.answer` (consulted point); others are refused (`InvalidFacts`).
- Build policies with `policy.new`; check `decisions.publishable` first. A condition over an absent or mistyped fact asks `otherwise`; proceeding needs a rule that holds.
- `policy.known` is never unknown: `All([policy.known(x), ..])` skips its rule when `x` is absent; `When(Not(policy.known(answer)), Consult(point))` consults until answered.
- Wire `decisions.consulting`; the consulted tool calls `decisions.inform`.
- Admit with `recommend_once` under a key from the trigger, prefixed per point; call `decisions.happened`, then `decisions.expect`, in the trigger's receiving transaction, before the model runs.
- Release only through the executor: it receives an opaque `Released` at most once, in the verb's transaction, where the tool writes its rows; for outside effects, write an instruction keyed by `decisions.key` and record its fate with `decisions.report`.
- Put world checks in `decisions.checking`, thresholds in the policy. A tool stops with `Refuse`, `Unsure` or `Contended`; `decisions.stop_for` maps refusals. Record `ToolRefused` with `decisions.record_refusal` in a second transaction; retry `ToolUnsure`.
- `decisions.showing` is the rule `open` uses to repeat a showing; a verdict ends it, so `open` then refuses, until another validator's correction lets a new showing open.
- Read client text with `view.verdict` or `wire.parse`.
- Build a bundle item with `vocabulary.item`, which refuses an empty name or slash. Admit bundles with `decisions.recommend_bundle` or, across points, `decisions.recommend_member`. A member's id is `decisions.member_key`, "bundle/item"; percent-encode it in a URL path. The follower reads `decisions.members`; once `decisions.is_complete` holds, it recommends the follow-on under a bundle key.

## Transactions and runtimes

- Run every verb inside a helper's opaque `Tx`: `memory.transaction`, `store.transaction` (decisions_otp), or `decisions_postgres.transaction`, `transaction_with`, `refusing`, `decide`. Helpers take the store or `Pool`, never a `Tx`. Inside a body, a nested `memory.transaction` rolls back with the outer body's error; other helpers open a separate transaction.
- Put your own statements and `grind.submit_in` in `transaction_with`, on `decisions_postgres.connection`.
- Roll back on every refusal; redeliver through `decisions.handling`.
- Read a committed head outside verbs with `store.head` or `decisions_postgres.head`; `inspection().head` is test-only.
- Run `decisions_postgres.migrate` at deploy with a DDL role before any node writes. Migrate Grind apart.
- Before Grind starts, register `decisions_postgres.wake_worker`, and `decisions_postgres.settlement_worker` for points from `decisions_postgres.following`; then `decisions_postgres.sweep`.
- Run verbs in your worker's Grind settlement through `decisions_postgres.with_settlement`.
- Call models through `decisions_otp`'s `isolated.model`.

## Red flags

- A later proceeding rule expected to catch an unknown fact.
- A blind retry of an uncertain effect.
- A node writing to a database at migration 1.
- Routing cards through `inspection()`.
- `decisions/memory` shared across processes.

## Sources

[HexDocs](https://hexdocs.pm/decisions/) · [README](https://github.com/gleam-dream/decisions), [migration](https://github.com/gleam-dream/decisions/blob/main/docs/MIGRATION.md), [ADRs](https://github.com/gleam-dream/decisions/tree/main/docs/adr).
