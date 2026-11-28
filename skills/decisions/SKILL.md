---
name: decisions
description: Build and debug decision points with Decisions, where a policy lets a recommendation proceed or asks a person and a gated tool receives it at most once. Use for policies, verdicts, consults, bundles, and the memory, OTP, and PostgreSQL stores.
metadata:
  library: gleam-dream/decisions
  library-ref: 13d76cc5910acb7740b6f8b490d76069c7bc3a27
  not-in-library: grind.submit_in
---

# Decisions

Choose Decisions where an output must not reach the world unchecked: some cases proceed, the rest go to a person, and an append-only record shows who decided what. Workflows belong to Saga, jobs to Grind, agent loops to Fabric.

## Terms and stores

- A point declares the output codec, verdicts, and facts a policy may read. A desk binds it to a gated tool, a policy read in the transaction, and a storage port.
- A policy is versioned data: ordered rules, and `otherwise`, who is asked by default. Each recommendation (an output with signals) becomes one occurrence.
- A verdict is given on a card from `decisions.open` or `decisions.resume`. A consult asks another point first. A bundle groups occurrences proposed together.

```text
Which store holds the record?
├─ Tests in one process → decisions/memory
├─ Processes; rows lost when the owner stops → decisions_otp/store, runtime after it under RestForOne
└─ Durable record → decisions_postgres, with Grind running its workers
```

## Declare, decide, release

- Add `decisions = ">= 0.2.0 and < 0.3.0"` from Hex; take `decisions_otp` at tag `decisions_otp-v0.2.0` and `decisions_postgres` at tag `decisions_postgres-v0.3.0` from `gleam-dream/decisions`, path `integrations/<package>`. Match pog and pgo to Grind's exact ranges.
- Declare each fact with one source: `decisions.fact` (output), `decisions.signal` (recommendation), or `decisions.answer` (consulted point). `recommend` refuses an undeclared or mistyped signal with `InvalidFacts`.
- Build policies with `policy.new`; check `decisions.publishable` before storing one. Treat an unknown fact as a person: a condition over an absent or mistyped fact stops the reading and asks `otherwise`. Proceeding needs a rule that holds.
- Use `policy.known` on purpose: it is never unknown, so `All([policy.known(x), ..])` skips its rule when `x` is absent. `When(Not(policy.known(answer)), Consult(point))` consults until answered.
- Wire `decisions.consulting`; the consulted point's gated tool calls `decisions.inform`.
- Admit with `recommend_once` under a key from the trigger, prefixed per point. Call `decisions.happened`, then `decisions.expect`, in the trigger's transaction.
- Release only through the executor: it receives an opaque `Released` at most once, inside the verb's transaction. Write the tool's rows on that transaction; for outside effects write an instruction keyed by `decisions.key` and record its fate with `decisions.report`.
- Keep guards on transaction and subject, world checks in `decisions.checking`, thresholds in the policy. Keep `ToolRefused` with `decisions.record_refusal` in a second transaction; retry `ToolUnsure`.
- Read client text with `view.verdict` or `wire.parse`: strict, bounded, numbers exact.
- Admit bundles with `decisions.recommend_bundle` or, across points, `decisions.recommend_member`. The follower reads `decisions.members`; once `decisions.is_complete` holds, it recommends the follow-on under a key from the bundle.

## Transactions and runtimes

- Run every verb inside a helper's opaque `Tx`: `memory.transaction`, decisions_otp's `store.transaction`, or `decisions_postgres.transaction`, `decisions_postgres.transaction_with`, `decisions_postgres.refusing`, `decisions_postgres.decide`. Helpers take the store or the `Pool` from `decisions_postgres.pool`, never a `Tx`; inside a body, an OTP or PostgreSQL helper opens a separate transaction.
- Put your own statements in `transaction_with`, on `decisions_postgres.connection`, at READ COMMITTED; run `grind.submit_in` there too.
- Roll back on every refusal; redeliver by `decisions.handling`.
- Run `decisions_postgres.migrate` at deploy with a DDL role; its migration 2 must precede any 0.3.0 node's writes. Migrate Grind separately.
- Register `decisions_postgres.wake_worker`, and `decisions_postgres.settlement_worker` for points named by `decisions_postgres.following`, before Grind starts; then `decisions_postgres.sweep`. Followers use `decisions.read_record`: a record ended before it began is `NotBegun`.
- Call models through `isolated.model`, bounding time and heap.

## Red flags

- A later proceeding rule expected to catch an unknown fact.
- An uncertain outside effect retried blindly.
- A 0.3.0 node writing to a database at migration 1.
- `decisions/memory` shared by concurrent processes.

## Sources

[HexDocs](https://hexdocs.pm/decisions/) · [README](https://github.com/gleam-dream/decisions), [migration](https://github.com/gleam-dream/decisions/blob/main/docs/MIGRATION.md), [PostgreSQL](https://github.com/gleam-dream/decisions/tree/main/integrations/decisions_postgres), [OTP](https://github.com/gleam-dream/decisions/tree/main/integrations/decisions_otp), [ADRs](https://github.com/gleam-dream/decisions/tree/main/docs/adr).
