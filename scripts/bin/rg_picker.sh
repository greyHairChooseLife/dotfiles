#!/bin/bash
# Search with ripgrep + fzf and send result to tmux pane
# @file:line refs inside Claude Code, file:line otherwise

PANE_CMD=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_current_command}')
[[ "$PANE_CMD" == "claude" ]] && CC=1 || CC=0

echo "0" > /tmp/rg-fzf-hidden-state
echo "0" > /tmp/rg-fzf-glob-mode-state
echo "" > /tmp/rg-fzf-glob-state

cleanup() {
    rm -f /tmp/rg-fzf-hidden-state /tmp/rg-fzf-glob-mode-state /tmp/rg-fzf-glob-state
}
trap cleanup EXIT

selected=$(bash "$HOME/dotfiles/scripts/bin/rg_search.sh" \
    | fzf --ansi --multi \
        --prompt "Search> " \
        --header '<Tab>: select, <Alt+h>: hidden/ignored, <Alt+g>: glob filter, <Enter>: confirm' \
        --delimiter ':' \
        --preview 'bat --color=always --plain --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5' \
        --bind "alt-h:transform:bash $HOME/dotfiles/scripts/bin/rg_reload.sh toggle-hidden" \
        --bind "alt-g:change-prompt(glob> )+clear-query+execute-silent(echo 1 > /tmp/rg-fzf-glob-mode-state)" \
        --bind "enter:transform:
            GLOB_MODE=\$(cat /tmp/rg-fzf-glob-mode-state);
            if [[ \$GLOB_MODE -eq 1 ]]; then
                echo 0 > /tmp/rg-fzf-glob-mode-state;
                echo \"\$FZF_QUERY\" > /tmp/rg-fzf-glob-state;
                bash $HOME/dotfiles/scripts/bin/rg_reload.sh;
            else
                echo accept;
            fi")

[[ -z "$selected" ]] && exit 0

entries=$(echo "$selected" | awk -F: '{print $1":"$2}')

if [[ "$CC" -eq 1 ]]; then
    refs=$(echo "$entries" | sed 's/^/@/' | tr '\n' ' ')
else
    refs=$(echo "$entries" | tr '\n' ' ')
fi

tmux send-keys -t "$TMUX_PANE" "${refs% }"
