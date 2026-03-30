# Create history directory if it doesn't exist
mkdir -p ~/.zsh_history_dir

# PID-based history file
export HISTFILE=~/.zsh_history_dir/pid_$$
export HISTSIZE=500
export SAVEHIST=200000

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

# Function to save only successful commands
save_successful_history() {
    local exit_code=$?
    if [[ $exit_code -eq 127 ]]; then
        # Remove the last command from history if that is typo command
        fc -W
        sed -i '$ d' "$HISTFILE"
        fc -R
    else
        local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
        if [[ -n "$last_cmd" ]]; then
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "$timestamp $(pwd) $last_cmd" >> ~/.zsh_history_dir/pid_$$
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

get_full_field_list_per_process() {
    local pid="${1:-$$}"
    cat ~/.zsh_history_dir/pid_"$pid" 2> /dev/null \
        | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
        | sort -n -k1,2
}
get_full_field_list_per_process_no_path() {
    local pid="${1:-$$}"
    get_full_field_list_per_process $pid | awk '{$3="..."; print $0}'
}
per_process_history() {
    local pid="${1:-$$}"
    local pwd_escaped=$(printf ' %s ' "'${PWD}\\")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    eval "$(
        get_full_field_list_per_process ${pid} \
            | fzf \
                --tac \
                --header '<Alt+1>: filter by '${PWD}' ' \
                --prompt 'history -PID- > ' \
                --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
                --bind 'alt-e:execute(printf "%s" {4..} | xclip -selection clipboard)' \
                --bind "alt-1:put(${today})" \
                --bind "alt-2:put(${pwd_escaped})" \
                --bind "alt-3:reload(get_full_field_list_per_process ${pid})" \
                --bind "alt-4:reload(get_full_field_list_per_process_no_path ${pid})" \
                --bind "alt-d:execute(delete_history_entry ${pid} {})+reload(get_full_field_list_per_process ${pid})" \
            | awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}'
    )"
}

# Global history function (using rg)
# datetime으로 시작하는것만 추려
get_full_field_list_global() {
    cat ~/.zsh_history_dir/pid_* 2> /dev/null \
        | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
        | rg -- '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' \
        | sort -n -k1,2
}
get_full_field_list_global_no_path() {
    get_full_field_list_global | awk '{$3="..."; print $0}'
}
global_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    eval "$(
        get_full_field_list_global \
            | fzf \
                --tac \
                --header '<Alt+1>: filter by '${PWD}' ' \
                --prompt 'history -Global- > ' \
                --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
                --bind 'alt-e:execute(printf "%s" {4..} | xclip -selection clipboard)' \
                --bind "alt-1:put(${today})" \
                --bind "alt-2:put(${pwd_escaped})" \
                --bind "alt-3:reload(get_full_field_list_global)" \
                --bind "alt-4:reload(get_full_field_list_global_no_path)" \
                --bind "alt-d:execute(delete_history_entry_global {})+reload(get_full_field_list_global)" \
            | awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}'
    )"
}

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

    # Merge all entries with source file, sort by timestamp, find oldest to remove
    local tmpmerge=$(mktemp)
    for f in "$histdir"/pid_*; do
        [ -s "$f" ] || continue
        awk -v file="$f" '{print file "\t" $0}' "$f"
    done | sort -t$'\t' -k2,3 | head -n "$excess" > "$tmpmerge"

    # Remove oldest lines from their respective files (one match at a time)
    while IFS=$'\t' read -r file line; do
        local tmp=$(mktemp)
        awk -v target="$line" 'found || $0 != target { print } !found && $0 == target { found=1 }' "$file" > "$tmp" && mv "$tmp" "$file"
        rm -f "$tmp"
    done < "$tmpmerge"

    # Remove empty pid files
    find "$histdir" -name "pid_*" -empty -delete

    rm -f "$tmpmerge"
}

# Run LRU cleanup on shell startup (with flock to prevent race conditions)
(
    flock -n 9 || exit 0
    cleanup_history_lru
) 9>"$HOME/.zsh_history_dir/.cleanup.lock" > /dev/null 2>&1 &!

# Command aliases
alias hip='per_process_history'      # Current process history
alias hi='global_history'     # Global history across all processes
