#!/bin/bash
# Links the rofi notification list into ~/.local/bin.
#
# Depends on dunst, rofi and xclip (installed by setup.d/install_pkgs.sh).
# Pass --status to exit 0 when everything is linked.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

if [ "${1:-}" = "--status" ]; then
    status_bin "$DIR"
    exit $?
fi

link_bin "$DIR"
