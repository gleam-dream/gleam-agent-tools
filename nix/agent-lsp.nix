{
  lib,
  buildGoModule,
  fetchFromGitHub,
  bash,
  makeWrapper,
  nix,
  stdenv,
  writeShellScript,
}:
let
  projectLsp = writeShellScript "gleam-project-lsp" (
    builtins.replaceStrings [ "@nix@" "@bash@" ] [ (lib.getExe nix) (lib.getExe bash) ] (
      builtins.readFile ./gleam-project-lsp.sh
    )
  );
in
buildGoModule rec {
  pname = "agent-lsp";
  version = "0.24.6";

  src = fetchFromGitHub {
    owner = "blackwell-systems";
    repo = "agent-lsp";
    # Tag v0.24.6.
    rev = "46703fae29fc9d5e123417db5ba0cdad92e539b3";
    hash = "sha256-HlcTT+uFAVXpDQP+DKmqrnP2nKcR4reqo5IZbeuj8qM=";
  };

  vendorHash = "sha256-aBokNk3GGCkMX5UYotiQHzWRKfHF6Tc0EA4hIj5XIKg=";

  subPackages = [ "./cmd/agent-lsp" ];

  # The HTTP and initialization tests bind loopback sockets on Darwin.
  __darwinAllowLocalNetworking = stdenv.isDarwin;

  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    # Gleam registers a watch for gleam.toml. The bridge's generic watcher
    # also reports source/build files, resetting Gleam's diagnostic history.
    # get_diagnostics reopens edited source; restart after config changes.
    makeWrapper "$out/bin/agent-lsp" "$out/bin/gleam-agent-lsp" \
      --set AGENT_LSP_DISABLE_WATCHER 1 \
      --add-flags "gleam:${projectLsp}"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.commit=${src.rev}"
  ];

  meta = {
    description = "MCP server that orchestrates language servers (gopls, rust-analyzer, gleam lsp, etc.) into agent-native code intelligence workflows";
    homepage = "https://github.com/blackwell-systems/agent-lsp";
    license = lib.licenses.mit;
    mainProgram = "agent-lsp";
  };
}
