{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gleam-agent-tools;
  available = builtins.attrNames (
    lib.filterAttrs (_: kind: kind == "directory") (builtins.readDir ../skills)
  );
in
{
  options.programs.gleam-agent-tools = {
    enable = lib.mkEnableOption "the shared Gleam agent tools and skills";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./agent-lsp.nix { };
      description = "Agent LSP package providing the gleam-agent-lsp launcher.";
    };
    skills = lib.mkOption {
      type = lib.types.listOf (lib.types.enum available);
      default = available;
      example = [
        "gleam"
        "gleam-tooling"
        "lustre"
      ];
      description = "Skills installed under ~/.agents/skills; defaults to the complete collection.";
    };
    skillDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ".agents/skills" ];
      example = [
        ".agents/skills"
        ".claude/skills"
      ];
      description = "Skill directories relative to the home directory, selected by the host for its agents.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file = lib.listToAttrs (
      lib.concatMap (
        directory:
        map (name: {
          name = "${directory}/${name}";
          value.source = ../skills + "/${name}";
        }) cfg.skills
      ) cfg.skillDirectories
    );
  };
}
