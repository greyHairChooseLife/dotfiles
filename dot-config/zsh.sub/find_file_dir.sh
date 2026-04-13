# Unified function that combines both find_file and find_file_hidden
fzf_find_image_file2() {
    # Setup Überzug++
    case "$(uname -a)" in
        *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
        *) UEBERZUG_TMP_DIR="/tmp" ;;
    esac

    cleanup() {
        ueberzugpp cmd -s "$SOCKET" -a exit
    }
    trap cleanup HUP INT QUIT TERM EXIT

    UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
    ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file "$UB_PID_FILE"
    UB_PID=$(cat "$UB_PID_FILE")

    export SOCKET="$UEBERZUG_TMP_DIR"/ueberzugpp-"$UB_PID".socket

    # Only find image files
    fd --type file -e jpg -e jpeg -e png -e svg | sort \
        | fzf-tmux --prompt "Images: " \
        --header '<Enter>: open in nvim (vertical split)' \
        --preview-window=up:70%:wrap \
        --bind "enter:become(nvim -o {+})" \
        --preview 'ueberzugpp cmd -s $SOCKET -i fzfpreview -a add -x $FZF_PREVIEW_LEFT -y $FZF_PREVIEW_TOP --max-width $FZF_PREVIEW_COLUMNS --max-height $FZF_PREVIEW_LINES -f {}'

    # Cleanup Überzug++
    ueberzugpp cmd -s "$SOCKET" -a exit
}

fzf_find_image_file() {
    # Setup Überzug++
    case "$(uname -a)" in
        *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
        *) UEBERZUG_TMP_DIR="/tmp" ;;
    esac

    cleanup() {
        ueberzugpp cmd -s "$SOCKET" -a exit
    }
    trap cleanup HUP INT QUIT TERM EXIT

    UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
    ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file "$UB_PID_FILE"
    UB_PID=$(cat "$UB_PID_FILE")

    export SOCKET="$UEBERZUG_TMP_DIR"/ueberzugpp-"$UB_PID".socket

    fd --type file -e jpg -e jpeg -e png -e svg | sort \
        | FZF_PREVIEW_IMAGE_WIDTH=40 \
        fzf-tmux --prompt "Images: " \
        --header '<Enter>: open in nvim (vertical split)' \
        --layout=default \
        --preview-window=up:70%:wrap \
        --bind "enter:become(nvim -o {+})" \
    --preview '
                IMAGE_WIDTH=${FZF_PREVIEW_IMAGE_WIDTH:-40}
                X=$((FZF_PREVIEW_LEFT + FZF_PREVIEW_COLUMNS - IMAGE_WIDTH))
                ueberzugpp cmd -s $SOCKET -i fzfpreview -a add \
                    -x $X \
                    -y $FZF_PREVIEW_TOP \
                    --max-width $IMAGE_WIDTH \
                    --max-height $FZF_PREVIEW_LINES \
                    -f {}
            '

    ueberzugpp cmd -s "$SOCKET" -a exit
}

fzf_find_file_unified() {
    local show_hidden=${1:-0}

    ueberzugpp cmd -s "$SOCKET" -a exit

    # Setup Überzug++
    case "$(uname -a)" in
        *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
        *) UEBERZUG_TMP_DIR="/tmp" ;;
    esac

    cleanup() {
        ueberzugpp cmd -s "$SOCKET" -a exit
        rm -f /tmp/fzf-hidden-state /tmp/fzf-depth-state
    }
    trap cleanup HUP INT QUIT TERM EXIT

    UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
    ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file "$UB_PID_FILE"
    UB_PID=$(cat "$UB_PID_FILE")

    export SOCKET="$UEBERZUG_TMP_DIR"/ueberzugpp-"$UB_PID".socket

    local curr_dir=${PWD/$HOME/\~}
    local hidden_flag=""
    local hidden_prompt=""
    local initial_depth=1

    [[ "$show_hidden" -eq 1 ]] && hidden_flag="--hidden -I" && hidden_prompt="(+hidden) "

    # Initialize state files
    echo "$show_hidden" > /tmp/fzf-hidden-state
    echo "$initial_depth" > /tmp/fzf-depth-state

    local selected
    selected=$(fd --type file $hidden_flag --max-depth $initial_depth | sort \
            | fzf --multi \
            --prompt "${hidden_prompt}Files (--depth=${initial_depth}) & ${curr_dir}/" \
            --header '<Alt+h>: toggle hidden, <Alt+1~3>: depth lvl, <Enter>: editor' \
        --bind "alt-h:transform:
				HIDDEN=\$(cat /tmp/fzf-hidden-state);
				DEPTH=\$(cat /tmp/fzf-depth-state);
				if [[ \$HIDDEN -eq 0 ]]; then
					echo 'reload(fd --type file --hidden -I --max-depth '\$DEPTH' | sort)+change-prompt((+hidden) Files (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 1 > /tmp/fzf-hidden-state)';
				else
					echo 'reload(fd --type file --max-depth '\$DEPTH' | sort)+change-prompt(Files (--depth='\$DEPTH') & ${curr_dir}/)+execute-silent(echo 0 > /tmp/fzf-hidden-state)';
				fi" \
            --bind "alt-1:transform:
        HIDDEN=\$(cat /tmp/fzf-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type file '\$HIDDEN_FLAG' --max-depth 1 | sort)+change-prompt('\$PROMPT'Files (--depth=1) & ${curr_dir}/)+execute-silent(echo 1 > /tmp/fzf-depth-state)';" \
            --bind "alt-2:transform:
        HIDDEN=\$(cat /tmp/fzf-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type file '\$HIDDEN_FLAG' --max-depth 2 | sort)+change-prompt('\$PROMPT'Files (--depth=2) & ${curr_dir}/)+execute-silent(echo 2 > /tmp/fzf-depth-state)';" \
            --bind "alt-3:transform:
        HIDDEN=\$(cat /tmp/fzf-hidden-state);
        HIDDEN_FLAG=''; [[ \$HIDDEN -eq 1 ]] && HIDDEN_FLAG='--hidden -I' && PROMPT='(+hidden) ';
        echo 'reload(fd --type file '\$HIDDEN_FLAG' | sort)+change-prompt('\$PROMPT'Files (--depth=end) & ${curr_dir}/)+execute-silent(echo 999 > /tmp/fzf-depth-state)';" \
            --bind "enter:execute(nvim -O {+})" \
        --preview '[[ {} =~ (".jpg"|".JPG"|".jpeg"|".png"|".PNG"|".svg")$ ]] && ueberzugpp cmd -s $SOCKET -i fzfpreview -a add -x $FZF_PREVIEW_LEFT -y $FZF_PREVIEW_TOP --max-width $FZF_PREVIEW_COLUMNS --max-height $FZF_PREVIEW_LINES -f {} || (ueberzugpp cmd -s $SOCKET -a remove -i fzfpreview && [[ $FZF_PROMPT =~ Files ]] && bat --color=always --plain {} || tree -C {})')

    rm -f /tmp/fzf-hidden-state /tmp/fzf-depth-state
    ueberzugpp cmd -s "$SOCKET" -a exit

    # if [ -n "$selected" ]; then
    #     echo $selected
    # fi
}

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

fzf_find_dir_hidden() {
    local curr_dir=${PWD/$HOME/\~}
    local prompt="(+hidden) Dir (--depth=1) & ${curr_dir}/"
    local header="<Alt+h>: toggle hidden, <Alt+1~3>: depth lvl, <Enter>: cd into"
    local dir
    dir=$(fd --type d --hidden -I --max-depth 1 \
            | awk 'BEGIN{print ".."} {print}' \
            | sort -r \
            | fzf-tmux \
            --prompt="$prompt" \
            --header="$header" \
            --bind "alt-h:become(fzf_find_dir)" \
            --bind "alt-1:change-prompt((+hidden) Dir (--depth=1) & ${curr_dir}/)+reload(fd --type d --hidden -I --max-depth 1)" \
            --bind "alt-2:change-prompt((+hidden) Dir (--depth=2) & ${curr_dir}/)+reload(fd --type d --hidden -I --max-depth 2)" \
            --bind "alt-3:change-prompt((+hidden) Dir (--depth=end) & ${curr_dir}/)+reload(fd --type d --hidden -I)" \
        --preview "tree --gitignore -dC -L 3 {}")

    if [ -n "$dir" ]; then
        cd "$dir"
        if [ $(fd --type d --max-depth 1 --hidden -I | wc -l) -gt 0 ]; then
            fzf_find_dir_hidden
        fi
    fi
}

# Switch between Ripgrep mode and fzf filtering mode (CTRL-T)
smart_grep() {
    local curr_dir=${PWD/$HOME/\~}
    rm -f /tmp/rg-fzf-{r,f}
    local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"
    : | fzf-tmux --ansi --disabled --query "$INITIAL_QUERY" \
        --prompt "ripgrep & ${curr_dir}/" \
        --header "<CTRL-T>: Toggle ripgrep / FZF" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
                echo "rebind(change)+change-prompt(ripgrep & '${curr_dir}'/)+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
                echo "unbind(change)+change-prompt(FZF & '${curr_dir}'/)+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --delimiter : \
        --preview "bat -p --theme=base16 --color=always {1} --highlight-line {2}" \
        --bind "enter:become(nvim {1} +{2})"
}

smart_grep_hidden() {
    local curr_dir=${PWD/$HOME/\~}
    rm -f /tmp/rg-fzf-{r,f}
    local RG_PREFIX="rg --hidden --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"
    : | fzf-tmux --ansi --disabled --query "$INITIAL_QUERY" \
        --prompt "ripgrep & ${curr_dir}/" \
        --header "<CTRL-T>: Toggle ripgrep / FZF" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
                echo "rebind(change)+change-prompt(ripgrep & '${curr_dir}'/)+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
                echo "unbind(change)+change-prompt(FZF & '${curr_dir}'/)+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --delimiter : \
        --preview "bat -p --theme=base16 --color=always {1} --highlight-line {2}" \
        --bind "enter:become(nvim {1} +{2})"
}

alias jj='fzf_find_dir'
alias ff='fzf_find_file_unified'
alias j='fzf_find_dir'
alias f='fzf_find_file_unified'
alias ffg='smart_grep'
alias ffg.='smart_grep_hidden'
