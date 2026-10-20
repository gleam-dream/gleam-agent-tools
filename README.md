# Gleam Agent Tools

Compact, independent skills for building Gleam applications and libraries. Each skill is one self-contained `SKILL.md` with an abstraction decision tree, concrete rules, red flags, and primary sources.

Use the guides that fit the task. Agents compose their responsibilities. Included packages are recommended when their capabilities fit; preserve a project's existing suitable choices. Choose targets from the application's or library's purpose.

## Skills

| Skill | Responsibility |
| --- | --- |
| [gleam](skills/gleam/SKILL.md) | Language conventions, types, errors, functions, and modules |
| [gleam-lib](skills/gleam-lib/SKILL.md) | Bounded libraries, public APIs, ownership, and compatibility |
| [gleam-ffi](skills/gleam-ffi/SKILL.md) | Thin native capabilities, checked representations, and lifetimes |
| [gleam-otp](skills/gleam-otp/SKILL.md) | Typed processes, protocols, supervision, and recovery |
| [gleam-inspect](skills/gleam-inspect/SKILL.md) | Existing BEAM service inspection, RPC, Voyager MCP, and deliberate repair boundaries |
| [lustre](skills/lustre/SKILL.md) | Interface state, views, effects, and component lifetimes |
| [wisp](skills/wisp/SKILL.md) | Inbound HTTP, middleware, and Mist integration |
| [http-gun](skills/http-gun/SKILL.md) | Outbound HTTP, owned bodies, deadlines, and retry evidence |
| [gleam-sql](skills/gleam-sql/SKILL.md) | Squirrel generation, Pog transactions, and Cigogne migrations |
| [gleam-pubsub](skills/gleam-pubsub/SKILL.md) | Whisper/Roar notifications, scope, and delivery limits |
| [grind](skills/grind/SKILL.md) | Durable background jobs, admission, and uncertain effects |
| [saga](skills/saga/SKILL.md) | Typed dependent workflows, compensation, and recovery |
| [sinal](skills/sinal/SKILL.md) | Typed observations independent of optional consumers |
| [json-blueprint](skills/json-blueprint/SKILL.md) | Aligned JSON encoding, decoding, and schemas |
| [warden](skills/warden/SKILL.md) | OIDC/OAuth roles, checked identity, and token custody |
| [correio](skills/correio/SKILL.md) | Email submission and passwordless verification |
| [llm-wire](skills/llm-wire/SKILL.md) | Provider calls, structured answers, tools, and streaming |
| [fabric](skills/fabric/SKILL.md) | Typed agents, conditional graphs, policy, and recovery |
| [relay](skills/relay/SKILL.md) | Typed MCP clients, servers, transports, and delivery evidence |
| [retrace](skills/retrace/SKILL.md) | Frontend model/message recording and inert session reconstruction |

Package skills serve applications consuming those packages. `gleam-lib` covers creating libraries. Skill names normalize package underscores to hyphens; package and import names keep their original spelling.

## Use and maintenance

Each directory under `skills/` is an independent Agent Skills entry point. Install the desired directories through your agent's supported skill mechanism. No skill requires another file or a particular editor, host, Nix environment, or hook.

The format follows the [Agent Skills specification](https://agentskills.io/specification). The decision-focused structure is informed by [Elixir Agent Tools](https://github.com/georgeguimaraes/elixir-agent-tools). Technical guidance was written against Gleam and package sources rather than translating Elixir APIs.

The [research index](research/README.md) records source identities, claim evidence, review corrections, and verification limits. These records are maintainer material; they are not additional skill loads. Preserve source distinctions when updating a guide: a published release, a Git checkout, and a consumer's lock may expose different APIs.

Before publishing a changed technical claim, check its primary contract and use a focused code probe only when execution is needed to settle that claim. Keep prototypes outside `skills/`. Keep each skill below 650 words and 80 lines. Check metadata, links, public API names, and overlap with neighboring responsibilities.

## Current qualifications

- JSON Blueprint's researched checkout has a modern codec API absent from published 1.7.1. The guide distinguishes those sources.
- Roar 0.1.0 and Whisper 0.2.0 have incompatible APIs. The pub/sub guide keeps Roar conditional on a verified compatible resolution.
- Several gleam-dream packages are unreleased. Their guides name consumer contracts and limits; they do not qualify package releases.

OpenAPI, composition recipes, and a routing skill are outside the collection's scope. No package implementation changes are bundled here.

See [source acknowledgements](NOTICE.md) for adapted foundation guidance.
