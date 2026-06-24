#!/usr/bin/env zsh
source ~/.config/zsh.sub/bluetooth.sh

if xinput list-props "AT Translated Set 2 keyboard" | grep -q "Device Enabled.*1$"; then
    btkb on
    notify-send "BT keyboard:" "ON"
else
    btkb off
    notify-send "BT keyboard:" "OFF"
fi
