---
name: gleam-otp
description: Design and debug typed BEAM processes with gleam_otp and gleam_erlang. Use for actors, subjects, selectors, message protocols, names, supervision, restart dependencies, timeouts, and bounded runtime inspection. Use grind for durable jobs and saga for dependent workflows.
---

# Gleam OTP

Choose processes to own a connection, serialize shared state, run concurrent work, or isolate failure on Erlang/BEAM. Keep stateless calculations as functions; a process earns its lifecycle by owning a runtime responsibility.

## Governing rule

An actor handles one message at a time. Supervision restores processes according to a recovery policy; it does not restore arbitrary business state or undo effects.

## Abstraction decision tree

```text
What runtime responsibility exists?
├── Stateless calculation → Plain function
├── Serialized state or owned resource → Actor with a typed message protocol
├── Fixed supervised children → Static supervisor
├── Runtime-created supervised children → Factory supervisor
└── Work must survive runtime loss → Select a persistence-owning abstraction
```

## Keep the process responsive

- Read the resolved `gleam_otp`/`gleam_erlang` API. Use an explicit message type and public functions that hide request/reply mechanics.
- Keep blocking or slow effects out of a coordinator's message loop when it must respond during that work. Run work under a deliberate owner and route completion, failure, and cancellation back as messages.
- Choose bounds for accepted work, active workers, and waiting messages. A typed subject and synchronous caller do not bound all producers or the mailbox.
- Receive from a subject in its owning process. Use selectors to combine subjects and map their payloads into a coherent protocol.
- Distinguish reply waiting from work cancellation. `process.call` panics on timeout, callee exit before reply, or a missing named process; it does not return a timeout `Error` or prove the request had no effect.

## Encode recovery dependencies

| Child relationship | Static strategy |
| --- | --- |
| Independent children | `OneForOne` |
| Children must recover together | `OneForAll` |
| Later children depend on earlier children | `RestForOne` |

- Start prerequisites before dependants. Choose restart tolerance and shutdown behavior from the recovery contract; inspect the child's retained references after a restart.
- A direct subject can retain an exited process. A named subject can resolve a replacement, but the protocol and recovery semantics must still agree.
- Allocate a bounded set of names at startup and pass them down. Names use atoms; creating names from unbounded input can exhaust the VM's atom table.
- Treat links, monitors, and supervision as distinct mechanisms. Decide whether a worker's failure should propagate to its caller or become a handled message.

## Verify and inspect

Exercise the protocol's failure path, timeout, restart, and retained client handle where relevant. Confirm that a restarted process can recover the state its caller expects.

When inspecting actors, check system-operation support against the pinned implementation. In `gleam_otp` 1.3.0, the focused probe reads state but `sys:trace` times out. Use bounded diagnostics; treat inspected state as private and mutate through the owning public API.

## Red flags

- An actor introduced only to organize functions.
- Network work blocks the only process handling cancellation.
- A call timeout triggers an unconditional retry of an external effect.
- A supervisor restarts a dependency while dependants retain unusable handles.
- GenServer debugging features assumed to work for every Gleam actor.

## Sources

[Actors](https://gleam-otp.hexdocs.pm/gleam/otp/actor.html), [subjects and calls](https://gleam-erlang.hexdocs.pm/gleam/erlang/process.html), [static supervision](https://gleam-otp.hexdocs.pm/gleam/otp/static_supervisor.html), [factory supervision](https://gleam-otp.hexdocs.pm/gleam/otp/factory_supervisor.html).
