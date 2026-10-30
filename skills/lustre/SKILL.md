---
name: lustre
description: Build and debug Lustre interfaces with Model-View-Update. Use for UI state, large applications, flow boundaries, shared drafts, forms, views, effects, asynchronous responses, subscriptions, browser components, static rendering, and server-component lifetimes. Keep transport and durable application state under their own contracts.
---

# Lustre

Explicit model/message transitions make interfaces inspectable and reproducible.

## Governing rule

Keep `init`, `update`, and `view` deterministic for the same inputs. Return external work as effects and observations as messages. Gleam does not enforce purity.

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

## Model the interaction and organize the application

- Represent meaningful states with variants: idle, pending, success, or failure as needed. Preserve form input and validation feedback until the intended transition completes.
- Decode event payloads at ingress into typed messages describing DOM events and external results. Let `update` choose the next model and effect. Compose internal behavior with ordinary functions; never recursively call `update` with fabricated messages.
- Correlate asynchronous results with requests or model revisions. Ignore superseded responses and messages for departed flow instances; arrival order is not request order.
- Put navigation in URLs when reloads and shared links must reproduce it. Keep transient interaction details in the model.
- Split around data ownership, invariants, and lifetimes, rather than line counts. Extract modules that hide internals or separate responsibilities.
- Keep one authoritative copy of shared state and surviving session/context with the coordinating model; pass flows only needed data. Use a `Screen` variant for mutually exclusive flows whose local state can be discarded on navigation.
- Distinct flows with independent state can own `Model`, `Message`, `init`, `update`, and `view`. The root delegates updates, maps child messages, and owns routing and handovers within one runtime.
- Steps editing one draft share one model with step views and transformation functions. A lookup with timers and requests can own a submachine.
- Extract view functions before adding component runtimes. Components require independent encapsulation or lifetime.

## Manage effects and lifetimes

- Use effect-returning `init`/`update` with `lustre.application`.
- For complex coordination, consider application-defined `Command` values for requests and handovers such as `SignedIn`, returned as `#(Model, List(Command))`. This optional Effect pattern differs from Lustre's `Effect(Message)`; simpler flows can return native effects and explicit outcomes.
- With commands, the root applies shared transitions; a live interpreter converts requests into Lustre effects. Replay applies transitions without executing requests.
- Do not rely on `effect.batch` ordering. Sequence dependent work through result messages or one sequencing effect.
- Install long-lived event sources through managed effects and own cleanup. `effect.subscribe`/`unsubscribe` handles parent DOM context. Measure DOM during paint; ordinary effects may precede rendering.
- Separate browser APIs from portable transitions. Server components ignore browser paint effects; shared source does not guarantee compatibility.
- Decide whether server runtimes serve one client or several. Authorize connections/messages, register/deregister clients, and own shutdown. Runtimes are separate from WebSocket servers and may outlive connections.

## Verification

Test message sequences through flow handovers, draft preservation, delayed responses, and failures; inspect returned commands when used. Lustre simulation discards effects: injected messages test interpretation. Verify requests, subscriptions, DOM behavior, and cleanup in their real runtime.

## Red flags

- Executing requests, timers, or random reads inside `view` or `update`.
- Components created for file size; duplicated shared drafts; recursive message dispatch.
- Stale responses overwrite current state; shared runtimes leak private state.
- Simulation presented as proof of effect execution or cleanup.

## Sources

[Core API](https://lustre.hexdocs.pm/lustre.html), [state](https://lustre.hexdocs.pm/guide/02-state-management.html), [effects](https://lustre.hexdocs.pm/lustre/effect.html), [server components](https://lustre.hexdocs.pm/lustre/server_component.html), [simulation](https://lustre.hexdocs.pm/lustre/dev/simulate.html).

Architecture examples: [Elm SPA](https://github.com/rtfeldman/elm-spa-example), [Effect pattern](https://discourse.elm-lang.org/t/realworld-example-app-architected-with-the-effect-pattern/5753), [module boundaries](https://elm-radio.com/episode/life-of-a-file/). These inform application design; they are not Lustre requirements.
