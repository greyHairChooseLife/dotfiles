#!/bin/bash
# Links the fzf pickers that send a file path / file:line to a tmux pane.
#   bin/*            -> ~/.local/bin
#   libexec/*        -> ~/.local/libexec/picker
#
# Depends on features/base (find_file).
# Pass --status to exit 0 when everything is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR" && status_libexec "$DIR" picker
    exit $?
fi

require_feature "$(dirname "$DIR")" base
link_bin "$DIR"
link_libexec "$DIR" picker
