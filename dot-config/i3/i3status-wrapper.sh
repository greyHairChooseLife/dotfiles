#!/bin/sh
# Find first available battery device and patch i3status config before running

CONF="$HOME/.config/i3/i3status.conf"
TMP=$(mktemp /tmp/i3status.XXXXXX.conf)

BAT_PATH=$(for dev in /sys/class/power_supply/*/; do
    type=$(cat "${dev}type" 2>/dev/null)
    if [ "$type" = "Battery" ]; then
        echo "${dev}uevent"
        break
    fi
done)

if [ -n "$BAT_PATH" ]; then
    sed "s|path = \".*\"|path = \"$BAT_PATH\"|" "$CONF" > "$TMP"
else
    cp "$CONF" "$TMP"
fi

exec i3status -c "$TMP"
