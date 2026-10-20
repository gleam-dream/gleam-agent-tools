# Live inspection guidance: scope and evidence

The collection distributes text guidance for standard Erlang, IEx and optional
Voyager workflows. The bundled runtime client, launcher and their tests have
been removed. The [operator guide](../docs/beam-inspection.md) documents native
commands; the compact skill remains self-contained.

Service setup normally needs only runtime naming, protected cookie access and
private connectivity. Investigations use existing APIs and ad hoc expressions.
They do not create application inspection modules, diagnostic SQL files,
generated queries or migrations. Validation scripts remain temporary.

## Current validation

On 2026-10-20, the documented one-shot `erl`/`erpc` command was extracted from
the guide and run against a disposable VM with the selected OTP 28.5.0.7.
It confirmed the exact target and evaluated a metadata expression there using
only standard runtime functions. No application module or custom client was
installed. The service remained alive after the client exited.

The same command failed with nonzero status for an incorrect cookie and a
stopped node. Cookie contents and remote exception payloads were not printed.
The fixture VM was retired. Temporary probe and log:
`/private/tmp/check-native-inspection-guide.py` and
`/private/tmp/gleam-inspect-text-only.log`.

All 20 skills passed metadata, size and link checks. The changed documentation
has no links or commands requiring the deleted tooling. Earlier custom-client
checks remain historical results in Git (`58b8117`), not current dependencies
or validation commands.

## Retained boundaries and limits

The instrumented Dash pilot was rejected and reverted in `3a19553`, restoring
its tracked tree exactly to `ea45f9505d84f66d5fefeee64f71c13a0173cb98`.
Its patch has also been removed here. Passing pilot tests did not justify its
application-specific inspection APIs or generated SQL.

The earlier read-only Fly observation found an unnamed service and no reachable
EPMD on Machine `287e355a7e2e98`. No subsequent deployment or restart occurred.
The native command's local results do not qualify packaged or deployed access.
Voyager remains source-reviewed at `577706b237899229b7cc496522a58d372157a000`;
no live desktop/MCP session is qualified.

Primary contracts: [distribution](https://www.erlang.org/doc/system/distributed.html),
[RPC](https://www.erlang.org/doc/apps/kernel/erpc.html),
[Voyager connection requirements](https://github.com/software-mansion/voyager/blob/577706b237899229b7cc496522a58d372157a000/docs/connecting_to_a_node.md).
