# Scope and composition review

Reviewed October 20, 2026 after the owner clarified the `gleam-ffi` and `gleam-lib` principles. The corpus was the other 17 complete skills. Both the main author and an independent reviewer read that corpus. The four edits below preserve package APIs and public contracts.

## Criteria

- Keep one defined abstraction per guide and leave surrounding application policy with its owner.
- Compose configuration and usage through explicit values, typed functions, and supported public contracts.
- Keep domain decisions in Gleam. Foreign wrappers supply narrow runtime capabilities and representation conversion.
- Keep sans-I/O and ports conditional on a useful boundary. Preserve package-owned storage, protocol, and native runtime mechanisms.

## Corrections applied

| Skill | Conflict or ambiguity | Correction |
| --- | --- | --- |
| `wisp` | Only “expensive” domain work was assigned to application functions. Cheap business decisions could drift into transport glue. | Handlers parse requests and map results; Gleam application functions own domain decisions and explicit capabilities supply storage. |
| `json-blueprint` | “Custom callbacks own their effects” could license hidden I/O despite the preceding purity instruction. | Keep conversion and domain validation in pure Gleam functions. Perform application I/O before or after codec use; callback types do not enforce purity or resource ownership. |
| `warden` | “Start one client” and “new once” could imply a singleton across independent configurations. | Construct once per independent configuration and reuse each handle. Keep validation, name allocation, and supervision explicit. |
| `fabric` | The ordinary setup path required HTTP/database resources even for adapters that do not use them. | Allocate only the resources required by the selected adapters. Keep borrowed resources under their application owner's lifecycle. |

Source checks supporting the corrections:

- Wisp's existing decision tree already assigns business decisions to application functions. The correction makes its handler instructions consistent with that scope.
- JSON Blueprint's selected `src/json/blueprint/codec.gleam` exposes value conversion through `try_map` and invokes construction callbacks for schema descriptions. These callbacks are not an application workflow or resource-lifecycle boundary.
- Warden's selected `src/warden.gleam` `new` function allocates distinct names per client. The revised instruction preserves supported independently configured instances.
- Fabric's selected `src/fabric/model.gleam` defines `Model` as a typed request/reply function; `src/fabric/llm.gleam` supplies the specific Wire/HTTP adapter. A custom model does not inherently require that adapter's HTTP client or a database backend.

Selected revisions remain those in [source identities](source-identities.json). This review adds design guidance, not a new claim of runtime qualification.

## Aligned guides retained

| Skills | Existing boundary supporting composition |
| --- | --- |
| `gleam`, `gleam-otp` | Ordinary functions and values precede processes; protocols, recovery dependencies, and handles have explicit owners. |
| `lustre` | Model/update decisions stay separate from effects; components require a lifetime reason and transport retains its own owner. |
| `http-gun` | Explicit configuration and per-call views compose over an owned client; payload interpretation and retry policy remain application-owned. |
| `gleam-sql` | Query generation, runtime execution, and migrations are selectable responsibilities; callers compose transactions through the provided connection. |
| `gleam-pubsub`, `sinal` | Notification and diagnostic delivery remain distinct. Documented shared registries/routes have explicit setup and cleanup ownership. |
| `grind`, `saga` | Typed workers and steps compose with application callbacks; job admission, checkpoints, business commits, and effect recovery remain separate authorities. |
| `correio` | An injected sender separates delivery from business code; passwordless verification and email submission are independently usable. |
| `llm-wire`, `relay` | Typed preparation/definitions compose with application policy; provider/protocol handling does not absorb business effects or retries. |
| `retrace` | Core, frontend, and server capabilities are selected independently; applications supply safe projections, reducers, storage, and lifecycle. |

These 13 guides needed no edits through the requested lens. Their existing native mechanisms do not justify instructing consumers to rewrite package internals, invent unsupported ports, or adopt a whole stack.

## Verification

The author inspected the complete four-file diff. The independent reviewer checked the revised instructions. The two previously refined foundation guides remained unchanged.

Rechecked all 19 skills for metadata, single-file layout, decision sections, red flags, source links, size limits, whitespace, and relative-link integrity. Regenerated [validation counts](validation.json). This was a prose and contract review; no package implementation, executable example, or runtime claim changed, so no code prototype or runtime suite was needed.
