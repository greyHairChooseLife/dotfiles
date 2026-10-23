#!/bin/bash
# Removes the CPU power tuning symlinks and root artifacts.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

unlink_bin "$DIR"
sudo_remove /etc/tlp.d/10-cpu-performance.conf
sudo_remove /etc/udev/rules.d/99-battery-epp.rules
sudo_remove /usr/local/bin/battery-epp-switch

sudo udevadm control --reload-rules
