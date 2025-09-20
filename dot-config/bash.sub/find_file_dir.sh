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
        | fzf --prompt "Images: " \
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
          fzf --prompt "Images: " \
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
    local show_hidden=${1:-0}  # Default: don't show hidden files

    ueberzugpp cmd -s "$SOCKET" -a exit

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

    # Run fzf with Überzug++ for image previews
    local curr_dir=${PWD/$HOME/\~}

    # Set up initial commands based on hidden flag
    local hidden_flag=""
    local hidden_prompt=""
    local toggle_cmd="fzf_find_file_unified 0"

    if [[ "$show_hidden" -eq 1 ]]; then
        hidden_flag="--hidden -I"
        hidden_prompt="(+hidden) "
        toggle_cmd="fzf_find_file_unified 0"
    else
        toggle_cmd="fzf_find_file_unified 1"
    fi

    # Initial command
    fd --type file $hidden_flag | sort \
        | fzf --prompt "${hidden_prompt}Files (--depth=end) & ${curr_dir}/" \
            --header '<Alt+h>: toggle hidden, <Alt+1~3>: depth lvl, <Enter>: editor' \
            --bind "alt-h:become($toggle_cmd)" \
            --bind "alt-1:change-prompt(${hidden_prompt}Files (--depth=1) & ${curr_dir}/)+reload(fd --type file $hidden_flag --max-depth 1 | sort)" \
            --bind "alt-2:change-prompt(${hidden_prompt}Files (--depth=2) & ${curr_dir}/)+reload(fd --type file $hidden_flag --max-depth 2 | sort)" \
            --bind "alt-3:change-prompt(${hidden_prompt}Files (--depth=end) & ${curr_dir}/)+reload(fd --type file $hidden_flag | sort)" \
            --bind "enter:become(nvim -O {+})" \
            --preview '[[ {} =~ (".jpg"|".JPG"|".jpeg"|".png"|".PNG"|".svg")$ ]] && ueberzugpp cmd -s $SOCKET -i fzfpreview -a add -x $FZF_PREVIEW_LEFT -y $FZF_PREVIEW_TOP --max-width $FZF_PREVIEW_COLUMNS --max-height $FZF_PREVIEW_LINES -f {} || (ueberzugpp cmd -s $SOCKET -a remove -i fzfpreview && [[ $FZF_PROMPT =~ Files ]] && bat --color=always --plain {} || tree -C {})'

    # Cleanup Überzug++
    ueberzugpp cmd -s "$SOCKET" -a exit
}

fzf_find_dir() {
    local curr_dir="${PWD/$HOME/\~}"
    local prompt="Dir (--depth=1) & ${curr_dir}/"
    local header="<Alt+h>: toggle hidden, <Alt+1~3>: depth lvl, <Enter>: cd into"
    local dir
    dir=$(fd --type d --max-depth 1 \
        | awk 'BEGIN{print ".."} {print}' \
        | sort -r \
        | fzf \
            --prompt="$prompt" \
            --header="$header" \
            --bind "alt-h:become(fzf_find_dir_hidden)" \
            --bind "alt-1:change-prompt(Dir (--depth=1) & ${curr_dir}/)+reload(fd --type d --max-depth 1)" \
            --bind "alt-2:change-prompt(Dir (--depth=2) & ${curr_dir}/)+reload(fd --type d --max-depth 2)" \
            --bind "alt-3:change-prompt(Dir (--depth=end) & ${curr_dir}/)+reload(fd --type d)" \
            --preview 'tree --gitignore -dC -L 3 {}')

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
        | fzf \
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
    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
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
    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
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

# alias ff='fzf_find_file'
# alias ff.='fzf_find_file_hidden'

alias fff='fzf_find_file_unified'
alias ffd='fzf_find_dir'
alias ffd.='fzf_find_dir_hidden'
alias j='fzf_find_dir'
alias j.='fzf_find_dir_hidden'
alias ffg='smart_grep'
alias ffg.='smart_grep_hidden'

export -f fzf_find_image_file
export -f fzf_find_file_unified
export -f fzf_find_dir
export -f fzf_find_dir_hidden
