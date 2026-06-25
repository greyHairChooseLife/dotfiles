#!/usr/bin/env zsh
source ~/.config/zsh.sub/bluetooth.sh

# Enable internal keyboard for lock screen password entry
btkb off

i3lock -n --image /home/sy/Pictures/bg/lock.png --show-failed-attempts

# After unlock, switch back to BT keyboard
btkb on
