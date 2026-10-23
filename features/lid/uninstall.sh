#!/bin/bash
# Removes the lid hook symlink and the systemd sleep hook.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

unlink "$HOME/.local/bin/lid-hook"
sudo_remove /usr/lib/systemd/system-sleep/50-lid
