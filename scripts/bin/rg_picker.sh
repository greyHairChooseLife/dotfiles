#!/bin/bash
# Search with ripgrep + fzf, insert @file:line refs into tmux pane (Claude Code mode)

selected=$(rg --line-number --no-heading --color=always "" \
    | fzf --ansi --multi \
        --prompt "Search> " \
        --header '<Tab>: select, <Enter>: confirm' \
        --delimiter ':' \
        --preview 'bat --color=always --plain --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5')

[[ -z "$selected" ]] && exit 0

refs=$(echo "$selected" | awk -F: '{print $1":"$2}' | sed 's/^/@/' | tr '\n' ' ')

tmux send-keys -t "$TMUX_PANE" "${refs% }"
