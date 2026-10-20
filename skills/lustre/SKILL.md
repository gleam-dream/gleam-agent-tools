---
name: lustre
description: Build and debug Lustre interfaces with Model-View-Update. Use for UI state, forms, views, effects, asynchronous responses, subscriptions, browser components, static rendering, and server-component lifetimes. Keep transport and durable application state under their own contracts.
---

# Lustre

Model interface state explicitly and return managed effects for the runtime to execute.

## Governing rule

Keep `init`, `update`, and `view` deterministic for the same inputs. Move external work into effects and return its observations as messages. Gleam's type checker does not enforce purity.

## Abstraction decision tree

```text
What does the interface need?
├── Static HTML → Render elements without starting a UI runtime
├── Browser state with no managed effects → lustre.simple
├── Browser state plus external work → lustre.application
├── Reusable presentation → Ordinary view function
├── Independent encapsulated state/lifetime → Browser component
└── Server-owned interactive state → Server component + explicit transport owner
```

## Model the interaction

- Represent meaningful states with variants: idle, pending, success, or failure as the domain requires. Keep form input and validation feedback available until the intended transition completes.
- Keep shared state in the model that owns its coordination. Extract view functions before adding independent component runtimes; a component needs an actual encapsulation or lifetime reason.
- Translate DOM events and external results into typed messages. Decode event payloads at ingress and let `update` decide the next model and effect.
- Associate asynchronous results with the request or model revision they belong to. Ignore obsolete results when a newer request supersedes them; arrival order is not request order.
- Put navigation state in the URL when reloads and shared links must reproduce it. Keep transient interaction details local to the model.

## Manage effects and lifetimes

- Use effect-returning `init`/`update` with `lustre.application`. Use `effect.none()` when no work is required.
- Do not rely on `effect.batch` ordering. Sequence dependent work through result messages or a single effect with the required sequencing.
- Install long-lived event sources through managed effects and give their owner a cleanup path. `effect.subscribe`/`unsubscribe` handles parent DOM context. Use the paint lifecycle for DOM measurement; ordinary effects can run before the new view is rendered.
- Separate browser APIs from portable state transitions. Server components ignore browser paint effects; a shared source file does not establish runtime compatibility.
- Decide whether a server runtime belongs to one client or several. Authorize connections and messages, register/deregister clients, and own runtime shutdown. The component runtime is separate from the WebSocket server and may outlive every connection.

## Verification

Test transitions with meaningful message sequences, including delayed responses and failures. Lustre simulation discards effects: injected messages test their interpretation, not the actual request, subscription, or DOM behavior. Test those claims in their real runtime.

## Red flags

- HTTP requests, timers, or random reads executed directly by `view` or `update`.
- Components created solely to split a large view file.
- An older response overwrites the latest search or form state.
- A shared server runtime exposes one user's private state to another.
- Simulation success presented as proof of effect execution or browser cleanup.

## Sources

[Core API](https://lustre.hexdocs.pm/lustre.html), [state](https://lustre.hexdocs.pm/guide/02-state-management.html), [effects](https://lustre.hexdocs.pm/lustre/effect.html), [server components](https://lustre.hexdocs.pm/lustre/server_component.html), [simulation](https://lustre.hexdocs.pm/lustre/dev/simulate.html).
