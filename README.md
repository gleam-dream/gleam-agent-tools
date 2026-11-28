# Gleam Agent Tools

[![CI](https://github.com/gleam-dream/gleam-agent-tools/actions/workflows/nix.yml/badge.svg?branch=main)](https://github.com/gleam-dream/gleam-agent-tools/actions/workflows/nix.yml)
[![Gleam](https://img.shields.io/badge/Gleam-FFAFF3?logo=gleam&logoColor=000000)](https://gleam.run/)

Agent skills for building Gleam applications and libraries, with optional Nix installation for skills and language tools. Each self-contained `SKILL.md` includes selection criteria, a decision tree, red flags, and primary sources.

## Install

```sh
npx skills@latest add gleam-dream/gleam-agent-tools
```

Choose the skills and agents interactively. Add `-g` to make them available across projects. See the [installer documentation](https://github.com/vercel-labs/skills#install-a-skill) for more options.

That command installs whatever `main` holds when it runs. A skill is instruction to an agent that can run commands, so read what is installed, or install a commit already reviewed. The installer accepts a full commit hash after `@`, as its [source formats](https://github.com/vercel-labs/skills/blob/main/docs/commands.md#source-formats) describe:

```sh
npx skills@latest add gleam-dream/gleam-agent-tools@<full-commit-hash>
```

This repository has no release tags; the same form takes a tag when one exists. `skills@latest` is itself unpinned; replace `latest` with an installer version to fix that as well.

### Nix and Home Manager

The optional flake provides `packages.<system>.agent-lsp`, a `gleam-agent-lsp` app, an `agent-lsp` overlay, and `homeManagerModules.default`. macOS and Linux packages use the same pinned bridge and launcher. Applications keep their own Gleam compiler and dependencies.

Add this repository as a flake input. Reuse the consumer's existing inputs. The consumer's `flake.lock` records the commit, and only `nix flake update gleam-agent-tools` moves it; append `/<full-commit-hash>` to the URL to name the commit in `flake.nix` as well:

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

Register `gleam-agent-lsp` as the agent's stdio MCP command. The bridge starts outside a project; when a Gleam file is requested, its child uses the compiler on `PATH`, or the package's Nix development shell when the user trusts that project. Development-shell startup output is kept off the protocol stream. Configuration does not install a global Gleam compiler.

Entering a project's development shell runs that project's code: `nix develop` evaluates the flake and runs its `shellHook` as the user, and the agent chooses the directory when it calls `start_lsp`. The launcher therefore enters a development shell only for a flake at or below a directory listed in `GLEAM_AGENT_LSP_TRUSTED_ROOTS`, a colon-separated list of absolute paths set on the MCP command. For any other project it uses the compiler on `PATH` and names the skipped flake on stderr. With the variable unset, no development shell is entered. To use project shells for your own repositories, set, for example, `GLEAM_AGENT_LSP_TRUSTED_ROOTS=$HOME/code/my-org`.

Flake discovery stops at the project's Git root. An unrelated parent flake does not override a PATH compiler. Existing project lockfiles are preserved; a new project without a lockfile can enter its shell without writing one.

The launcher disables the bridge's broad automatic watcher because it resets Gleam's diagnostic state. Refresh externally edited source with `get_diagnostics`, and restart the server after changing `gleam.toml`. The bridge is [agent-lsp](https://github.com/blackwell-systems/agent-lsp), built from the commit of its release tag `v0.24.6`.

Registering the bridge gives the agent tools that write files, not only tools that read code. The pinned bridge exposes `apply_edit`, `safe_apply_edit`, `replace_symbol_body`, `safe_delete_symbol`, `rename_symbol`, `format_document` and `execute_command`, among others; its [tool reference](https://github.com/blackwell-systems/agent-lsp/blob/46703fae29fc9d5e123417db5ba0cdad92e539b3/docs/reference/tools.md) lists them all. Grant or deny those tools in the agent's own permission settings.

For a temporary installation, run `nix run github:gleam-dream/gleam-agent-tools#gleam-agent-lsp`. That form runs the current `main`; `nix run github:gleam-dream/gleam-agent-tools/<full-commit-hash>#gleam-agent-lsp` runs a chosen commit. For local development, override the flake input with `--override-input gleam-agent-tools path:/absolute/path/to/gleam-agent-tools`.

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
| [decisions](skills/decisions/SKILL.md)           | Policies, verdicts, and gated releases made at most once   |
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
- State lasting direction. Name no release version or floor, upgrade step, or defect workaround; point to the package's docs and CHANGELOG, which hold those.
- Check primary sources before changing technical claims. Use temporary code probes only when execution is needed to verify a claim.
- Record a library skill's repository and the commit it describes in frontmatter `metadata` (`library`, `library-ref`). CI checks every backticked `module.function` in the skill against that commit with `python nix/tests/check_skill_identifiers.py`; pass `--libraries <directory>` to use local checkouts. When a library changes, move `library-ref` and correct the skill in the same change. List a backticked `name.name` that is not a library function under `not-in-library`.
- Check metadata, links, API names, and responsibility boundaries. Keep experiments, downloaded dependencies, and validation output outside this repository.

Uses the [Agent Skills format](https://agentskills.io/specification).

## Licence

Licensed under the [Apache License, Version 2.0](LICENSE). Guidance adapted from `lostbean/skills` stays under its MIT licence; [NOTICE.md](NOTICE.md) names the sources and reproduces their notices.
