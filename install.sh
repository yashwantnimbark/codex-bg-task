#!/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="$PREFIX/bin"

mkdir -p "$BINDIR"

for script in "$ROOT"/bin/codex-*; do
  name="$(basename "$script")"
  install -m 0755 "$script" "$BINDIR/$name"
  echo "installed $BINDIR/$name"
done

case ":$PATH:" in
  *":$BINDIR:"*) ;;
  *)
    echo
    echo "Add this to your shell profile if needed:"
    echo "  export PATH=\"$BINDIR:\$PATH\""
    ;;
esac
