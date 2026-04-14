#!/bin/bash
# Pick files with fzf and insert @path references into the target tmux pane

TARGET_PANE="$1"

curr_dir=${PWD/$HOME/\~}
initial_depth=1

echo "0" > /tmp/cc-fzf-hidden-state
echo "$initial_depth" > /tmp/cc-fzf-depth-state

cleanup() {
    rm -f /tmp/cc-fzf-hidden-state /tmp/cc-fzf-depth-state
}
trap cleanup EXIT

selected=$(fd --type file --max-depth $initial_depth | sort \
    | fzf --multi \
        --prompt "Files (--depth=${initial_depth}) & ${curr_dir}/" \
        --header '<Tab>: select, <Alt+h>: toggle hidden, <Alt+1~3>: depth, <Enter>: confirm' \
        --preview 'bat --color=always --plain {}' \
        --bind "alt-h:transform:
            HIDDEN=\$(cat /tmp/cc-fzf-hidden-state);
            DEPTH=\$(cat /tmp/cc-fzf-depth-state);
            if [[ \$HIDDEN -eq 0 ]]; then
                echo 'reload(fd --type file --hidden -I --max-depth '\$DEPTH' | sort)+change-prompt((+hidden) Files (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 1 > /tmp/cc-fzf-hidden-state)';
            else
                echo 'reload(fd --type file --max-depth '\$DEPTH' | sort)+change-prompt(Files (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 0 > /tmp/cc-fzf-hidden-state)';
            fi" \
        --bind "alt-1:transform:
            HIDDEN=\$(cat /tmp/cc-fzf-hidden-state);
            HIDDEN_FLAG=''; PROMPT=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
            echo 'reload(fd --type file '\$HIDDEN_FLAG' --max-depth 1 | sort)+change-prompt('\$PROMPT'Files (--depth=1) & ${curr_dir}/)+execute-silent(echo 1 > /tmp/cc-fzf-depth-state)'" \
        --bind "alt-2:transform:
            HIDDEN=\$(cat /tmp/cc-fzf-hidden-state);
            HIDDEN_FLAG=''; PROMPT=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
            echo 'reload(fd --type file '\$HIDDEN_FLAG' --max-depth 2 | sort)+change-prompt('\$PROMPT'Files (--depth=2) & ${curr_dir}/)+execute-silent(echo 2 > /tmp/cc-fzf-depth-state)'" \
        --bind "alt-3:transform:
            HIDDEN=\$(cat /tmp/cc-fzf-hidden-state);
            HIDDEN_FLAG=''; PROMPT=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
            echo 'reload(fd --type file '\$HIDDEN_FLAG' | sort)+change-prompt('\$PROMPT'Files (--depth=end) & ${curr_dir}/)+execute-silent(echo 999 > /tmp/cc-fzf-depth-state)'")

[[ -z "$selected" ]] && exit 0

# Build "@path1 @path2 ..." string
refs=$(echo "$selected" | sed 's/^/@/' | tr '\n' ' ')

tmux send-keys -t "$TARGET_PANE" "$refs"
