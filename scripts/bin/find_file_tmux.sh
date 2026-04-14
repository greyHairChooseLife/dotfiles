#!/bin/bash
# Wrapper around find_file.sh that sends selected files to a tmux pane

TARGET_PANE="$1"

selected=$(bash "$(dirname "$0")/utils/find_file.sh")

[[ -z "$selected" ]] && exit 0

tmux send-keys -t "$TARGET_PANE" "$selected"
