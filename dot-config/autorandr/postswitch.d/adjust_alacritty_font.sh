#!/bin/bash

export DISPLAY=:0
CONFIG_FILE="$HOME/.config/alacritty/alacritty.toml"

# Get all connected external monitors (excluding eDP-1)
EXTERNALS=$(xrandr --query | grep " connected" | grep -v "eDP-1" | awk '{print $1}')

# Count the number of external monitors
if [ -n "$EXTERNALS" ]; then
    EXTERNAL_COUNT=$(echo "$EXTERNALS" | wc -l)
else
    EXTERNAL_COUNT=0
fi

if [ "$EXTERNAL_COUNT" -ge 2 ]; then
    # Adjust font size based on detected monitors (customize as needed)
    if echo "$EXTERNALS" | grep -q -E "HDMI-2|DP-2-"; then
        sed -i 's/^size = .*/size = 11.0  # current/' "$CONFIG_FILE"
    elif echo "$EXTERNALS" | grep -q "DP-1"; then
        sed -i 's/^size = .*/size = 15.0  # DP-1/' "$CONFIG_FILE"
    fi
elif [ "$EXTERNAL_COUNT" -eq 1 ]; then
    # Original logic for single external monitor
    EXTERNAL=$(echo "$EXTERNALS" | head -1)
    if [[ "$EXTERNAL" == "HDMI-2" || "$EXTERNAL" == "DP-2-" ]]; then
        sed -i 's/^size = .*/size = 11.0  # current/' "$CONFIG_FILE"
    elif [[ "$EXTERNAL" == "DP-1" ]]; then
        sed -i 's/^size = .*/size = 15.0  # current/' "$CONFIG_FILE"
    fi
else
    sed -i 's/^size = .*/size = 9.0  # current/' "$CONFIG_FILE"
fi
