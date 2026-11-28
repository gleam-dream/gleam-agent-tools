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
  # Synced upstream includes the path-confinement fix from PR #26. This fork
  # also fixes Gleam roots, initialization, impact warnings and diagnostics.
  version = "0.23.2-gleam-reliability-57d7a50";

  src = fetchFromGitHub {
    owner = "lostbean";
    repo = "agent-lsp";
    rev = "57d7a50949f1745903cfb5b18287e0fc0c756853";
    hash = "sha256-sRHF8WQ71/ESNdbmQG+r+xL3eLW8qgfNbc79IIpHNKM=";
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
