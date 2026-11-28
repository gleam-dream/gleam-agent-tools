# Agent LSP starts this child in the requested Gleam package. Only enter
# Nix here: the MCP bridge itself must also start in non-project chats.
# nix/agent-lsp.nix replaces @nix@ and @bash@ with store paths.
#
# `nix develop` evaluates the project's flake and runs its shellHook as the
# user, so entering a development shell trusts that repository's code. A
# development shell is entered only for a flake at or below a directory in
# GLEAM_AGENT_LSP_TRUSTED_ROOTS, a colon-separated list of absolute paths.
# Every other project uses the compiler on PATH.
root=$(pwd -P)
while [ ! -f "$root/flake.nix" ] && [ ! -e "$root/.git" ] && [ "$root" != / ]; do
  root=$(dirname "$root")
done
use_nix=false
if [ -f "$root/flake.nix" ]; then
  old_ifs=$IFS
  IFS=:
  for entry in ${GLEAM_AGENT_LSP_TRUSTED_ROOTS:-}; do
    case "$entry" in
    /*) ;;
    *) continue ;;
    esac
    trusted=$(cd "$entry" 2>/dev/null && pwd -P) || continue
    case "$root/" in
    "${trusted%/}/"*) use_nix=true ;;
    esac
  done
  IFS=$old_ifs
  if [ "$use_nix" = false ]; then
    echo "Not entering the Nix development shell of $root: it is not under GLEAM_AGENT_LSP_TRUSTED_ROOTS. Using Gleam on PATH." >&2
  fi
fi
if [ "$use_nix" = true ]; then
  lock_flag=--no-update-lock-file
  if [ ! -f "$root/flake.lock" ]; then
    lock_flag=--no-write-lock-file
  fi
  # Preserve protocol stdout on fd 3 while the development shell starts.
  exec @nix@ develop "$root" "$lock_flag" \
    --command @bash@ -c 'exec 1>&3 3>&-; exec gleam lsp' 3>&1 1>&2
fi
if command -v gleam >/dev/null 2>&1; then
  exec gleam lsp
fi
echo "No Gleam compiler found: put Gleam on PATH, or add the project to GLEAM_AGENT_LSP_TRUSTED_ROOTS to use its Nix development shell." >&2
exit 127
