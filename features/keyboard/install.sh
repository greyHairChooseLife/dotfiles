#!/bin/bash
# Installs the keyboard switch command.
#   ~/.local/bin/btkb -> features/keyboard/btkb (symlink)
#
# `install.sh --status` exits 0 when the symlink is in place.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

PAYLOAD="$HOME/.local/bin/btkb"

if [ "${1:-}" = "--status" ]; then
    is_link "$PAYLOAD"
    exit $?
fi

mkdir -p "$HOME/.local/bin"
link "$DIR/btkb" "$PAYLOAD"
