---
name: gleam-inspect
description: Inspect existing Gleam services dynamically on BEAM. Use for remote attachment, one-shot expressions/RPC, Voyager MCP and ad hoc investigation with minimal runtime setup.
---

# Inspect live Gleam services

Inspect dynamically through existing runtime APIs. Setup normally needs only a node name, cookie access and private connectivity. Reuse release tools.

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

- Name only the service VM at runtime; preserve its bootstrap. Ordinary Gleam starts unnamed; `gleam shell` creates another VM. Keep naming flags out of compiler, migration/recovery commands and shared `ERL_FLAGS`.
- Use predictable service names and unique hidden clients. Match naming mode and host suffix. Bind host-contained distribution/EPMD to loopback; verify listeners because existing EPMD retains its bindings.
- Enter an explicitly selected existing instance as the service user, inside its network namespace. Confirm environment, image, user, HOME and exact node. Keep distribution private; add no HTTP evaluation endpoint.
- Same-user processes normally share their cookie file. Provision deployed cookies privately with service ownership and mode 0400/0600. Never print cookies or put them in argv. Root SSH may use another cookie home.

## Investigate dynamically

- Use native functions, library APIs or temporary expressions. Add no application inspection modules, committed diagnostic SQL, generated queries, migrations or HTTP routes. Production persistence conventions do not require generation for ad hoc investigation.
- Confirm the exact target, use finite timeouts and bound evidence. Use Erlang `erpc` or release RPC for automation; never pipe interactive IEx. Distinguish unnamed nodes, naming/cookie/user mismatches, wrong instances, unavailable ports and missing exports without printing secrets.
- Discover registered names and exports; preserve `$` in names and `@` in compiled modules. Resolve names on the target; printed remote PIDs are client-relative, not reusable target PID text.
- Select memory, mailbox lengths, reductions, stack MFAs, supervision and ETS metadata. Exclude credentials, customer content, messages and raw state from automation. Limits do not redact values.
- IEx needs compatible target modules; retain Erlang fallback. Optional Voyager needs OTP 27+ and target `compiler`. Discover MCP schemas at local `http://127.0.0.1:4040/mcp`; verify `node_info.node` and coordinate desktop switching. Small results do not bound whole-node scans.
- Use Recon when justified. Scope MFA/PID tracing, cap events and duration, and arrange target-side cleanup after disconnect. Preserve other operators' instrumentation.

## Preserve ownership

Investigate the database read-only by default. Keep one connection for the explicit transaction; verify READ ONLY, set statement/lock limits and roll back before returning it. Discard a connection if rollback fails. Use a separate SQL client when the pool lacks suitable dynamic access.

Rehearse SQL repairs on disposable data with exact keys, expected old values, affected-row checks, RETURNING and rollback before a deliberate commit. Read-only SQL grants no authority to invoke external effects.

Check pinned actor support: `gleam_otp` 1.3.0 lacks `replace_state` and debug tracing. `sys:get_status` can expose state/dictionaries; suspension can block dependants. Repair through existing domain APIs or separately authorized SQL. Preserve invariants, migration ownership and recovery holds. Timeout proves neither failure nor cancellation.

## Verification and red flags

On a disposable service, check exact-target attachment, an expression, disconnect survival and useful stopped-node/wrong-cookie failures. Keep fixtures outside application code. Distinguish local, packaged and deployed evidence. Disconnect the client; never halt the target.

Red flags: fixed SQL probes, schema changes, inspection subsystems or required new application APIs.

## Sources

[Distribution](https://www.erlang.org/doc/system/distributed.html), [RPC](https://www.erlang.org/doc/apps/kernel/erpc.html), [dynamic expressions](https://www.erlang.org/doc/apps/stdlib/erl_eval.html), [Recon](https://hexdocs.pm/recon/recon_trace.html), [Voyager requirements](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/docs/connecting_to_a_node.md), [PostgreSQL transactions](https://www.postgresql.org/docs/current/sql-begin.html).
