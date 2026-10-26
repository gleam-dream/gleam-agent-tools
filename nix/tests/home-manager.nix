{
  pkgs,
  home-manager,
  module,
}:
let
  home =
    enable: skills:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        {
          home = {
            username = "gleam-tools-test";
            homeDirectory =
              if pkgs.stdenv.isDarwin then "/Users/gleam-tools-test" else "/home/gleam-tools-test";
            stateVersion = "26.05";
          };
          programs.gleam-agent-tools = {
            inherit enable skills;
            skillDirectories = [
              ".agents/skills"
              ".claude/skills"
            ];
          };
        }
      ];
    };
  selected = home true [
    "gleam"
    "gleam-tooling"
  ];
  disabled = home false [ "gleam" ];
  bridgeOnly = home true [ ];
  invalid = builtins.tryEval (builtins.deepSeq (home true [ "not-a-skill" ]).config.home.file true);
in
assert !invalid.success;
assert builtins.elem selected.config.programs.gleam-agent-tools.package
  selected.config.home.packages;
assert
  !(builtins.elem disabled.config.programs.gleam-agent-tools.package disabled.config.home.packages);
pkgs.runCommand "gleam-agent-tools-home-manager" { } ''
  test -f ${selected.config.home-files}/.agents/skills/gleam/SKILL.md
  test -f ${selected.config.home-files}/.agents/skills/gleam-tooling/SKILL.md
  test -f ${selected.config.home-files}/.claude/skills/gleam/SKILL.md
  test -f ${selected.config.home-files}/.claude/skills/gleam-tooling/SKILL.md
  test ! -e ${selected.config.home-files}/.agents/skills/lustre
  test ! -e ${disabled.config.home-files}/.agents/skills/gleam
  test ! -e ${disabled.config.home-files}/.claude/skills/gleam
  test ! -e ${bridgeOnly.config.home-files}/.agents/skills/gleam
  touch "$out"
''
