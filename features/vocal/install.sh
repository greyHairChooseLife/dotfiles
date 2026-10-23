#!/bin/bash
# Links the voice transcription command.
#   bin/*     -> ~/.local/bin
#   libexec/* -> ~/.local/libexec/vocal
#
# Pass --status to exit 0 when everything is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR" && status_libexec "$DIR" vocal
    exit $?
fi

link_bin "$DIR"
link_libexec "$DIR" vocal
