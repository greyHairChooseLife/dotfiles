#!/bin/bash
# Removes the keyboard switch symlink.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

unlink "$HOME/.local/bin/btkb"
