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

delete_history_entry() {
    local pid="$1"
    local entry="$2"
    local histfile="$HOME/.zsh_history_dir/pid_$pid"
    local tmpfile
    tmpfile=$(mktemp)
    grep -F -v -- "$entry" "$histfile" > "$tmpfile" && mv "$tmpfile" "$histfile"
    rm -f "$tmpfile"
}
delete_history_entry_global() {
    local entry="$1"
    local histdir="$HOME/.zsh_history_dir"
    local tmpfile
    for file in "$histdir"/pid_*; do
        [ -e "$file" ] || continue
        if grep -F -q -- "$entry" "$file"; then
            tmpfile=$(mktemp)
            grep -F -v -- "$entry" "$file" > "$tmpfile" && mv "$tmpfile" "$file"
            rm -f "$tmpfile"
            return 0
        fi
    done
    return 1
}

# Use precmd hook for zsh
precmd_functions+=(save_successful_history)

_hist_format() {
    local cols=${COLUMNS:-$(tput cols)}
    awk -F'\t' -v cols="$cols" '{
        cmd=$1; meta=$3"  "$2
        pad=cols-length(cmd)-length(meta)
        if(pad<4) pad=4
        printf "%s%*s%s\t%s\n", cmd, pad, "", meta, cmd
    }'
}
get_full_field_list_per_process() {
    local pid="${1:-$$}"
    cat ~/.zsh_history_dir/pid_"$pid" 2> /dev/null \
        | awk -F'\t' '{ if (!seen[$3]++) print $3"\t"$1"\t"$2 }' \
        | sort -t$'\t' -k2,2 \
        | _hist_format
}
get_full_field_list_per_process_no_path() {
    local pid="${1:-$$}"
    cat ~/.zsh_history_dir/pid_"$pid" 2> /dev/null \
        | awk -F'\t' '{ if (!seen[$3]++) print $3"\t"$1"\t..." }' \
        | sort -t$'\t' -k2,2 \
        | _hist_format
}
per_process_history() {
    local pid="${1:-$$}"
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    local selected
    selected=$(
        get_full_field_list_per_process ${pid} \
            | fzf \
                --tac \
                --delimiter '\t' \
                --with-nth=1 \
                --header '<Alt+1>: filter by '${PWD}' ' \
                --prompt 'history -PID- > ' \
                --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
                --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
                --bind "alt-1:put(${today})" \
                --bind "alt-2:put(${pwd_escaped})" \
                --bind "alt-3:reload(get_full_field_list_per_process ${pid})" \
                --bind "alt-4:reload(get_full_field_list_per_process_no_path ${pid})" \
                --bind "alt-d:execute(delete_history_entry ${pid} {})+reload(get_full_field_list_per_process ${pid})" \
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
get_full_field_list_global() {
    cat ~/.zsh_history_dir/pid_* 2> /dev/null \
        | awk -F'\t' 'NF>=3 { if (!seen[$3]++) print $3"\t"$1"\t"$2 }' \
        | sort -t$'\t' -k2,2 \
        | _hist_format
}
get_full_field_list_global_no_path() {
    cat ~/.zsh_history_dir/pid_* 2> /dev/null \
        | awk -F'\t' 'NF>=3 { if (!seen[$3]++) print $3"\t"$1"\t..." }' \
        | sort -t$'\t' -k2,2 \
        | _hist_format
}
global_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    local selected
    selected=$(
        get_full_field_list_global \
            | fzf \
                --tac \
                --delimiter '\t' \
                --with-nth=1 \
                --header '<Alt+1>: filter by '${PWD}' ' \
                --prompt 'history -Global- > ' \
                --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
                --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
                --bind "alt-1:put(${today})" \
                --bind "alt-2:put(${pwd_escaped})" \
                --bind "alt-3:reload(get_full_field_list_global)" \
                --bind "alt-4:reload(get_full_field_list_global_no_path)" \
                --bind "alt-d:execute(delete_history_entry_global {})+reload(get_full_field_list_global)" \
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
