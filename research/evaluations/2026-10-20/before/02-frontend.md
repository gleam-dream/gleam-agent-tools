# INITIAL

## Choice and evidence

Use Retrace core plus `retrace_frontend` for safe transition capture and an inert browser viewer; use Lustre's effect-returning application runtime for the live editor. Keep ordinary typed reducers and projections in application modules. Do not add the server package, database/archive, screen recorder, business event store, actor system, or generic workflow engine: the first release needs frontend reconstruction, not these lifetimes or guarantees. Logs alone cannot reconstruct the message sequence that produced the total.

Selected guides (read completely):
- `/code/gleam-dream/gleam-agent-tools/skills/retrace/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/lustre/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/gleam/SKILL.md`

Material guide lines: “Project safe models and messages before capture/encoding; exclude credentials and private values.” And: “Associate asynchronous results with the request or model revision they belong to. Ignore obsolete results when a newer request supersedes them; arrival order is not request order.”

Reject the teammate's proposal. Viewer redaction happens after the leak; the live update/effect runner could issue HTTP or submit checkout during replay. A current reducer can also reinterpret old messages, disguising the original bug.

## Domain and privacy boundary

The application owns `LiveModel`, domain `Msg`, deterministic state transitions, effect interpretation, safe projections, and the versioned recording contract. Retrace owns recording/player mechanics, not cart policy. Use native variants such as `TaxIdle`, `TaxPending(request_id, cart_revision)`, `TaxReady(amount)`, and `TaxFailed(reason)`; similarly model search and checkout states. Represent money with validated integer minor units and currency, quantity with checked values, and request/revision identifiers with distinct types. Tax results contain their request ID, relevant cart revision, and a typed success/failure result. Search results carry request IDs too.

A separate `SafeModel` contains only reconstruction inputs: product keys, quantities, prices, tax status/results, totals, request IDs, cart revision, and safe UI state. Safe messages retain those values needed by the reducer. Exclude tokens, contact details, free text, raw headers/bodies, private error strings, and URLs containing personal data. Review every variant, including initial state, errors, and external results. Keep tokens in an effect-owned credential boundary where practical; in either case the recorder never receives them.

Allowlist projection runs before any recorder, encoder, persistence, diagnostics, or export. Do not hash customer contacts as a substitute for excluding them. If tax logic depends on location, record the minimal derived tax classification or actual tax outcome needed for reconstruction; do not silently retain an address. Unknown fields/variants stop capture safely rather than passing through raw values. Missing requirement: support must specify whether contact-dependent bugs require extra consented evidence beyond this intentionally limited recording.

## Ordinary consumer path (conceptual pseudocode, not an API promise)

1. At application startup create one session/writer and capture handle, supplying contract/build identity, codecs for safe values, a monotonic elapsed clock, and chosen local delivery settings. Keep capture coordination outside domain messages.
2. Live runtime receives `QuantityChanged`; call `capture.observe` once with the **pre-transition** safe model and safe message, retaining capture's returned state/cursor. Then apply the ordinary live transition and execute its returned tax-request effect. Capture failure is reported separately and does not reject a cart edit.
3. HTTP completion becomes `TaxReturned(request_id, revision, result)`. Capture this observation before its transition. The reducer accepts it only for the current request/revision; stale tax/search responses produce no state change. Preserve observation order, including harmless stale responses, if the capture adapter permits this, so support can see the race. Never sort responses by request ID or repeat the HTTP call.
4. Save/export bounded safe session data locally for user-directed support sharing. Display recording/export failure and incomplete ranges; a numbered event is not proof it was saved. Do not promise crash recovery until the browser adapter's persistence contract is checked.
5. Viewer decodes a recording, checks identity/integrity and continuity, loads its matching historical replay artifact, and steps safe messages through the safe deterministic reducer with an inert view. The replay artifact has no live effect interpreter or credentials. Show recorded tax failures/delays; seeking never performs checkout or HTTP.

Use composable constructor/configuration values for clock, safe codecs, identities, delivery bounds and replay reducer/view; avoid a service locator or new processes. Application startup owns the client, local session and unload behavior; teardown stops capture/delivery, releases subscriptions, and invokes viewer/replay disposers. Concurrent tabs/writers receive separate sessions/cursors. Exact frontend constructors, disposal APIs, local storage guarantees, and observation integration still require verification.

## Recovery and release plan

Handle gaps, duplicates, backwards elapsed time, malformed input, contract mismatch and reducer failure explicitly; preserve the last valid player state. Deduplicate or obtain missing locally available ranges deliberately; otherwise label replay incomplete and stop at the gap. A failed export retains the local data for retry within explicit storage bounds. Storage exhaustion stops recording visibly; never silently discard evidence while claiming completeness.

Pin all Retrace packages to one revision. Each release publishes a safe recording contract and immutable historical replay bundle under its build identity, including the buggy logic needed for faithful reproduction. Keep pure transition rules shared between live behavior and the corresponding safe replay reducer where possible; verify projection preserves relevant transitions. Require explicit migrations/compatibility decisions, with fixtures from prior releases. If the historical bundle is missing or incompatible, refuse replay rather than substituting today's reducer. Build identity, authenticity/integrity, authorization, and contract compatibility are separate checks. First release retention, access to exported files, size limits, and historical-artifact retention need product decisions.

Verification needed: actual capture/frontend APIs and lifetime; purity and projection equivalence; privacy fixtures with seeded secrets; delayed/stale tax and search sequences; zero HTTP/checkout execution during replay; malformed/gapped sessions and incompatible builds; browser export, storage failure and teardown. No synthetic build is justified by this design-only exercise.

# VERIFIED

Primary-source checks amend the integration choice:

- Public pinned Retrace URLs could not be fetched, and revision `31352e53c7673fd948540e2f7cbe921a9903b203` is unavailable locally. The following checks use workspace primary source at `/code/gleam-dream/retrace`; checkout HEAD is `13ef6f9c4304081bb60c13c9d6d3c0802170fdbb`. They do **not** verify the guide's pinned revision.
- `packages/retrace_frontend/src/retrace_frontend/capture.gleam:50` requires config, storage **and transport**; `observe` at line 120 requires a connected client and returns capture state plus an effect. An early observation permanently fails that capture session. Wait for connection before admitting captured transitions, or explicitly mark an uncaptured prefix and start from a safe checkpoint. Observe only after the application accepts a transition, passing its pre-reduction model; an accepted stale-result no-op may be included intentionally. `capture.update` handles coordination messages; `capture.stop` returns an effect that must actually run before disposal.
- More importantly, `client.gleam:28` confirms saved means local persistence, while its `Transport` is an abortable **upload** returning acknowledgement JSON (line 73). The default flow is delivery-oriented, not a demonstrated local-export API. For release one, choose **core recorder/checkpoint + application-owned bounded browser store/export**, and frontend replay; defer `capture.start`/delivery client unless a real required delivery destination emerges. The ordinary path becomes safe projection → `retrace.record` → retain returned recorder → atomically save checkpoint/entry → export. Do not invent a successful upload adapter that acknowledges and deletes the only local copy. Local-store transaction/eviction/export behavior remains application work, not a verified Retrace guarantee.
- `replay.gleam:20` provides `ReplayModule` with native model/message decoders, reducer returning `Result`, equality, view, viewport and label. `load` at line 50 validates build/contract/range and returns no partial snapshots on failure; keep the prior successful viewer state in the host. `mount` at line 209 returns a disposer. Inertness still requires application callbacks themselves to be pure; the library cannot prevent an effect hidden inside a supplied reducer/view.
- [Lustre effect documentation](https://lustre.hexdocs.pm/lustre/effect.html) confirms runtime-executed effects and completion messages. This supports recording external observations rather than replaying requests.

No builds, dependencies, repository edits, credentials, or application services were used. Browser safety, projection equivalence and retained historical bundles remain release acceptance checks.

Output: `/private/tmp/gleam-skills-eval-20261020/02-frontend.md` — safe local transition recording, inert historical replay, and an explicit correction to avoid assuming delivery APIs provide local-only export.
