#!/bin/bash
# Installs the lid hook.
#   1. ~/.local/bin/lid-hook  -> repo payload (symlink, no copy)
#   2. /usr/lib/systemd/system-sleep/50-lid  (root, generated with this user/home)
#
# Run as your normal user; sudo is requested only for step 2.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SLEEP_HOOK=/usr/lib/systemd/system-sleep/50-lid

mkdir -p "$HOME/.local/bin"
ln -sfn "$DIR/lid-hook" "$HOME/.local/bin/lid-hook"
echo "[ok] $HOME/.local/bin/lid-hook -> $DIR/lid-hook"

tmp=$(mktemp)
sed -e "s|@@USER@@|$USER|g" -e "s|@@HOME@@|$HOME|g" "$DIR/50-lid" >"$tmp"
bash -n "$tmp"
sudo install -Dm755 "$tmp" "$SLEEP_HOOK"
rm -f "$tmp"
echo "[ok] $SLEEP_HOOK"

cat <<EOF

Verify:
  sudo $SLEEP_HOOK pre    # stops running tasks, prepends the report
  sudo $SLEEP_HOOK post   # opens the floating nvim window
  systemctl suspend       # real test
EOF
