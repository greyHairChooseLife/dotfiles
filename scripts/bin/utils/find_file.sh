#!/bin/bash

show_hidden=${1:-0}

ueberzugpp cmd -s "$SOCKET" -a exit 2>/dev/null

# Setup Überzug++
case "$(uname -a)" in
    *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
    *) UEBERZUG_TMP_DIR="/tmp" ;;
esac

cleanup() {
    ueberzugpp cmd -s "$SOCKET" -a exit 2>/dev/null
    rm -f /tmp/fzf-hidden-state /tmp/fzf-depth-state
}
trap cleanup HUP INT QUIT TERM EXIT

UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file "$UB_PID_FILE" >/dev/null 2>&1
UB_PID=$(cat "$UB_PID_FILE")

export SOCKET="$UEBERZUG_TMP_DIR"/ueberzugpp-"$UB_PID".socket

curr_dir=${PWD/$HOME/\~}
hidden_flag=""
hidden_prompt=""
initial_depth=1

[[ "$show_hidden" -eq 1 ]] && hidden_flag="--hidden -I" && hidden_prompt="(+hidden) "

# Initialize state files
echo "$show_hidden" > /tmp/fzf-hidden-state
echo "$initial_depth" > /tmp/fzf-depth-state

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
    --preview '[[ {} =~ (".jpg"|".JPG"|".jpeg"|".png"|".PNG"|".svg")$ ]] && ueberzugpp cmd -s $SOCKET -i fzfpreview -a add -x $FZF_PREVIEW_LEFT -y $FZF_PREVIEW_TOP --max-width $FZF_PREVIEW_COLUMNS --max-height $FZF_PREVIEW_LINES -f {} || (ueberzugpp cmd -s $SOCKET -a remove -i fzfpreview && [[ $FZF_PROMPT =~ Files ]] && bat --color=always --plain {} || tree -C {})')

rm -f /tmp/fzf-hidden-state /tmp/fzf-depth-state
ueberzugpp cmd -s "$SOCKET" -a exit 2>/dev/null

echo $selected
