# INITIAL

Choose Retrace core for safe transition capture and local export, plus an inert support viewer (optionally `retrace_frontend`'s viewer only). Keep the existing message-driven editor; if using Lustre, use `lustre.application` because tax/search/checkout require effects. Do not add component runtimes just to divide the UI. Reject screen recording, a business event store, server archival, and `retrace_frontend` capture for release one: its storage/upload lifecycle is unnecessary for local export and must not be satisfied with fake upload acknowledgements. Logs alone cannot reconstruct intermediate cart state.

Reject serializing the complete model and redacting later: secrets would already exist in buffers, files, and failure paths. Reject replay through today's live update: it could execute checkout and would silently change historical behavior.

Selected guides, read completely:
- `/code/gleam-dream/gleam-agent-tools/skills/retrace/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/lustre/SKILL.md`
- `/code/gleam-dream/gleam-agent-tools/skills/gleam/SKILL.md`

Two controlling guide lines:
> Project safe models and messages before capture/encoding; exclude credentials and private values.

> Associate asynchronous results with the request or model revision they belong to. Ignore obsolete results when a newer request supersedes them; arrival order is not request order.

## Ownership, types, configuration

The application owns cart rules, money arithmetic, message variants, and privacy policy. Use native custom types: `Money(minor_units, currency)`, `CartRevision`, `RequestId`, `TaxState = Idle | Pending(request, revision) | Calculated(amount) | Failed(reason)`, and analogous search state. Enforce valid quantities/currency at ingress. Domain messages include quantity changes, tax/search observations with request IDs and revisions, checkout intent and sanitized checkout outcome. Expected failures use `Result`; missing data uses `Option`.

Separate replayable cart state from a private live envelope containing bearer tokens and contact details. The browser effect adapter owns access to that envelope; it never enters recorder calls. Replay state retains only approved product/price/quantity/tax information and opaque session-local aliases, no address, email, token, search free text, raw response bodies, or private error strings. Preserve the exact numeric tax result used in a transition. If an omitted input influences a cart rule, retain an approved derived fact or observation sufficient for that rule; otherwise mark that transition unsupported rather than pretend replay is faithful. Necessary product/search data still needs an explicit privacy review.

Compose a small application-owned configuration from safe codecs/projectors, a deterministic cart reducer, session/build/contract identities, monotonic elapsed clock, bounded retention policy, and local storage/export adapter. Do not hide these choices in a global recording service. Tax/search effects attach request ID and relevant cart/query revision. The reducer rejects obsolete results, so a slow old result cannot overwrite newer state. Retain sanitized stale-response arrivals as no-op messages if their ordering is needed to diagnose the incident; exclude recording coordination messages.

## Ordinary consumer path (pseudocode, not runnable API)

1. On editor start, initialize a safe checkpoint and one recorder owned by that editor session. Separate tabs/writers get distinct session IDs. Start recording before the interactions under investigation.
2. DOM intent or asynchronous observation enters the application dispatcher. Decode/project it into the safe domain message before capture. Apply the deterministic reducer to safe cart state, yielding the next state and effect descriptions. Keep private form/auth updates outside this stream.
3. Record the safe message with elapsed time, then checkpoint the resulting safe state; retain the returned recorder. Commit local event/cursor/checkpoint consistently if promising crash recovery. Execute effect descriptions only in the live runtime, using private context. Feed sanitized effect results back through step 2, including delayed tax, search, and checkout results. Never record a bearer-bearing request.
4. User exports a bounded local recording. Support imports through strict decoders, validates identities, ordering and limits, and loads the retained replay artifact matching its build.
5. Initialize a player from the safe checkpoint and apply recorded messages in accepted arrival order through that artifact's deterministic reducer. Render through an inert view with no network, checkout dispatch, subscriptions, or active form actions. Timing controls playback presentation; recorded observations determine state. Side-effect descriptions are discarded.

The editor owns recorder/storage lifetime; stop capture on teardown, release timers/listeners, and enforce expiry/deletion locally. The viewer owns its player and disposes any mounted viewer resources. Storage quota/write errors stop recording with visible status while cart editing continues. Export must state its captured range; no silent truncation. Tax/search failures become typed domain observations with ordinary retry creating a new request ID; replay never retries. Replay gaps, duplicates, backwards time, decode/reducer errors, and mismatched contracts must preserve the prior player and show an actionable failure. Do not claim missing evidence is recoverable without a retained source.

## Release and verification

Release the safe recording contract and matching replay bundle together; pin Retrace packages to one revision. Retain historical reducer/view artifacts, with build identity distinct from schema/contract compatibility. Refuse unavailable artifacts; permit migrations only when tested and explicit. Treat artifact integrity and support access separately from identity strings. No backend upload in release one.

Unknowns: actual framework, resolved versions, export UX/consent, safe retention size/duration, and which cart decisions currently depend on private fields. Verify core initialization/record/checkpoint/player APIs, local serialization and failure semantics, inert viewer lifetime, and historical artifact loading. Later acceptance sequences should cover superseded search/tax, tax errors/retry, duplicate arrivals, checkout intent/outcome without effects, privacy inspection of exports, and corrupted/incompatible recordings. No build or browser verification is claimed here.

# VERIFIED

Checked public package source in the local checkout at HEAD `13ef6f9c4304081bb60c13c9d6d3c0802170fdbb`; the guide's pinned GitHub source could not be fetched, and that pin's paths were unavailable locally. These checks establish the inspected API, not compatibility with the guide pin or a consumer lockfile.

[Core source](/code/gleam-dream/retrace/src/retrace.gleam:45) confirms `start(origin, initial)` returns recorder/checkpoint; `record(recorder, event, elapsed_ms:)` returns next recorder/entry; `checkpoint` trusts the supplied resulting model. `replay(checkpoint, contract_id, reducer)` requires a reducer returning `Result(model, error)`; `step(player, entry)` returns the next player or error without advancing on failure (lines 107–162). Thus adapt the pure transition function to discard effect descriptions explicitly. Keep the initial checkpoint plus its following entries; latest-only checkpoint replacement would erase the path support needs. Optional later checkpoints accelerate seeking.

[Viewer source](/code/gleam-dream/retrace/packages/retrace_frontend/src/retrace_frontend/viewer.gleam:25) confirms composable `Source` callbacks and artifact `Resolver`, allowing an application-owned imported-file source; do not use its HTTP collector. `mount` returns a disposer, and artifacts must share its origin (lines 48–65). Import-to-source wiring remains application work, untested here.

[Lustre's official API](https://lustre.hexdocs.pm/lustre.html#application) confirms effect-returning application updates and explicit browser startup. No runtime checks were run.

Clarification: request supersession is the desired live policy; historical artifacts must retain their actual old reducer behavior, including a stale-response bug. Do not fix the reducer while replaying an old incident. Privacy projection must preserve the observations needed to reproduce that historical behavior. A release cannot promise replay of sessions captured before this boundary existed.

Output: `/private/tmp/gleam-skills-rerun-20261020/02-frontend.md` — local safe transition recording, inert historical replay, and explicit privacy/version boundaries; API checks appended without replacing initial reasoning.
