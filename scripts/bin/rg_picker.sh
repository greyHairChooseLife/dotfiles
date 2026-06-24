#!/bin/bash
# Search with ripgrep + fzf and send result to tmux pane
# @file:line refs inside Claude Code, file:line otherwise

TARGET_PANE="${1:-$TMUX_PANE}"

PANE_CMD=$(tmux display-message -p -t "$TARGET_PANE" '#{pane_current_command}')
[[ "$PANE_CMD" == "claude" || "$PANE_CMD" == "pi" ]] && CC=1 || CC=0

echo "0" > /tmp/rg-fzf-hidden-state
echo "0" > /tmp/rg-fzf-glob-mode-state
echo "" > /tmp/rg-fzf-glob-state
tmux display-message -p -t "$TARGET_PANE" '#{pane_current_path}' | tr -d '\n' > /tmp/rg-fzf-cwd

cleanup() {
    rm -f /tmp/rg-fzf-hidden-state /tmp/rg-fzf-glob-mode-state /tmp/rg-fzf-glob-state /tmp/rg-fzf-cwd
}
trap cleanup EXIT

selected=$(fzf --ansi --multi \
        --disabled \
        --prompt "Search> " \
        --header '<Tab>: select, <Alt+h>: hidden/ignored, <Alt+g>: glob, <Alt+f>: open in nvim, <Enter>: confirm' \
        --delimiter ':' \
        --preview "bash $HOME/dotfiles/scripts/bin/rg_preview.sh {1} {2}" \
        --preview-window 'right:60%:+{2}-5' \
        --bind "start:reload(bash $HOME/dotfiles/scripts/bin/rg_search.sh)" \
        --bind "change:reload(bash $HOME/dotfiles/scripts/bin/rg_search.sh {q} || true)" \
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
                fi" \
        --bind "ctrl-r:execute(CWD=\$(cat /tmp/rg-fzf-cwd); awk -F: -v cwd=\"\$CWD\" 'NR==1{printf \"nvim -O +%s %s/%s\", \$2, cwd, \$1} NR>1{printf \" %s/%s\", cwd, \$1}' {+f} > /tmp/rg-nvim-cmd.sh && bash /tmp/rg-nvim-cmd.sh)")
        # TODO: open each file at its exact line number in nvim vertical split.
        # nvim -O does not support per-file +line args (e.g. nvim -O +62 a.lua +8 b.lua is invalid).
        # Attempted: building "nvim -O +line1 file1 +line2 file2" — nvim ignores all but the last +cmd.
        # Possible fix: use a lua script passed via --cmd or -c that iterates buffers and calls :buffer +line.
        # For now, only the first selected file opens at the correct line; others open at top.

[[ -z "$selected" ]] && exit 0

entries=$(echo "$selected" | awk -F: '{print $1":"$2}')

if [[ "$CC" -eq 1 ]]; then
    refs=$(echo "$entries" | sed 's/^/@/' | tr '\n' ' ')
else
    refs=$(echo "$entries" | tr '\n' ' ')
fi

tmux send-keys -t "$TARGET_PANE" "${refs% }"
