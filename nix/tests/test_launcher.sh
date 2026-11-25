#!/usr/bin/env bash
# Runs the project launcher with a recording `nix` and `gleam` and checks
# which one it starts. Usage: test_launcher.sh path/to/gleam-project-lsp.sh
set -u

template=$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")
work=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/tools" "$work/path"
printf '#!/bin/sh\necho "nix $*" >"%s/started"\n' "$work" >"$work/tools/nix"
printf '#!/bin/sh\necho "gleam $*" >"%s/started"\n' "$work" >"$work/path/gleam"
chmod +x "$work/tools/nix" "$work/path/gleam"
sed -e "s|@nix@|$work/tools/nix|g" -e "s|@bash@|$(command -v bash)|g" \
  "$template" >"$work/launcher"

# A flake project inside a Git repository, and a package below its root.
trusted="$work/trusted/project"
other="$work/other/project"
mkdir -p "$trusted/.git" "$trusted/package" "$other/.git" "$work/plain/.git"
touch "$trusted/flake.nix" "$other/flake.nix"
ln -s "$trusted" "$work/link"

failures=0
# check NAME DIRECTORY EXPECTED [VARIABLE=value ...]
check() {
  name=$1 directory=$2 expected=$3
  shift 3
  rm -f "$work/started"
  (cd "$directory" && env PATH="$work/path:$PATH" "$@" \
    bash "$work/launcher" >/dev/null 2>"$work/stderr")
  started=$(cat "$work/started" 2>/dev/null || echo "nothing")
  case "$started" in
  "$expected"*) echo "ok - $name" ;;
  *)
    echo "not ok - $name"
    echo "  expected: $expected"
    echo "  started:  $started"
    failures=$((failures + 1))
    ;;
  esac
}

develop="nix develop $trusted --no-write-lock-file"

check "a project flake with no trusted list starts the PATH compiler" \
  "$trusted/package" "gleam lsp"
for message in "$trusted" GLEAM_AGENT_LSP_TRUSTED_ROOTS "Gleam on PATH"; do
  if ! grep -q "$message" "$work/stderr"; then
    echo "not ok - the fallback message names: $message"
    failures=$((failures + 1))
  fi
done
check "a project without a flake starts the PATH compiler" \
  "$work/plain" "gleam lsp"
check "a root on the trusted list starts its development shell" \
  "$trusted/package" "$develop" \
  GLEAM_AGENT_LSP_TRUSTED_ROOTS="$work/missing:$work/trusted"
check "a root off the trusted list starts the PATH compiler" \
  "$other" "gleam lsp" GLEAM_AGENT_LSP_TRUSTED_ROOTS="$work/trusted"
check "a sibling whose name extends a trusted root is not trusted" \
  "$other" "gleam lsp" GLEAM_AGENT_LSP_TRUSTED_ROOTS="$work/oth"
check "an empty or relative entry trusts nothing" \
  "$other" "gleam lsp" GLEAM_AGENT_LSP_TRUSTED_ROOTS=":.:$work/trusted"
if ! grep -q "$other" "$work/stderr"; then
  echo "not ok - the refusal names the untrusted root"
  failures=$((failures + 1))
fi
check "a trusted root reached through a symbolic link starts its development shell" \
  "$work/link/package" "$develop" GLEAM_AGENT_LSP_TRUSTED_ROOTS="$work/trusted"

exit "$((failures > 0))"
