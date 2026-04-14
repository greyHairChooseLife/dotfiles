#!/bin/bash
# Search with ripgrep + fzf and send result to tmux pane
# @file:line refs inside Claude Code, file:line otherwise

PANE_CMD=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_current_command}')
[[ "$PANE_CMD" == "claude" ]] && CC=1 || CC=0

echo "0" > /tmp/rg-fzf-hidden-state

cleanup() {
    rm -f /tmp/rg-fzf-hidden-state
}
trap cleanup EXIT

selected=$(rg --line-number --no-heading --color=always "" \
    | fzf --ansi --multi \
        --prompt "Search> " \
        --header '<Tab>: select, <Alt+h>: toggle hidden/ignored, <Enter>: confirm' \
        --delimiter ':' \
        --preview 'bat --color=always --plain --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5' \
        --bind "alt-h:transform:
            HIDDEN=\$(cat /tmp/rg-fzf-hidden-state);
            if [[ \$HIDDEN -eq 0 ]]; then
                echo 'reload(rg --line-number --no-heading --color=always --hidden -u \"\")+change-prompt((+hidden) Search> )+execute-silent(echo 1 > /tmp/rg-fzf-hidden-state)';
            else
                echo 'reload(rg --line-number --no-heading --color=always \"\")+change-prompt(Search> )+execute-silent(echo 0 > /tmp/rg-fzf-hidden-state)';
            fi")

[[ -z "$selected" ]] && exit 0

entries=$(echo "$selected" | awk -F: '{print $1":"$2}')

if [[ "$CC" -eq 1 ]]; then
    refs=$(echo "$entries" | sed 's/^/@/' | tr '\n' ' ')
else
    refs=$(echo "$entries" | tr '\n' ' ')
fi

tmux send-keys -t "$TMUX_PANE" "${refs% }"
