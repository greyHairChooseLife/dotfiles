#!/bin/bash
# Links small standalone utilities and the sharing commands.
#
# Depends on features/base (find_file, show_spinner).
# Pass --status to exit 0 when every bin/ file is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR"
    exit $?
fi

require_feature "$(dirname "$DIR")" base
link_bin "$DIR"
