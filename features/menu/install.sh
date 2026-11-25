#!/bin/bash
# Links the rofi mode menu into ~/.local/bin.
#
# Depends on features/notif (the notifications row runs rofi-notif).
# Pass --status to exit 0 when everything is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR"
    exit $?
fi

require_feature "$(dirname "$DIR")" notif
link_bin "$DIR"
