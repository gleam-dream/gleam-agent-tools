{
  description = "Gleam agent skills and an optional shared Nix installation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      treefmt-nix,
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      formatting =
        system:
        treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            ruff-check.enable = true;
            ruff-format.enable = true;
          };
        };
    in
    {
      overlays.default = final: _: {
        agent-lsp = final.callPackage ./nix/agent-lsp.nix { };
      };
      homeManagerModules.default = import ./nix/home-manager.nix;
      packages = forSystems (system: {
        inherit (pkgsFor system) agent-lsp;
        default = self.packages.${system}.agent-lsp;
      });
      apps = forSystems (system: {
        gleam-agent-lsp = {
          type = "app";
          program = "${self.packages.${system}.agent-lsp}/bin/gleam-agent-lsp";
          meta.description = "Gleam language tools using the requested project's compiler";
        };
        default = self.apps.${system}.gleam-agent-lsp;
      });
      formatter = forSystems (system: (formatting system).config.build.wrapper);
      devShells = forSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [
            lefthook
            git
            gleam
            agent-lsp
            python3
            nixfmt
            ruff
          ];
          shellHook = "lefthook install";
        };
      });
      checks = forSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          formatting = (formatting system).config.build.check self;
          workflow =
            pkgs.runCommand "gleam-agent-tools-workflow"
              {
                nativeBuildInputs = [ pkgs.actionlint ];
              }
              ''
                cd ${self}
                actionlint .github/workflows/nix.yml
                touch "$out"
              '';
          package = pkgs.agent-lsp;
          home-manager = import ./nix/tests/home-manager.nix {
            inherit pkgs home-manager;
            module = self.homeManagerModules.default;
          };
          gleam-mcp =
            pkgs.runCommand "gleam-agent-tools-mcp"
              {
                nativeBuildInputs = [
                  pkgs.python3
                  pkgs.gleam
                ];
              }
              ''
                export HOME="$TMPDIR/home"
                mkdir -p "$HOME"
                python ${./nix/tests/test_mcp.py} ${pkgs.agent-lsp}/bin/gleam-agent-lsp
                touch "$out"
              '';
        }
      );
    };
}
