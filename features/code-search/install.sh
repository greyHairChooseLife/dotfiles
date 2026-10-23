#!/bin/bash
# Links the ripgrep / ast-grep search commands.
#
# Pass --status to exit 0 when every bin/ file is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR"
    exit $?
fi

link_bin "$DIR"
