#!/bin/bash
# Wrapper around find_file.sh that sends selected files to a tmux pane

TARGET_PANE="$1"

pane_pid=$(tmux display-message -p -t "$TARGET_PANE" '#{pane_pid}')
pane_cwd=$(readlink -f /proc/$pane_pid/cwd 2>/dev/null || tmux display-message -p -t "$TARGET_PANE" '#{pane_current_path}')

selected=$(cd "$pane_cwd" && bash "$(dirname "$0")/utils/find_file.sh")

[[ -z "$selected" ]] && exit 0

tmux send-keys -t "$TARGET_PANE" "$selected"
