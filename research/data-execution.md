# Data and execution guide research

Researched on 2026-10-20. This pass created six consumer skills: `grind`, `saga`, `sinal`, `json-blueprint`, `gleam-sql`, and `gleam-pubsub`. Each is one self-contained `SKILL.md`. Package consumers own business policy and compose the capabilities. The collection adds no composition recipes, mandatory router, or OpenAPI guidance.

## Source method and identities

Read the reference collection's `ecto`, `otp`, and `oban` skills at `/tmp/gleam-agent-research-elixir/plugins/elixir-dev/skills/`. Their useful pattern is direct triggers, abstraction choice, concrete rules, and red flags. Their wording and Elixir semantics were not transplanted.

Re-read current local READMEs, package configuration, selected public modules, designs, and real consumers. Local revision identities came from `git rev-parse HEAD`:

| Package | Revision | Consumer inspected |
| --- | --- | --- |
| Grind 0.1.0 | `bcd4b9205392596bbb3c60cd94d0c251e5072110` | `consumer/{README.md,gleam.toml}`; `examples/usage/{gleam.toml,src/grind_usage/transactions.gleam}` |
| Saga 0.1.0 | `c09b7a7c72148fcaf73fea96cb595ccf16a56e7b` | `examples/order_consumer/{README.md,gleam.toml,src/order_consumer/usage/committed_effect.gleam}`; `integrations/saga_postgres/README.md` |
| Sinal 0.1.0 | `58c6e7dea08abccd9f187d16b9ef5f9bb86eb769` | `examples/usage/{gleam.toml,src/sinal_usage.gleam}` |
| JSON Blueprint, manifest 1.7.1 | `45b361628af9d464a1670e8789b82a4dc310604f` | `examples/{gleam.toml,src/examples/optional_fields.gleam}` |

The first three identify themselves as unreleased/unpublished. JSON Blueprint's modern codec, contract, and generator surface is unreleased despite its unchanged version field. This distinction is retained in the skill.

Selected local evidence includes Grind's facade and `docs/design/CONTEXT.typ`; Saga's facade, `durable`, memory/file public modules, and `docs/design/durability/design.typ`; Sinal's event and forwarder modules and observation vocabulary; JSON Blueprint's codec module and root design. The earlier [execution research](../../gleam-agent-tools-research/second-pass/execution-data.md) indexes further inspected ADRs and retained tests. A test body read is source evidence, never a new passing run.

## Fresh primary web reads

These URLs returned primary content through the web tool in this pass:

- [Squirrel 4.7.0](https://squirrel.hexdocs.pm/): generation conventions, live schema dependency, check command, supported types, and nullable parameter limitation.
- [Cigogne 5.0.6](https://cigogne.hexdocs.pm/): migration history, hashes, library inclusion, configuration, and nontransactional option.
- [Pog 4.1.0](https://pog.hexdocs.pm/pog.html), including `#transaction` and `#returning`: runtime resource, transaction, and result-decoding contracts.
- [Native telemetry 1.4.2](https://telemetry.hexdocs.pm/telemetry.html): inline dispatch and callback failure removal. Sinal forwarding remains Sinal's own contract.
- [Published JSON Blueprint](https://hex.pm/packages/json_blueprint) and [upstream README](https://github.com/lostbean/json_blueprint): package identity and published/unreleased distinction. The GitHub page includes older OTP documentation, so it is not substituted for the inspected checkout's runtime identity.
- [Whisper upstream README](https://github.com/webermarci/whisper), [Roar upstream README](https://github.com/webermarci/roar), and [Roar 0.1.0 overview](https://hexdocs.pm/roar/): experimental status and intended scope.

Direct opens of `https://whisper.hexdocs.pm/`, `https://whisper.hexdocs.pm/index.html`, `https://hexdocs.pm/whisper/`, `https://roar.hexdocs.pm/`, and `https://roar.hexdocs.pm/index.html` failed. GitHub pages supplied a fresh primary refresh instead. Direct web opens of `https://github.com/gleam-dream/{grind,saga,sinal}` also failed with cache misses; their availability and semantics are attributed to local source. A direct Grind pinned README open failed too. These failures are not evidence that the packages are unavailable.

## Fresh external source reads

GitHub connector file reads supplemented documentation. They returned the following exact sources:

| Repository and revision | Actual fetched file URL | Blob identity |
| --- | --- | --- |
| Squirrel `5b6407d14a7c83af102944f2c86f52a521a74d57` | [src/squirrel.gleam](https://github.com/giacomocavalieri/squirrel/blob/5b6407d14a7c83af102944f2c86f52a521a74d57/src/squirrel.gleam) | `b55bf468faad76b139f206c9acf130e676dac552` |
| Squirrel, same revision | [numeric snapshot](https://github.com/giacomocavalieri/squirrel/blob/5b6407d14a7c83af102944f2c86f52a521a74d57/test/birdie_snapshots/numeric_decoding.accepted) | `89bdf50d14fa4584d9e8d059e4d3e8632bed2ef6` |
| Cigogne `229ea13f6c1736a7ea6f56f314a808bb1d315bda` | [src/cigogne.gleam](https://github.com/Billuc/cigogne/blob/229ea13f6c1736a7ea6f56f314a808bb1d315bda/src/cigogne.gleam) | `b9f09f0f17724b342d0ec14e100597242f65b0b6` |
| Cigogne, same revision | [gleam.toml](https://github.com/Billuc/cigogne/blob/229ea13f6c1736a7ea6f56f314a808bb1d315bda/gleam.toml) | `b583e7cb5a2e0abf1876a33fe95c93fd071d0f78` |
| Pog `611d9947244c94867e0b596a939e83e3c76d582b` | [src/pog.gleam](https://github.com/lpil/pog/blob/611d9947244c94867e0b596a939e83e3c76d582b/src/pog.gleam) | `2cb6c615309af5ebdd66d1b9aca8d005ceaf25f1` |

Pog's revision was resolved from the actual [v4.1.0 tag ref endpoint](https://api.github.com/repos/lpil/pog/git/ref/tags/v4.1.0). An initial `Billuc/pog` file lookup returned 404; the docs' repository link correctly identifies `lpil/pog`.

Cigogne's fetched manifest says 5.0.5; the refreshed published docs say 5.0.6. They remain distinct source identities. The older research also inspected the published archive, but this pass does not claim to have fetched that archive anew. Source confirms transaction chunks around disabled-transaction migrations despite a broader comment claiming universal atomicity.

Squirrel's implementation visits `src`, `test`, and `dev`, while its introductory prose emphasizes `src`. The guide gives the ordinary application convention without asserting exclusive traversal. Its numeric snapshot produces `Float`. Snapshots were read, not executed.

Pub/sub sources were re-read from the already materialized primary files under `/private/tmp/gleam-guide-pubsub-20261020`:

| Package | Revision | Files inspected |
| --- | --- | --- |
| Whisper 0.2.0 | `d98a7fa9ded4f58706f767c519a1db3a099e76bc` | `gleam.toml`, `src/whisper.gleam`, `src/whisper_topic.erl`, `src/whisper_ffi.mjs` |
| Roar 0.1.0 | `4852f5396459f93b389f8663538558301a4b0595` | `gleam.toml`, `src/roar.gleam`, `src/roar_ffi.erl` |

The [retained source identities](../../gleam-agent-tools-research/second-pass/external-source-identities.json) give the original fetched blob provenance. Fresh GitHub READMEs agree on the API-generation distinction. The guide's source links point to those inspected revisions rather than an unspecified release.

## Rules and their evidence

| Guide | Decision changed by the source | Evidence and limitation |
| --- | --- | --- |
| Grind | Retain a pending command after a lost reply; do not substitute a new key. | Public README and facade distinguish submission receipts from uniqueness and permanent business idempotency. No new database run. |
| Grind | Treat `submit_in` as staged and READ COMMITTED; preserve uncertainty through cancellation. | Public transaction example, facade, and vocabulary. The application owns outer commit and investigation. |
| Grind | Budget runtime capacity and retention explicitly. | Public facade documents pool ownership, extra renewal connections, local queue capacity, pruning, and non-total wait budgets. |
| Saga | Reuse a typed definition and keep local lifetime distinct from durable progress. | Public facade and consumer. Builder executes once; local execution needs no codec/storage. |
| Saga | Missing checkpoint cannot prove missing effect. | Public durable evidence variants and committed-effect consumer. Application evidence resolves interrupted work. |
| Saga | Match storage and wakeups to the application's failure model. | Public memory/file modules, durability design, and PostgreSQL adapter README. No power-loss or failover certification. |
| Sinal | Assume inline handlers until forwarding is selected. | Public `emit`, forwarder operational contract, native telemetry docs. Forwarding drops rather than falling back. |
| Sinal | Own source-defined atom names, enum completeness, and registration lifetimes. | Public event contract and observation vocabulary. An attachment ID is not a generation token. |
| JSON Blueprint | Choose source identity before imports; preserve the wire contract. | Local README/config and fresh publication page. Published 1.7.1 differs from modern checkout. |
| JSON Blueprint | Keep absent/null/value and exact numeric representation distinct. | Codec contract and real optional-field consumer. Strict parser guarantees do not transfer to native parser bridges. |
| JSON Blueprint | Admit the finite schema profile and bounded parsing deliberately. | Codec module, README limits, and design non-goal. Draft label alone does not establish full JSON Schema support. |
| SQL | Generate against intended schema; preserve query execution and decoder failure as separate facts. | Squirrel source and fresh docs; Pog tagged public source. No new PostgreSQL-backed checks. |
| SQL | Keep applied migration history and selected transaction scope. | Cigogne public source and fresh docs. Disabled-transaction sections require a narrower atomicity claim. |
| Pub/sub | Reject the current unqualified Roar/Whisper pair. | Roar calls removed `whisper.new` and old arities; Whisper 0.2 exposes topic values. Permissive range does not establish source compatibility. |
| Pub/sub | Own callback and stale-handle lifetimes per target. | Whisper native sources and retained focused probes. Local registry, replacement, and callback execution differ by target. |
| Pub/sub | Avoid total-memory, cleanup, or exactly-once promises. | Per-subscription buffer and Roar bridge source. Cross-node behavior was not executed. |

## Validation performed and remaining limits

- Verified every created skill has one file, matching directory/name, only `name` and `description` frontmatter, an abstraction decision tree, concrete rules, red flags, and primary source links.
- Ran a Python mechanical check of frontmatter fields, directory/name matching, file count, required sections, balanced tree fences, 45–75-line bounds, and <=650-word bounds. All six passed. Integration review subsequently qualified Saga's reporting-handle completion and Blueprint's inner-codec null behavior; see the [review record](README.md#review-and-corrections).
- Published no runnable API snippets requiring an unexecuted compilation claim. SQL CLI commands are checked against refreshed official docs and generator source.
- Created no new prototypes. The specific pub/sub mismatch and lifecycle claims already have [focused probe evidence](../../gleam-agent-tools-research/second-pass/pubsub-experiments.md). That experiment bypassed dependency resolution and used stdlib 1.0.5 outside Whisper's declared `<1.0.0` range. It establishes the named source mismatch and observations in that environment, not a normally resolved supported pair.
- This drafting pass ran no Gleam, PostgreSQL, multi-node, browser, power-loss, failover, or agent-effectiveness tests. Prior test results are identified as prior evidence. No package production source or dependency constraints were changed.
