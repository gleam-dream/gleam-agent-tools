---
name: gleam-inspect
description: Inspect Gleam services on BEAM locally or in deployment. Use for console attachment, RPC, Voyager MCP, process/ETS diagnostics, Recon tracing, database investigation, and repair boundaries. Building actor protocols belongs to gleam-otp.
---

# Inspect live Gleam services

Use when source and logs cannot explain growing mailboxes, memory concentration, missing children, or database waits. Compare bounded observations against one question. Runtime access does not establish domain commit evidence.

## Abstraction decision tree

```text
What evidence answers the question?
├── Health or known application fact → Existing health/log/domain surface
├── Repeatable agent/script probe → Release RPC or erpc:call/5
├── Private interactive exploration → Attached Erlang shell; IEx if packaged
├── Process/ETS exploration through MCP → Optional Voyager
├── Narrow call/resource hypothesis → Recon with target-owned cleanup
└── Persistence question → Existing pool checkout or one SQL client session
```

## Reach the existing VM

- Reuse release tools. Ordinary Gleam starts unnamed; `gleam shell` creates another VM. Configure distribution in the service launcher, preserving its bootstrap. Keep naming flags out of compiler, migration, recovery, and shared `ERL_FLAGS` variables.
- Give services predictable names and clients unique hidden names. Match naming mode and full target. Bind host-contained distribution and EPMD to loopback; verify actual listeners because existing EPMD retains its bindings.
- Enter an explicitly selected existing host/container/instance as the service user, then attach inside its network namespace. Verify environment, instance, image, user, HOME, and target node. Replacement instances inspect different state. Keep public distribution ports and HTTP evaluation endpoints closed.
- Same-user local processes normally share their cookie file. Deployment secrets need a service-owned private cookie file (0400/0600); provision privileged mounts before dropping privileges. Never print cookies or pass them in argv. Root SSH and the service user can have different cookie homes.

## Select the inspection surface

- For scripts, confirm `erpc:call(Target, erlang, node, [], 2000) == Target`, then call a reviewed metadata projection with a finite timeout. Check transport failure and application `Error` separately; exit nonzero with sanitized errors. Bound enumeration and output. Never pipe automation into IEx.
- Package Recon on the target when used. IEx needs compatible Elixir/IEx modules on the target as well as the client; retain Erlang-shell fallback. Compile RPC helpers during build so baseline inspection needs no compiler or checkout.
- Optional Voyager requires OTP 27+ and the target `compiler` application: it compiles and loads an in-memory helper. Its local MCP endpoint defaults to `http://127.0.0.1:4040/mcp`. Discover tools; confirm `node_info.node` before each probe and coordinate against connection switching. Start with five numeric `process_list` rows and `ets_list` metadata. Limits cap output, not scans. Budgets truncate; they do not redact. State, messages, dictionaries, labels, and ETS contents require private investigation. Keep host-local RPC independent.

## Preserve ownership

- Discover registered names and generated `$` suffixes on the target. Read the pinned actor: `gleam_otp` 1.3.0 supports state inspection but lacks `replace_state` and GenServer debug tracing. State is private; repair through public Gleam APIs. Keep domain decisions and transaction policy in Gleam behind narrow runtime externals.
- Compare memory, mailbox lengths, reductions, stack MFAs, supervisor children, and ETS ownership. Omit arguments, bodies, and raw state. Trace only selected MFAs/PIDs with an event cap, deadline, exclusive ownership, and target-side cleanup after disconnect. Verify cleanup; do not clear another operator's trace.
- Keep database work in one checkout/session: explicit transaction, verified READ ONLY, statement/lock/idle limits, rollback before return. Preserve Squirrel/Cigogne ownership where used. Rehearse repairs only on disposable data with exact keys, expected values, affected-row checks, RETURNING, and verified rollback. Preserve recovery holds and external-effect evidence.

## Verification and red flags

Verify attachment, RPC, diagnostics, rollback, disconnect survival, and stopped-node/wrong-cookie failures. Record local, packaged, and deployed results separately. Disconnect the client; never halt the target. A timeout leaves mutation outcome uncertain. Missing modules, wrong users/cookies, naming mismatches, and unavailable listeners need distinct probes; opening public ports is no remedy.

## Sources

[Distribution](https://www.erlang.org/doc/system/distributed.html), [RPC](https://www.erlang.org/doc/apps/kernel/erpc.html), [Recon](https://hexdocs.pm/recon/recon_trace.html), [Voyager connection requirements](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/docs/connecting_to_a_node.md).
