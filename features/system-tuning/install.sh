#!/bin/bash
# Installs the CPU power tuning:
#   ~/.local/bin/change-cpu-performance       -> bin/change-cpu-performance
#   /etc/tlp.d/10-cpu-performance.conf         (root)
#   /etc/udev/rules.d/99-battery-epp.rules     (root)
#   /usr/local/bin/battery-epp-switch          (root)
#
# Then reloads udev rules, restarts TLP invocation, applies EPP once.
# Pass --status to exit 0 when every artifact is in place.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

TLP_CONF=/etc/tlp.d/10-cpu-performance.conf
UDEV_RULE=/etc/udev/rules.d/99-battery-epp.rules
EPP_SWITCH=/usr/local/bin/battery-epp-switch

status() {
    status_bin "$DIR" || return 1
    [ -f "$TLP_CONF" ] && [ -f "$UDEV_RULE" ] && [ -x "$EPP_SWITCH" ]
}

if [ "${1:-}" = "--status" ]; then
    status
    exit $?
fi

link_bin "$DIR"
sudo_link "$DIR/10-cpu-performance.conf" "$TLP_CONF"
sudo_link "$DIR/99-battery-epp.rules" "$UDEV_RULE"
sudo_link "$DIR/battery-epp-switch" "$EPP_SWITCH"

sudo udevadm control --reload-rules
sudo tlp start
sudo "$EPP_SWITCH"

echo ""
echo "Current EPP:"
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
