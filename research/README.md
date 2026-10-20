# Research and verification

Refreshed October 20, 2026 after the collection's scope and compact format were accepted. All 19 guide scopes have current primary-source coverage. This is a review of the consumer contracts used by the guides, rather than a complete audit of every exported API or package implementation.

## Source coverage

| Report | Skills covered |
| --- | --- |
| [Foundations and web](foundations-web.md) | `gleam`, `gleam-lib`, `gleam-ffi`, `gleam-otp`, `lustre`, `wisp` |
| [Data and execution](data-execution.md) | `grind`, `saga`, `sinal`, `json-blueprint`, `gleam-sql`, `gleam-pubsub` |
| [Transport, identity, and email](transport-identity.md) | `http-gun`, `warden`, `correio` |
| [Agents and replay](agents-replay.md) | `llm-wire`, `fabric`, `relay`, `retrace` |
| [Live inspection](live-inspection.md) | `gleam-inspect`, dynamic client checks, rejected Dash pilot and deployment limits |
| [Source identities](source-identities.json) | Local and remote revisions, clean-state observations, and actual consumer manifest digests |

The earlier [research corpus](../../gleam-agent-tools-research/README.md) and [second pass](../../gleam-agent-tools-research/second-pass/README.md) remain supporting evidence. Findings were checked against actual sources before entering the new skills. Old test results remain historical observations unless explicitly rerun below.

GitHub connector branch reads refreshed all eleven package identities. Ten remote main revisions match the inspected local checkout. Retrace advanced from local `13ef6f9` to remote `31352e5`; the six-commit comparison, updated public server API, README, and erasure design were read before updating its skill. Source links preserve that distinction. Consumer dependency locks can still resolve different revisions.

## Findings carried into the skills

- **JSON Blueprint:** the published 1.7.1 API and the checkout's unreleased codec/contracts API require different imports and wire decisions. Its version field alone cannot identify the API.
- **Roar/Whisper:** Roar 0.1.0 calls an older API than Whisper 0.2.0 provides, despite a dependency range permitting that resolution. The guide requires a normally resolved compatible pair before recommending combined use. No downgrade or patch is asserted to work.
- **SQL:** Squirrel needs the intended live schema; Pog decoding failure can follow query execution; Cigogne's disabled transactions narrow atomicity claims. No fresh database qualification is claimed.
- **Outcome ownership:** job admission, workflow checkpoints, email submission, token custody, model answers, and recording acknowledgements establish different facts. Each guide keeps the application's surrounding commit and retry decisions explicit.
- **Retrace:** fencing prevents new upload admission while pre-admitted uploads may still dispatch. Completion requires the host's qualified quiescence decision. The refreshed write-attempt schema refuses earlier tombstone layouts and supplies no in-place upgrade.
- **Documentation freshness:** Fabric's stale README says its pinned LLM Wire lacks generation settings, but the actual locked source provides them. The guide follows the committed public API.

## Review and corrections

Every complete skill received a source-focused review by an agent other than its author. The main author also read and reconciled the complete collection. Reviews checked technical claims, ordinary consumer paths, scope boundaries, target fit, and false guarantees. They were source reviews, not package runtime certifications or fresh-session skill evaluations.

Four narrow findings were corrected and checked against primary sources:

| Finding | Final rule |
| --- | --- |
| Saga reporting handles cannot use `await` | Use the reporting channel and coordinator monitor; `await` belongs to owner-delivered `start` handles. |
| Optional-field null behavior depends on the inner codec | An absent field bypasses the inner codec; present values delegate to it. Use a nullable inner codec when all three states must remain distinct. |
| Lustre `effect.subscribe` is not a general event subscription API | It handles parent DOM context. Install other long-lived sources through effects with an explicit cleanup owner. |
| Wisp/Mist target fit was implicit | The discovery description now states Erlang/OTP. |

Retrace's subsequent erasure/schema additions received a separate exact-revision review. Its fetched README blob is `f6f65ef18edf4fa06498c3dfa6ece10fd8b11265`; the public server API blob is `17f73540747275cba3b2677dc84613704117c193`. Both support the final rules.

The owner's subsequent diff review strengthened two design policies. `gleam-ffi` now leads with a thin wrapper for one narrow external capability, leaving domain logic and workflow policy in Gleam. `gleam-lib` now explicitly covers composable configuration and usage, ecosystem interoperability, sans-I/O, and narrow typed ports for caller-supplied capabilities. Runtime representation checks, deliberate target selection, and public-consumer verification remain required. These edits introduce no new runtime API claim or prototype.

The subsequent [scope and composition review](composition-review.md) covered the remaining 17 skills. It tightened Wisp's domain boundary, Blueprint callback purity, Warden configuration per client, and Fabric's adapter-specific resource requirements. The other 13 were already aligned with the requested principles.

The owner's requested [independent Astra High review](astra-high-review.md) then examined all 19 skills, their abstraction fit, primary sources, oracle scope, and retained probe evidence. Its purpose-first recommendations were applied after baseline commit `a873eac`. The [revision record](astra-revisions.md) accounts for every skill and the contracts preserved while compressing or replacing prose. Retrace now leads with frontend reconstruction, Sinal with independent producers and optional consumers, and Saga with coordinated effects rather than typed dependencies alone.

Astra High independently reread all 19 revisions and the baseline diff. It found one new ambiguity: legacy Blueprint decoding had been nested beneath bidirectional codecs. The corrected tree separates its one-way decoder and separate encoders from the modern shared-definition codec. No other material regression was found. This is source and editorial review, not a new runtime qualification or agent-effectiveness evaluation.

The subsequent [behavioral evaluation](behavioral-evaluation.md) used fresh agents and actual Oversight maintenance tasks. Its accepted follow-up clarified Retrace core/capture timing, Grind transactional resolution, Saga reporting lifetime, and Sinal producer-side encoding failures. Six affected tasks were rerun with new agents; the report retains inputs, answers, independent grading, lifecycle regression evidence and limits. All 19 current files still pass the size/structure checks, now with 23 unique local exact-revision source paths. Oversight's separately repaired shutdown passed 26 application tests and the repeated-lifetime probe; these later results do not broaden the earlier authoring-pass claims below.

## Checks

The subsequent [live-inspection addition](live-inspection.md) extends the collection to 20 skills. The current guide follows the owner's corrected scope: minimal runtime access and dynamic investigation. The instrumented Dash pilot was rejected and reverted; its earlier passing checks do not justify application inspection APIs. Earlier 19-skill reviews and evaluation results below retain their original scope.

The structural check verifies the exact 19-skill catalog, matching names/directories, portable two-field metadata, direct discovery verbs, one file per skill, decision sections, red flags, source links, balanced fences, size limits, whitespace, and existing relative links. Individual skill budgets are 80 lines and 650 whitespace-delimited words, including metadata and sources.

The baseline check passed for all 19 skills: 54–67 lines and 503–646 words each, with 25 exact-revision source-path checks. After applying Astra's recommendations, the structural check passed again: 55–67 lines and 532–649 words each. It verified all 21 unique exact-revision local GitHub source paths against Git objects; refreshed Retrace sources retain their separate connector evidence. All 19 skills changed and `git diff --check` passed. The [validation record](validation.json) retains current per-skill counts. This establishes structure and source-path integrity, not agent effectiveness.

The retained [boundary lab](../../gleam-agent-tools-research/probes/README.md) was read and rerun with Gleam 1.19.2, OTP 28, and Node 25.8.1:

| Command from the probe project | Result | Claims exercised |
| --- | --- | --- |
| Selected compiler: `gleam test --target erlang` | 7 passed | Foreign returns/Results, fallback choice, integer distinction, escaped static text, discarded simulation effect, selected actor inspection |
| Selected compiler: `gleam test --target javascript` | 7 passed | Foreign returns/Results, Promise behavior, fallback choice, integer precision, escaped static text, discarded simulation effect |

The exact compiler path and locked graph are in the foundation report. Some tests are target-specific. The intentional actor trace warning/timeout does not indicate a failed suite. No new prototype was needed; existing probes validate only the guide claims they exercise.

The retained [pub/sub experiment](../../gleam-agent-tools-research/second-pass/pubsub-experiments.md) is prior evidence, not a fresh supported-installation run. Its harness bypassed resolution and used stdlib 1.0.5 outside Whisper's declared range. The guide therefore makes no claim of a qualified combined installation or distributed delivery guarantee.

No live provider, browser, database, multi-node cluster, deployment, power-loss, security-conformance, or agent-effectiveness evaluation ran for this authoring pass. Package source worktrees remain clean. Skills were created in this directory; no existing installation, dependency graph, or package source was changed.
