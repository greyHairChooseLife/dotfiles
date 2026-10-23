#!/bin/bash
# Installs the lid hook.
#   1. ~/.local/bin/lid-hook               -> payload (symlink)
#   2. /usr/lib/systemd/system-sleep/50-lid (root, generated with this user/home)
#
# Run as your normal user; sudo is requested only for step 2.
# `install.sh --status` exits 0 when both are in place.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

PAYLOAD="$HOME/.local/bin/lid-hook"
SLEEP_HOOK=/usr/lib/systemd/system-sleep/50-lid

status() {
    is_link "$PAYLOAD" || return 1
    [ -f "$SLEEP_HOOK" ]
}

if [ "${1:-}" = "--status" ]; then
    status
    exit $?
fi

mkdir -p "$HOME/.local/bin"
link "$DIR/lid-hook" "$PAYLOAD"

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
