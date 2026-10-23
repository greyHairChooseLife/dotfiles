#!/bin/bash
# Installs the lid hook.
#   ~/.local/bin/lid-hook                -> bin/lid-hook (symlink)
#   /usr/lib/systemd/system-sleep/50-lid  -> generated from 50-lid (root)
#
# Run as your normal user; sudo is requested only for the systemd hook.
# `install.sh --status` exits 0 when both are in place.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

SLEEP_HOOK=/usr/lib/systemd/system-sleep/50-lid

status() {
    status_bin "$DIR" || return 1
    [ -f "$SLEEP_HOOK" ]
}

if [ "${1:-}" = "--status" ]; then
    status
    exit $?
fi

link_bin "$DIR"

tmp=$(mktemp)
sed -e "s|@@USER@@|$USER|g" -e "s|@@HOME@@|$HOME|g" "$DIR/50-lid" >"$tmp"
bash -n "$tmp"
sudo_link "$tmp" "$SLEEP_HOOK"
rm -f "$tmp"

cat <<EOF

Verify:
  sudo $SLEEP_HOOK pre    # stops running tasks, prepends the report
  sudo $SLEEP_HOOK post   # opens the floating nvim window
  systemctl suspend       # real test
EOF
