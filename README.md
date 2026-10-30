# Gleam Agent Tools

[![CI](https://github.com/gleam-dream/gleam-agent-tools/actions/workflows/nix.yml/badge.svg?branch=main)](https://github.com/gleam-dream/gleam-agent-tools/actions/workflows/nix.yml)
[![Gleam](https://img.shields.io/badge/Gleam-FFAFF3?logo=gleam&logoColor=000000)](https://gleam.run/)

Agent skills for building Gleam applications and libraries, with optional Nix installation for skills and language tools. Each self-contained `SKILL.md` includes selection criteria, a decision tree, red flags, and primary sources.

## Install

```sh
npx skills@latest add gleam-dream/gleam-agent-tools
```

Choose the skills and agents interactively. Add `-g` to make them available across projects. See the [installer documentation](https://github.com/vercel-labs/skills#install-a-skill) for more options.

### Nix and Home Manager

The optional flake provides `packages.<system>.agent-lsp`, a `gleam-agent-lsp` app, an `agent-lsp` overlay, and `homeManagerModules.default`. macOS and Linux packages use the same pinned bridge and launcher. Applications keep their own Gleam compiler and dependencies.

Add this repository as a flake input. Reuse the consumer's existing inputs:

```nix
inputs.gleam-agent-tools = {
  url = "github:gleam-dream/gleam-agent-tools";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

Import `gleam-agent-tools.homeManagerModules.default` into the Home Manager configuration and enable it:

```nix
programs.gleam-agent-tools = {
  enable = true;
  skills = [ "gleam" "gleam-tooling" "lustre" ];
  skillDirectories = [ ".agents/skills" ".claude/skills" ];
};
```

Omit `skills` to install the whole collection; use `[]` to install only the bridge. The module is disabled by default. It installs the selected guides under `~/.agents/skills` and exposes `gleam-agent-lsp` on `PATH`. Unknown skill names are rejected.

The host owns agent configuration, Zsh, shell aliases, Git, `gh`, and authentication. Import the module into its existing Home Manager configuration so one activation manages the user's files. Mionix and Dash can retain their own development settings while consuming these tools.

If an imported team setup also consumes this provider, make its `gleam-agent-tools` input follow the host's input so Nix can deduplicate the module.

#### Use your existing Home Manager configuration

On NixOS or nix-darwin, import at the Home Manager level. In a host module receiving the input through `specialArgs`:

```nix
{ gleam-agent-tools, ... }:
{
  home-manager.sharedModules = [
    gleam-agent-tools.homeManagerModules.default
  ];
  home-manager.users.me.programs.gleam-agent-tools = {
    enable = true;
    skills = [ "gleam" "gleam-tooling" ];
    skillDirectories = [ ".agents/skills" ".claude/skills" ];
  };
}
```

Apply this through the host's normal `nixos-rebuild` or `darwin-rebuild` command. Keep one Home Manager configuration and activation for each user. A second standalone `home-manager switch` can replace the host-managed generation.

For an existing standalone setup, add `gleam-agent-tools.homeManagerModules.default` to the `modules` list of its `home-manager.lib.homeManagerConfiguration`, enable the program in that same configuration, and keep using its normal switch command.

When a team module such as Dash also imports this provider, share the input explicitly:

```nix
inputs.dash-dev-env.inputs.gleam-agent-tools.follows = "gleam-agent-tools";
```

The host selects team defaults. In a personal Mionix configuration, disable Dash's shell, Git, SSH, direnv, npm and MCP management where the host owns them. Set `dash.git.identityFile = null`, disable duplicate tools such as Node or separately managed agents, and disable Eza's shell integrations if retaining personal aliases. Set `dash.switchCommand` to the host's rebuild. This provider installs the bridge and selected guides.

The default `skillDirectories` is `[ ".agents/skills" ]`, the [Codex user skill location](https://learn.chatgpt.com/docs/build-skills). The example also installs into [Claude Code's personal skill directory](https://code.claude.com/docs/en/skills). Hosts select the locations used by their agents.

For an existing installation, move any selected skill directories to a backup before activating Home Manager. Nix-managed guides are updated through the consumer's flake lock. The `npx skills` route remains available for independently managed guides.

Register `gleam-agent-lsp` as the agent's stdio MCP command. The bridge starts outside a project; when a Gleam file is requested, its child uses that package's Nix development shell or the existing compiler on `PATH`. Development-shell startup output is kept off the protocol stream. Configuration does not install a global Gleam compiler.

Flake discovery stops at the project's Git root. An unrelated parent flake does not override a PATH compiler. Existing project lockfiles are preserved; a new project without a lockfile can enter its shell without writing one.

The launcher disables the bridge's broad automatic watcher because it resets Gleam's diagnostic state. Refresh externally edited source with `get_diagnostics`, and restart the server after changing `gleam.toml`. The repaired fork remains pinned until the required fixes are available upstream.

For a temporary installation, run `nix run github:gleam-dream/gleam-agent-tools#gleam-agent-lsp`. For local development, override the flake input with `--override-input gleam-agent-tools path:/absolute/path/to/gleam-agent-tools`.

Run `nix fmt`, `nix flake check`, and `nix develop --command python nix/tests/test_mcp.py gleam-agent-lsp` before publishing. The flake checks build the package, verify enabled, disabled and selective Home Manager installations, and exercise MCP with a real Gleam compiler. The development-shell command also verifies project environment selection against a live Nix store; CI runs both commands.

## Skills

| Skill                                            | Use it for                                                 |
| ------------------------------------------------ | ---------------------------------------------------------- |
| [gleam](skills/gleam/SKILL.md)                   | Types, errors, functions, and modules                      |
| [gleam-tooling](skills/gleam-tooling/SKILL.md)   | Compiler, dependencies, and language server                |
| [gleam-lib](skills/gleam-lib/SKILL.md)           | Library scope, configuration, composition, and public APIs |
| [gleam-ffi](skills/gleam-ffi/SKILL.md)           | Thin foreign interfaces, types, and resource lifetimes     |
| [gleam-otp](skills/gleam-otp/SKILL.md)           | Actors, supervision, and recovery                          |
| [gleam-inspect](skills/gleam-inspect/SKILL.md)   | Live BEAM inspection, RPC, and Voyager MCP                 |
| [lustre](skills/lustre/SKILL.md)                 | UI state, views, effects, and large application structure  |
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
