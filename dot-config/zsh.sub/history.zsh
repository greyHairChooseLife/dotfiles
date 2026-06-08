# Create history directory if it doesn't exist
mkdir -p ~/.zsh_history_dir

# Separate zsh internal history from custom history
export HISTFILE=~/.zsh_history_dir/.zsh_internal_hist_$$
export HISTSIZE=500
export SAVEHIST=0

edit_and_return_command() {
    # 현재 줄을 임시 파일에 저장
    local tmpfile=$(mktemp)
    echo "$BUFFER" > "$tmpfile"
    # 에디터로 편집
    ${EDITOR:-vi} "$tmpfile" < /dev/tty > /dev/tty
    # 편집 결과를 다시 커맨드라인에 복원
    BUFFER="$(cat "$tmpfile")"
    CURSOR=${#BUFFER}
    rm "$tmpfile"
    zle reset-prompt
}

# Format: timestamp<TAB>pwd<TAB>command
# Function to save only successful commands
save_successful_history() {
    local exit_code=$?
    if [[ $exit_code -ne 127 ]]; then
        local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
        if [[ -n "$last_cmd" ]] && [[ "$last_cmd" != "hi" ]] && [[ "$last_cmd" != "hip" ]]; then
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            printf '%s\t%s\t%s\n' "$timestamp" "$(pwd)" "$last_cmd" >> ~/.zsh_history_dir/pid_$$
        fi
    fi
    return $exit_code
}

# Use precmd hook for zsh
precmd_functions+=(save_successful_history)

# List/delete logic lives in the `zsh-history` script on $PATH so it is also
# available inside fzf's execute()/reload() subshells (zsh can't export functions).
per_process_history() {
    local pid="${1:-$$}"
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    local selected
    selected=$(
        COLUMNS=$COLUMNS zsh-history list-process ${pid} \
            | fzf \
            --ansi \
            --multi \
            --tac \
            --delimiter '\t' \
            --with-nth=1 \
            --header '<Alt+1>: filter by '${PWD}' | <Alt+2>: filter by Date(today) | <Alt+d>: delete' \
            --prompt 'history -PID- > ' \
            --bind 'enter:clear-selection+accept' \
            --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
            --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
            --bind "alt-3:reload(zsh-history list-process ${pid})" \
            --bind "alt-4:reload(zsh-history list-process --no-path ${pid})" \
            --bind "alt-d:execute-silent(zsh-history delete-process ${pid} {+2})+clear-selection+reload(zsh-history list-process ${pid})" \
            | awk -F'\t' '{print $2}'
    )
    if [[ -n "$selected" ]]; then
        if zle; then
            BUFFER="$selected"
            CURSOR=${#BUFFER}
            zle reset-prompt
        else
            print -s -- "$selected"
            eval "$selected"
        fi
    fi
}
zle -N per_process_history

# Global history function
global_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    local selected
    selected=$(
        COLUMNS=$COLUMNS zsh-history list-global \
            | fzf \
            --ansi \
            --multi \
            --tac \
            --delimiter '\t' \
            --with-nth=1 \
            --header '<Alt+1>: filter by '${PWD}' | <Alt+2>: filter by Date(today) | <Alt+d>: delete' \
            --prompt 'history -Global- > ' \
            --bind 'enter:clear-selection+accept' \
            --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
            --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
            --bind "alt-3:reload(zsh-history list-global)" \
            --bind "alt-4:reload(zsh-history list-global --no-path)" \
            --bind "alt-d:execute-silent(zsh-history delete-global {+2})+clear-selection+reload(zsh-history list-global)" \
            | awk -F'\t' '{print $2}'
    )
    if [[ -n "$selected" ]]; then
        if zle; then
            BUFFER="$selected"
            CURSOR=${#BUFFER}
            zle reset-prompt
        else
            print -s -- "$selected"
            eval "$selected"
        fi
    fi
}
zle -N global_history

# LRU cleanup: keep total history lines under MAX_HISTORY_LINES
MAX_HISTORY_LINES=50000

cleanup_history_lru() {
    local histdir="$HOME/.zsh_history_dir"
    local total
    total=$(cat "$histdir"/pid_* 2>/dev/null | wc -l)

    if (( total <= MAX_HISTORY_LINES )); then
        return
    fi

    local excess=$(( total - MAX_HISTORY_LINES ))

    # Collect lines to delete per file, then remove in batch
    local tmpmerge=$(mktemp)
    for f in "$histdir"/pid_*; do
        [ -s "$f" ] || continue
        awk -v file="$f" -v OFS='\t' '{print file, $0}' "$f"
    done | sort -t$'\t' -k2,2 | head -n "$excess" > "$tmpmerge"

    # Group deletions by file for batch processing
    local prev_file="" tmp=""
    while IFS=$'\t' read -r file line; do
        if [[ "$file" != "$prev_file" ]]; then
            # Flush previous file
            if [[ -n "$prev_file" && -n "$tmp" ]]; then
                mv "$tmp" "$prev_file"
            fi
            tmp=$(mktemp)
            cat "$file" > "$tmp"
            prev_file="$file"
        fi
        # Remove first occurrence of the line
        local tmp2=$(mktemp)
        awk -v target="$line" 'found || $0 != target { print } !found && $0 == target { found=1 }' "$tmp" > "$tmp2"
        mv "$tmp2" "$tmp"
    done < "$tmpmerge"
    # Flush last file
    if [[ -n "$prev_file" && -n "$tmp" ]]; then
        mv "$tmp" "$prev_file"
    fi

    # Remove empty pid files
    find "$histdir" -name "pid_*" -empty -delete

    rm -f "$tmpmerge"
}

# Run LRU cleanup at most once per day (with flock to prevent race conditions)
(
    flock -n 9 || exit 0
    marker="$HOME/.zsh_history_dir/.last_cleanup"
    if [[ -f "$marker" ]]; then
        [[ "$(cat "$marker")" == "$(date '+%Y-%m-%d')" ]] && exit 0
    fi
    cleanup_history_lru
    date '+%Y-%m-%d' > "$marker"
) 9>"$HOME/.zsh_history_dir/.cleanup.lock" > /dev/null 2>&1 &!

# Command aliases
alias hip=' per_process_history'      # Current process history
alias hi=' global_history'     # Global history across all processes
