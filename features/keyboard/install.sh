#!/bin/bash
# Installs the keyboard switch command.
#   ~/.local/bin/btkb -> bin/btkb (symlink)
#
# `install.sh --status` exits 0 when the symlink is in place.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR"
    exit $?
fi

link_bin "$DIR"
