---
name: fabric
description: Build and debug typed LLM agents and conditional graphs with Fabric. Use for application tools, policy, approvals, retained run state, cancellation, uncertain effects, and recovery in Gleam applications.
---

# Fabric

Choose Fabric when a tool waits for approval or a lost runner must resume from retained actions and outcomes on Erlang/OTP; that justifies a store, live context and recovery owner.

Use Hex `fabric` 0.5 with `json_blueprint >= 2.1.1`; retain `manifest.toml`. Its PostgreSQL adapter stays Git+path.

## Abstraction decision tree

```text
Need one application-controlled model call? → LLM Wire
Need retained execution with tools or conditional control? → Fabric
├── Model chooses actions → agent
└── Application chooses routes and state transitions → graph
Need durable queue admission and scheduling? → Job queue
Need explicit workflow compensation? → Saga
```

## Build the ordinary path

1. Write one builder function that makes the spec: each tool from its `tool.Definition` and typed handler, the model, an explicit policy, and turn, concurrency, model-call and tool-body bounds (no whole-agent deadline). Pass it to `agent.build_with` (`agent.build` is deprecated) and handle its errors.
2. Start the store; keep adapter resources under their owner's lifecycle.
3. Start with a retained `RunId`, live context, prompt and correlation; a stable id lets a retry find the run.
4. Read `fabric.snapshot` actions before treating a final answer as business success.

Use `llm.model` or `llm.configured_model`; a deterministic `model.Model` serves offline checks. A graph binds typed state, operations and routes with `graph.new`, validated by `graph.build`.

## Keep agents out of process copies

Runs, tool bodies and model calls run in separate processes, and sent values are copied whole. Fabric builds a `build_with` agent in each process and gives a tool's task only that tool.

- Capture small values the same for every run: a client, settings, ids loaded once. Never capture built tools or codecs; capture a `build_with` sub-agent.
- Make subjects, names, and tables outside the builder; one made inside is remade per process.
- Another name or version is refused (`AgentUnbuildable`), but `open`, `recover` and the sweeper ignore captures. A per-run capture makes a per-run agent: re-derive it from the run and recover those runs yourself.
- A `Run` handle holds the built agent: send the id and `open` it there.
- Follow the [json_blueprint codec practice](https://github.com/lostbean/json_blueprint/blob/main/docs/CODEC-PRACTICE.md): child codecs inside their fields; run-time enums built in the field and checked with `codec.check`.

## Declare effect meaning

- A definitely failed effect is `tool.Explain`; a possibly completed one is `tool.Uncertain`, reconciled from external evidence before dependent work.
- Enable `with_replay` only for reads or idempotent writes keyed by run and action identity.
- Keep graph selection, acceptance, codecs and request preparation pure.

## Retain recovery authority

- Match status variants; denied or failed actions may precede `Finished(Completed(answer))`.
- An await timeout or dropped handle cancels nothing; cancel explicitly.
- Approval binds the exact action, current policy and configured verifier.
- Use a database backend in production and supervise its recovery worker.
- Retain an applied marker where a result must be incorporated once.

## Red flags

- Retrying an uncertain mutation to discover whether it succeeded.
- Marking every tool replayable or equating a final answer with successful effects.
- Reusing approval after changing arguments, policy, or requirements.
- Assuming per-call timeouts supply a whole-agent deadline.
- Sending built agents, handles, tools or codecs to other processes per request.
- Treating a queued run reference as the owner of Fabric recovery.

## Verify

Pin the dependency graph. Check lifecycle claims with scripted models and the waiting, approval, and reconciliation consumers; bound `erts_debug:flat_size/1` of what crosses processes when agents are large.

## Sources

[HexDocs](https://hexdocs.pm/fabric/0.5.0/) · [Public API](https://github.com/gleam-dream/fabric/tree/main/src/fabric) · [Usage topics](https://github.com/gleam-dream/fabric/tree/main/examples/usage) · [Design and pending scope](https://github.com/gleam-dream/fabric/blob/main/docs/design/design.typ)
