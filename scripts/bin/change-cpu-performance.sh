#!/bin/bash

set -euo pipefail

if [ "${1:-}" = "powersave" ]; then
    sudo bash -c 'echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'
    echo "now cpu -> powersave"
else
    sudo bash -c 'echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'
    echo "now cpu -> performance"
    echo "󰯪 Usage: $(basename "$0") [powersave|performance]"
fi
