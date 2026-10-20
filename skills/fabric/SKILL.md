---
name: fabric
description: Build and debug typed LLM agents and conditional graphs with Fabric. Use for application tools, policy, approvals, retained run state, cancellation, uncertain effects, and recovery in Gleam applications.
---

# Fabric

Use Fabric when model-selected actions or application-controlled graphs need bounded execution and retained outcomes on Erlang/OTP. Preserve an existing runtime when its contract fits.

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

1. Define native input and output codecs. Create each `tool.Definition`, then bind its typed handler before combining heterogeneous tools.
2. Build an agent with a model, tool list, and explicit policy. Set useful turn, concurrency, model-call, and tool-body bounds; handle `agent.build` errors before starting.
3. Start the selected store. Allocate HTTP/database resources only when the chosen adapters require them; keep borrowed resources under their application owner's lifecycle.
4. Start with a retained `RunId`, live context, prompt, and correlation. Use a stable application identity when retried admission must find the existing run.
5. Await or inspect status. Read action records from `fabric.snapshot` before treating a final answer as business success.

Use `llm.model` for a Wire-backed model or `llm.configured_model` for fixed generation settings. Supply a deterministic `model.Model` callback for offline checks. Fabric owns request assembly and transcript replay; supply live credentials and settings again on reconstruction.

For a graph, define typed state, operations, acceptance, and routes. Bind the definition to its store, context factory, and policy with `graph.new`; validate with `graph.build` before `graph.start`.

## Declare effect meaning

- Classify a definitely failed effect as `tool.Explain`; the model can receive that failure and continue.
- Classify a possibly completed effect as `tool.Uncertain`. Reconcile it from external evidence before allowing dependent work to continue.
- Enable `with_replay` only for reads or application-idempotent writes. Key repeated effects by stable run and action identity; correlation is for observation.
- Keep graph selection, acceptance, codecs, and request preparation pure. Put effects in the execution operations that record their outcomes.

## Retain recovery authority

- Match status variants explicitly. `Finished(Completed(answer))` records a model answer; denied or failed actions may precede it.
- Treat an await timeout or dropped handle as a caller observation. Cancel explicitly when that is the intended lifecycle; remote effects can still require reconciliation.
- Bind approval to the exact action and current policy. Reconstruct fresh context and use the configured verifier; changed arguments need fresh approval.
- Choose storage for the failure model. In-memory records disappear on stop; directory storage covers process/VM restart on one host. Use a database backend for production power-loss durability and supervise its recovery worker.
- Keep application admission and result incorporation explicit. Retain an applied marker where a business transaction must incorporate a run result once; preserve unapplied results when pruning.

## Red flags

- Retrying an uncertain mutation to discover whether it succeeded.
- Marking every tool replayable or equating a final answer with successful effects.
- Reusing approval after changing arguments, policy, or requirements.
- Assuming per-call timeouts supply a whole-agent deadline.
- Treating a queued run reference as the owner of Fabric recovery.

## Verify

Pin the resolved dependency graph. Check changed lifecycle claims with scripted models and the existing waiting, approval, and reconciliation consumers; provider calls do not validate recovery semantics.

## Sources

[Public API](https://github.com/gleam-dream/fabric/tree/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/src/fabric) · [Usage topics](https://github.com/gleam-dream/fabric/tree/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/examples/usage) · [Design and pending scope](https://github.com/gleam-dream/fabric/blob/815fc5971e0ae8e7783f122e1ee00a7e50c08de7/docs/design/design.typ)
