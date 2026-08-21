fzf_find_dir() {
    local show_hidden=${1:-0}
    local curr_dir="${PWD/$HOME/\~}"
    local hidden_flag=""
    local hidden_prompt=""
    local initial_depth=1

    [[ "$show_hidden" -eq 1 ]] && hidden_flag="--hidden -I" && hidden_prompt="(+hidden) "

    # Initialize state files
    echo "$show_hidden" > /tmp/fzf-dir-hidden-state
    echo "$initial_depth" > /tmp/fzf-dir-depth-state

    local dir
    dir=$(fd --type d $hidden_flag --max-depth $initial_depth \
            | awk 'BEGIN{print ".."} {print}' \
            | sort -r \
            | fzf-tmux \
            --prompt="${hidden_prompt}Dir (--depth=${initial_depth}) & ${curr_dir}/" \
            --header="<Alt+h>: toggle hidden, <Alt+1~3>: depth lvl, <Enter>: cd into" \
        --bind "alt-h:transform:
				HIDDEN=\$(cat /tmp/fzf-dir-hidden-state);
				DEPTH=\$(cat /tmp/fzf-dir-depth-state);
				if [[ \$HIDDEN -eq 0 ]]; then
					echo 'reload(fd --type d --hidden -I --max-depth '\$DEPTH' | awk '\''BEGIN{print \"..\"} {print}'\'' | sort -r)+change-prompt((+hidden) Dir (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 1 > /tmp/fzf-dir-hidden-state)';
				else
					echo 'reload(fd --type d --max-depth '\$DEPTH' | awk '\''BEGIN{print \"..\"} {print}'\'' | sort -r)+change-prompt(Dir (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 0 > /tmp/fzf-dir-hidden-state)';
				fi" \
            --bind "alt-1:transform:
        HIDDEN=\$(cat /tmp/fzf-dir-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type d '\$HIDDEN_FLAG' --max-depth 1 | awk '\''BEGIN{print \"..\"} {print}'\'' | sort -r)+change-prompt('\$PROMPT'Dir (--depth=1) & ${curr_dir}/)+execute-silent(echo 1 > /tmp/fzf-dir-depth-state)';" \
            --bind "alt-2:transform:
        HIDDEN=\$(cat /tmp/fzf-dir-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type d '\$HIDDEN_FLAG' --max-depth 2 | awk '\''BEGIN{print \"..\"} {print}'\'' | sort -r)+change-prompt('\$PROMPT'Dir (--depth=2) & ${curr_dir}/)+execute-silent(echo 2 > /tmp/fzf-dir-depth-state)';" \
            --bind "alt-3:transform:
        HIDDEN=\$(cat /tmp/fzf-dir-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type d '\$HIDDEN_FLAG' | awk '\''BEGIN{print \"..\"} {print}'\'' | sort -r)+change-prompt('\$PROMPT'Dir (--depth=end) & ${curr_dir}/)+execute-silent(echo 999 > /tmp/fzf-dir-depth-state)';" \
        --preview 'tree --gitignore -dC -L 3 {}')

    rm -f /tmp/fzf-dir-hidden-state /tmp/fzf-dir-depth-state

    if [ -n "$dir" ]; then
        cd "$dir"
        if [ $(fd --type d --max-depth 1 | wc -l) -gt 0 ]; then
            fzf_find_dir
        fi
    fi
}

alias j='fzf_find_dir'
alias f='~/dotfiles/scripts/bin/utils/find_file.sh | xargs -r nvim -O'
alias w='~/dotfiles/scripts/bin/rg_picker.sh'
