# Inspect an existing Gleam service

Use an existing release console/RPC surface when it fits. The optional
[bundled tools](../tools/beam/README.md) supply missing runtime mechanics.
Applications own diagnostic projections, pool access, domain operations and
recovery. Keep domain decisions and transaction policy in Gleam; use narrow
externals for BEAM mechanisms.

## Configure the runtime

Ordinary Gleam startup is unnamed. `gleam shell` starts another VM. Distribution
belongs in the actual service launcher, without compiler changes. Preserve its
bootstrap and readiness checks. Keep builds, explicit migrations and database
recovery as separate invocations. Do not export service flags through shared
`ERL_FLAGS`, `ERL_AFLAGS` or `ERL_ZFLAGS`.

Give the service a predictable name and clients unique hidden names. For local
or host-contained attachment, use a long name such as `service@127.0.0.1`.
Match naming mode and the complete host suffix. Bind distribution to loopback
with `-kernel inet_dist_use_interface '{127,0,0,1}'` and scope
`ERL_EPMD_ADDRESS=127.0.0.1` to the service/client invocations. Inspect actual
listeners: a running EPMD daemon retains its original bindings. Do not expose
public distribution ports or add an HTTP evaluation endpoint.

Build the bundled client with the consumer's OTP, then preserve its real entry
point. These paths and bootstrap names are illustrative:

```sh
./beam-tool run service@127.0.0.1 -noshell -pa /app/lib/*/ebin -s service_boot main
./beam-tool rpc service@127.0.0.1 erlang node '[]' 2000
./beam-tool console service@127.0.0.1
./beam-tool iex service@127.0.0.1
```

IEx needs compatible Elixir/IEx modules on the target and client. A laptop
installation cannot supply target modules. Package Recon on the target when
using it. Keep Erlang attachment available. The compiled RPC client needs no
source checkout or compiler command at inspection time; IEx retains its runtime
evaluation machinery.

Same-user local processes normally share their cookie file automatically.
Verify HOME, ownership and private file modes without printing cookie contents.
For deployment, use the platform secret store or a protected mounted file. Import
it as the service user with `BEAM_COOKIE_FILE=/run/secrets/beam-cookie ./beam-tool cookie`.
Never put a cookie value in argv, source control or logs. A root-owned mount
needs a private service-owned copy before dropping privileges. Secret rotation
must keep service and clients aligned and can require a restart.

## Select the deployed instance

Enter an explicitly selected existing instance/container as the service user,
then attach inside its network namespace. Record environment, instance, image,
region and service state. Verify the actual instance identifier, Unix user and
HOME. Root's cookie home can differ from the service user's. Creating a new
instance or running a console task in another container inspects different state.

Fly is one transport adapter:

```sh
flyctl machine list --app APP
flyctl ssh console --app APP --machine MACHINE_ID --user SERVICE_USER
id
printf '%s\n' "$FLY_MACHINE_ID" "$HOME"
/app/ops/beam-tool rpc service@127.0.0.1 erlang node '[]' 2000
```

For scripts, use the same explicit Machine/user selection with `--command` and
one-shot RPC. Other platforms use their existing instance-selection and remote
execution tools. Preserve the same identity checks and loopback boundary.
Read-only inspection does not authorize deployment, secret provisioning or restart.

## Inspect without exposing application data

Confirm the exact target before operations. The bundled RPC client does this
with `erpc:call/5`; it bounds the call and checks top-level application errors.
Use reviewed projection functions for automated output. Successful arbitrary
RPC values are not redacted. Keep diagnostics out of application logs unless
they satisfy the application's existing allowlisted logging contract.

| Question | Evidence |
| --- | --- |
| Where is memory concentrated? | VM categories, top few process heaps/binaries and ETS sizes. |
| Is work accumulating? | Repeated mailbox lengths and reductions for selected processes. |
| What is blocked? | Status and stack MFAs, omitting argument values. |
| What owns the behavior? | Existing registered names, selected supervisor children and retained references. |
| What tables matter? | ETS owner, protection, type, size and memory; no default content enumeration. |

Bound enumeration and output as well as RPC time. Discover generated names on
the target, preserving `$` suffixes. A client-rendered remote PID has a
client-relative node number; resolve names on the target or use target-generated
PID text with an explicit contract. Never start another pool to obtain a handle.

Read the pinned actor implementation before using `sys`. `gleam_otp` 1.3.0
supports state inspection, suspend and resume, but lacks `replace_state`, code
change, termination and GenServer debug requests. `get_status` includes private
state and dictionary data. State inspection is not a metadata default;
suspension can block dependants. Mutation belongs to the owning public API.

After narrowing a hypothesis, use Recon resource rankings or selected MFA/PID
call tracing. Require an event cap and a target-owned deadline that survives
client disconnect. Keep arguments, return values and message bodies out of
automated evidence. Coordinate exclusive tracing ownership, preserve other
operators' instrumentation, and verify cleanup afterward. A client-side timeout
is not a trace watchdog. The generic RPC client supplies no tracing lifecycle.

Disconnect the client, never the target: Erlang Ctrl-G then `q`, or IEx Ctrl-C
twice. Verify service health afterward. Do not evaluate target `halt()`,
`init:stop()` or `System.halt()`.

## Optional Voyager MCP

Voyager is useful for desktop or agent exploration of process/ETS metadata. Its
reviewed connector requires OTP 27+ and the target `compiler` application because
it compiles and loads an in-memory helper. This is an additional requirement
beyond precompiled RPC. Its SSH connector needs ordinary SSH routing; a provider
CLI console is not automatically that route. Keep desktop connectivity optional.

Connect an MCP client to the operator-local `http://127.0.0.1:4040/mcp` and
discover current schemas. Check `node_info.node` against the intended target
before each probe. Coordinate against desktop connection switching: these checks
cannot atomically bind a sequence to one target. Use exact-target RPC when that
guarantee matters. Do not expose the local MCP endpoint publicly.

Start with `process_list` arguments:

```json
{"limit": 5, "sort_by": "memory", "attrs": ["memory", "reductions", "message_queue_len"]}
```

Use `ets_list` for metadata. A small returned limit does not bound a whole-node
scan. Truncation budgets are not redaction. State, messages, dictionaries,
labels and ETS values can contain credentials or customer content. Even the
complete `process_info` response exceeds a reviewed metadata projection.
Voyager supplies neither domain repair policy nor a database transaction API.

## Investigate and repair the database

Use the application's existing transaction API when investigating its pool.
Discover the real pool name and inspect the pinned adapter. Keep the entire
transaction inside one checkout: `BEGIN` in one RPC and a query in another can
use different connections. A separate SQL client is appropriate when the target
has no suitable transaction surface. Supply credentials privately, never a URL
in argv. Use one `psql -X --set ON_ERROR_STOP=1` session:

```sql
BEGIN READ ONLY;
SET LOCAL statement_timeout = '1s';
SET LOCAL lock_timeout = '250ms';
SET LOCAL idle_in_transaction_session_timeout = '2s';
SHOW transaction_read_only;
-- Require on before running investigation queries.
SELECT pg_backend_pid();
ROLLBACK;
```

Bound selected columns and rows. Explicitly roll back before checkin; discard
the connection if rollback fails. READ ONLY does not authorize functions with
external side effects. Keep Squirrel SQL and Cigogne migration ownership when
the consumer uses them. Never alter applied migration hashes or recovery holds.

Prefer public domain APIs for deliberate repair. Preserve validation,
notifications, concurrent commit rules and external-effect evidence. A timeout
does not prove an operation failed; reconcile uncertainty before retrying.
Rehearse SQL mechanics only on disposable data in one connection:

```sql
BEGIN;
SET LOCAL statement_timeout = '1s';
SET LOCAL lock_timeout = '250ms';
SELECT to_regclass('pg_temp.inspection_rehearsal') IS NULL AS fresh_name;
-- Require true before proceeding.
SAVEPOINT before_probe;
CREATE TEMP TABLE inspection_rehearsal (id text PRIMARY KEY, value text NOT NULL);
INSERT INTO inspection_rehearsal VALUES ('inspection-only', 'before');
UPDATE inspection_rehearsal SET value = 'after'
WHERE id = 'inspection-only' AND value = 'before'
RETURNING id, value;
-- Require exactly one affected row and the exact expected values.
UPDATE inspection_rehearsal SET value = 'unexpected'
WHERE id = 'inspection-only' AND value = 'before'
RETURNING id, value;
-- Require zero affected rows for the stale expected value.
ROLLBACK TO before_probe;
SELECT to_regclass('pg_temp.inspection_rehearsal') IS NULL AS rolled_back;
-- Require true, then end the outer transaction.
ROLLBACK;
```

A real repair additionally requires exact domain keys, suitable locks and
postconditions before a deliberate commit decision. The generic client cannot
establish those invariants. The [Dash integration patch](../research/dash-inspection.patch)
contains its typed, Squirrel-generated pool probes and executable rollback checks.

## Diagnose connection failure

| Observation | Next probe |
| --- | --- |
| No EPMD registration | Verify the actual service launcher and naming; do not start a second service. |
| Wrong instance/user | Compare selected instance ID, image, Unix user and HOME. |
| Authentication failure | Check selected cookie owner/mode without exposing contents; `nodedown` alone is inconclusive. |
| Naming mismatch | Match short/long mode and full target name. |
| Refusal/timeout | Check host-local EPMD and distribution listeners; opening public ports is no remedy. |
| Missing export/IEx | Verify packaged target modules and code paths; use Erlang fallback. |
| Responsive actor times out on `sys` | Inspect its pinned system-message support. |
| Query transaction state differs | Verify one checked-out connection for the complete transaction. |

Test stopped-node and wrong-cookie failures on disposable services. Verify
console/RPC, diagnostics, target trace cleanup after interruption, database
rollback and disconnect survival. Qualify the packaged image separately from
local tests and actual deployment. See [evidence and source identities](../research/live-inspection.md)
for what has run; the current Fly deployment still lacks attachment prerequisites.
