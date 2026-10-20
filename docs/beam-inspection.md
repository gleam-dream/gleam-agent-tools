# Lightweight runtime inspection

The service supplies a reachable BEAM node. The operator supplies the question
and ad hoc expressions. Start with its existing release console/RPC commands.
The optional [generic client](../tools/beam/README.md) fills a missing client
surface without application inspection modules, diagnostic SQL files or routes.

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

Inside that selected host, use native Erlang/IEx attachment or a generic client.
A compiled operator client may be copied temporarily to the host; it need not
be added to the application's source tree or image. Match the selected OTP and
keep client names unique. Verify `node()` after attachment.

## One-shot dynamic investigation

For a single exported function:

```sh
./beam-tool rpc service@127.0.0.1 erlang system_info '[process_count]' 2000
```

For an ad hoc expression, send its source on stdin to a one-shot client:

```sh
./beam-tool eval service@127.0.0.1 2000 <<'ERLANG'
Pid = whereis(code_server),
erlang:process_info(Pid, [memory, message_queue_len, reductions, current_function]).
ERLANG
```

Expressions run on the confirmed target through OTP's `erl_eval`; no application
module is created or compiled. Temporary expression files can be private operator
input. They are not a catalogue of probes to commit to the application. The client
has full operator authority, including mutation; it is not a sandbox. Select safe
fields in each expression. Value/output caps do not redact sensitive data, and
an expression can perform I/O. Never send untrusted input for evaluation.

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
