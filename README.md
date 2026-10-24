# Gleam Agent Tools

Compact agent skills for building Gleam applications and libraries. Each guide is one self-contained `SKILL.md` with selection criteria, a decision tree, red flags, and primary sources.

## Install

```sh
npx skills@latest add gleam-dream/gleam-agent-tools
```

Choose the skills and agents interactively. Add `-g` to make them available across projects. See the [installer documentation](https://github.com/vercel-labs/skills#install-a-skill) for more options.

## Skills

| Skill                                            | Use it for                                                 |
| ------------------------------------------------ | ---------------------------------------------------------- |
| [gleam](skills/gleam/SKILL.md)                   | Types, errors, functions, and modules                      |
| [gleam-tooling](skills/gleam-tooling/SKILL.md)   | Compiler, dependencies, and language server                |
| [gleam-lib](skills/gleam-lib/SKILL.md)           | Library scope, configuration, composition, and public APIs |
| [gleam-ffi](skills/gleam-ffi/SKILL.md)           | Thin foreign interfaces, types, and resource lifetimes     |
| [gleam-otp](skills/gleam-otp/SKILL.md)           | Actors, supervision, and recovery                          |
| [gleam-inspect](skills/gleam-inspect/SKILL.md)   | Live BEAM inspection, RPC, and Voyager MCP                 |
| [lustre](skills/lustre/SKILL.md)                 | UI models, messages, views, and effects                    |
| [wisp](skills/wisp/SKILL.md)                     | HTTP handlers, middleware, and Mist integration            |
| [http-gun](skills/http-gun/SKILL.md)             | Pooled HTTP requests, streams, and retry decisions         |
| [gleam-sql](skills/gleam-sql/SKILL.md)           | SQL with Squirrel, Pog, and Cigogne                        |
| [gleam-pubsub](skills/gleam-pubsub/SKILL.md)     | Whisper/Roar notifications and delivery limits             |
| [grind](skills/grind/SKILL.md)                   | Durable jobs and uncertain-effect recovery                 |
| [saga](skills/saga/SKILL.md)                     | Dependent workflows, compensation, and recovery            |
| [sinal](skills/sinal/SKILL.md)                   | Typed telemetry with independent consumers                 |
| [json-blueprint](skills/json-blueprint/SKILL.md) | Aligned JSON codecs and schemas                            |
| [hellhound](skills/hellhound/SKILL.md)           | OIDC login, OAuth, and token custody                       |
| [correio](skills/correio/SKILL.md)               | Transactional email and passwordless verification          |
| [llm-wire](skills/llm-wire/SKILL.md)             | Model calls, structured answers, tools, and streaming      |
| [fabric](skills/fabric/SKILL.md)                 | Agents, conditional graphs, policy, and retained execution |
| [relay](skills/relay/SKILL.md)                   | Typed MCP clients, servers, and transports                 |
| [retrace](skills/retrace/SKILL.md)               | Frontend model/message capture and inert replay            |

Agents select and combine the guides a task needs. Package skills guide application code; `gleam-lib` guides library authors. Listed packages are recommended when they fit; keep existing suitable choices. Choose targets from the application's or library's purpose.

## Maintaining skills

- Keep each skill self-contained, under 650 words and 80 lines.
- Check primary sources before changing technical claims. Use temporary code probes only when execution is needed to verify a claim.
- Check metadata, links, API names, and responsibility boundaries. Keep experiments, downloaded dependencies, and validation output outside this repository.

Uses the [Agent Skills format](https://agentskills.io/specification). See [NOTICE.md](NOTICE.md) for source acknowledgements and licence notices.
