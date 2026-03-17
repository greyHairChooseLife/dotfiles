#!/bin/bash
# Installs TLP CPU performance config and low-battery EPP switcher.
# AC / high-battery  → EPP = performance
# Battery < 20%      → EPP = power
#
# Run with sudo: sudo bash scripts/setup_cpu_perf.sh

set -e

# ── 1. TLP drop-in ──────────────────────────────────────────────────────────
cat > /etc/tlp.d/10-cpu-performance.conf << 'EOF'
# CPU energy/performance preference
# AC: full performance; battery: balanced-performance (udev handles <20% case)
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_performance

# Keep turbo enabled on both
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=1
EOF
echo "[ok] /etc/tlp.d/10-cpu-performance.conf"

# ── 2. Low-battery EPP switch script ────────────────────────────────────────
cat > /usr/local/bin/battery-epp-switch << 'EOF'
#!/bin/bash
# Called by udev on battery capacity change.
# Sets EPP to 'power' below LOW_THRESHOLD, otherwise 'performance'.

LOW_THRESHOLD=20

# Find battery node dynamically
BATTERY_NODE=""
for ps in /sys/class/power_supply/*/; do
    if [ "$(cat "${ps}type" 2>/dev/null)" = "Battery" ]; then
        BATTERY_NODE="${ps%/}"
        break
    fi
done
[ -z "$BATTERY_NODE" ] && exit 0

capacity=$(cat "$BATTERY_NODE/capacity" 2>/dev/null) || exit 0
status=$(cat "$BATTERY_NODE/status" 2>/dev/null)

# On AC power: always performance
if [ "$status" = "Charging" ] || [ "$status" = "Not charging" ] || [ "$status" = "Full" ]; then
    epp=performance
elif [ "$capacity" -le "$LOW_THRESHOLD" ]; then
    epp=power
else
    epp=balance_performance
fi

for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "$epp" > "$f" 2>/dev/null || true
done
EOF
chmod +x /usr/local/bin/battery-epp-switch
echo "[ok] /usr/local/bin/battery-epp-switch"

# ── 3. udev rule ─────────────────────────────────────────────────────────────
cat > /etc/udev/rules.d/99-battery-epp.rules << 'EOF'
# Trigger EPP switch on any battery capacity/status change or AC plug/unplug
SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Battery", RUN+="/usr/local/bin/battery-epp-switch"
SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains",   RUN+="/usr/local/bin/battery-epp-switch"
EOF
echo "[ok] /etc/udev/rules.d/99-battery-epp.rules"

# ── 4. Reload ────────────────────────────────────────────────────────────────
udevadm control --reload-rules
tlp start
/usr/local/bin/battery-epp-switch

echo ""
echo "Done. Current EPP:"
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
