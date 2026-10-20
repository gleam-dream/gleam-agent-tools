# Lightweight runtime inspection

The service supplies a reachable BEAM node. The operator supplies the question
and ad hoc expressions. Start with its existing release console/RPC commands.
Use standard Erlang/IEx commands or optional Voyager. This collection supplies
no runtime client, launcher or code to install in the application.

## Minimal service setup

Add a predictable runtime node name to the existing service launch command.
Keep the bootstrap unchanged. For SSH-contained access, a long name such as
`service@127.0.0.1`, loopback distribution and loopback EPMD are sufficient.
Use the service user's normal cookie locally; provision a private service-owned
cookie in deployment. Inspect actual listeners and cookie ownership without
printing its value. Keep naming flags out of shared `ERL_FLAGS`, compiler,
migration and recovery invocations. A fresh `gleam shell` is a separate VM.

No application source change is normally needed. Additional target modules are
conditional: IEx needs compatible Elixir/IEx, Recon is for tracing/resource
questions, and Voyager needs OTP 27+ plus its target compiler application.
Erlang attachment and ordinary OTP introspection remain the baseline.

## Attach to the existing instance

Select the actual instance and service user using the platform's existing remote
access. Confirm instance identity, image, user, HOME and exact node before work.
Attach within its network namespace. Root SSH can select a different cookie
home. Keep distribution private; no public ports or evaluation HTTP endpoint.

For Fly, for example:

```sh
flyctl ssh console --app APP --machine EXISTING_MACHINE_ID --user SERVICE_USER
```

Inside that selected host, use its runtime tools with the service user's cookie.
Match the selected OTP and keep client names unique. For an existing long-name
service, Erlang attachment looks like:

```sh
export TARGET_NODE=service@127.0.0.1
ERL_EPMD_ADDRESS=127.0.0.1 erl -name "console_$$_$(date +%s)@127.0.0.1" \
  -hidden -kernel inet_dist_use_interface '{127,0,0,1}' -remsh "$TARGET_NODE"
```

Verify `node().` inside the Erlang console. IEx can attach with `--name`,
`--hidden` and `--remsh` when compatible target modules are present. Disconnect
Erlang with Ctrl-G then `q`, or IEx with Ctrl-C twice; never halt the target.

## One-shot dynamic investigation

Use a temporary named Erlang VM and `erpc` directly. This command confirms the
exact target, evaluates a small metadata expression there, and exits the client:

```sh
ERL_EPMD_ADDRESS=127.0.0.1 ERL_CRASH_DUMP=/dev/null \
erl -name "inspect_$$_$(date +%s)@127.0.0.1" -hidden \
  -kernel inet_dist_use_interface '{127,0,0,1}' -noshell -eval '
  try
    Target = list_to_atom(os:getenv("TARGET_NODE")),
    Target = erpc:call(Target, erlang, node, [], 2000),
    Value = erpc:call(Target, fun() ->
      erlang:process_info(whereis(code_server),
        [memory, message_queue_len, reductions, current_function])
    end, 2000),
    io:format("~P~n", [Value, 10]),
    halt(0)
  catch _:_ ->
    io:format(standard_error, "Inspection failed~n", []), halt(1)
  end.'
```

For one existing export, use `erpc:call(Target, Module, Function, Arguments, 2000)`.
Form expressions for the current question. They are private operator input, not
a catalogue of probes to commit to the application. Runtime access has full
operator authority, including effects and I/O. Never evaluate untrusted input.
Choose bounded, non-sensitive results; formatting depth does not redact values
or bound remote work. The `halt` calls above run in the client after RPC returns.

Use existing OTP/library APIs to discover processes, supervision, stack MFAs and
ETS ownership dynamically. Keep credentials, message bodies and customer state
out of automated output. Never default to dumping a process or table. Coordinate
tracing ownership and use event/deadline bounds with cleanup that survives client
disconnect. A client timeout does not stop remote work or clean instrumentation.

## Optional Voyager MCP

Point the operator's MCP client at `http://127.0.0.1:4040/mcp` after connecting
Voyager privately. Discover tool schemas and confirm `node_info.node` before
probing. Begin with small `process_list` or `ets_list` metadata results.
Truncation does not redact content or bound a whole-node scan. Coordinate against
desktop connection switching; use exact-target RPC when that distinction matters.
Voyager remains optional and its SSH connector requires an ordinary SSH route.

## Database and repair boundaries

Form queries during the investigation. Use the existing pool's transaction API
within one dynamic operation, or a separate SQL client. A transaction must stay
on one connection. Default to a verified read-only transaction with statement
and lock limits; roll back before returning the connection. Operational inspection
requires no Squirrel query generation, Cigogne migration, schema change or new
application API. Those tools still own actual application persistence changes.

Deliberate repair is a separate authorized operation. Prefer existing domain
APIs; transactional SQL needs exact keys, expected values, affected-row checks
and postconditions. Preserve domain invariants and recovery holds. A timeout
leaves effect outcome uncertain. Check pinned actor support before `sys`:
`gleam_otp` 1.3.0 does not implement state replacement or GenServer debug tracing.

## Verify the access path

Use disposable services to test target identity, an ad hoc expression, console
attachment, disconnect survival and wrong-cookie/stopped-node failures. Keep test
fixtures outside application code. Disconnect the client without halting the
service. Record local, packaged and deployed evidence separately; read-only
inspection does not authorize a deployment or restart.
