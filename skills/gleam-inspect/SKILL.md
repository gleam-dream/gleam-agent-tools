---
name: gleam-inspect
description: Inspect existing Gleam services dynamically on BEAM. Use for remote attachment, one-shot expressions/RPC, Voyager MCP and ad hoc investigation with minimal runtime setup.
---

# Inspect live Gleam services

Make the runtime reachable, then investigate dynamically. Setup normally needs only a node name, cookie access and private connectivity. Reuse release tools.

## Abstraction decision tree

```text
What does the operator need?
├── Existing health/log evidence answers it → Use that surface
├── Interactive investigation → Attach Erlang; IEx if already available
├── Agent/script investigation → One-shot dynamic expression or exported-function RPC
├── Process/ETS exploration through MCP → Optional Voyager
└── Database investigation → Ad hoc query through an existing connection API/client
```

## Make the smallest setup change

- Name only the service VM at runtime, preserving its bootstrap. Ordinary Gleam starts unnamed; a new `gleam shell` starts another VM. Keep service flags out of compiler, migration and recovery commands and shared `ERL_FLAGS` variables.
- Use predictable service names and unique hidden client names. Match naming mode and host suffix. Bind host-contained distribution/EPMD to loopback; existing EPMD retains its bindings, so verify listeners.
- Enter an explicitly selected existing host/container/instance as the service user, then attach inside its network namespace. Confirm environment, instance, image, user, HOME and exact target node. Keep distribution private; do not add an HTTP evaluation endpoint.
- Same-user local processes normally share their cookie file. Provision deployed cookies privately with correct service ownership and mode 0400/0600. Never print them or put them in argv. Root SSH can use a different cookie home.

## Investigate dynamically

- Use native runtime functions, existing library APIs or temporary operator expressions. Do not add application inspection modules, checked-in diagnostic SQL, generated queries, migrations or HTTP routes. Production persistence conventions do not require code generation for an ad hoc investigation.
- Confirm the exact target before executing a one-shot expression or RPC. Give calls finite timeouts and return bounded evidence. Parse/evaluate expressions through a trusted operator client; never pipe automation into interactive IEx. A generic client belongs to the operator tooling and can be temporary on the host.
- Discover registered names and generated `$` suffixes at runtime. Select process memory, mailbox lengths, reductions, stack MFAs, supervision and ETS metadata for the question. Omit credentials, customer content, message bodies and raw state from automated output. Output limits do not redact values.
- IEx needs compatible Elixir/IEx modules on the target too; retain Erlang fallback. Optional Voyager requires OTP 27+ and the target `compiler` application for its in-memory helper. Its local MCP endpoint defaults to `http://127.0.0.1:4040/mcp`; discover schemas and verify `node_info.node`. Coordinate against desktop connection switching. Start with small metadata results; limits do not bound whole-node scans.
- Use Recon when available and justified. Scope tracing by MFA/PID, cap events and duration, and arrange target-side cleanup after disconnect. Preserve another operator's instrumentation. This is temporary instrumentation, not an application feature.

## Preserve ownership

Keep database investigation ad hoc and read-only by default. Use one connection for the whole explicit transaction; verify READ ONLY, set suitable statement/lock limits, then roll back before returning it. If the existing pool cannot support this dynamically, use a separate SQL client. Do not add a query module to make inspection possible.

Inspect the pinned actor before using `sys`; `gleam_otp` 1.3.0 lacks `replace_state` and GenServer debug tracing. Deliberate repair uses existing public domain APIs or separately authorized transactional SQL. Preserve invariants, migration ownership and recovery holds. Timeout does not prove an effect failed or stopped.

## Verification and red flags

Check exact-target attachment, an ad hoc expression, disconnect survival and useful stopped-node/wrong-cookie errors on a disposable service. Keep validation fixtures outside application code. Distinguish local, packaged and deployed evidence. Disconnect the client; never halt the target.

Red flags: fixed SQL probes, schema changes, inspection subsystems or required new application APIs.

## Sources

[Distribution](https://www.erlang.org/doc/system/distributed.html), [RPC](https://www.erlang.org/doc/apps/kernel/erpc.html), [dynamic expressions](https://www.erlang.org/doc/apps/stdlib/erl_eval.html), [Recon](https://hexdocs.pm/recon/recon_trace.html), [Voyager requirements](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/docs/connecting_to_a_node.md).
