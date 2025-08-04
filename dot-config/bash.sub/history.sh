# Create history directory if it doesn't exist
mkdir -p ~/.bash_history_dir

# PID-based history file
export HISTFILE=~/.bash_history_dir/pid_$$
export HISTSIZE=500
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:cd:exit:pwd"
# shopt -s histappend

edit_and_return_command() {
    # 현재 줄을 임시 파일에 저장
    local tmpfile=$(mktemp)
    READLINE_LINE="${READLINE_LINE:-}"
    echo "$READLINE_LINE" > "$tmpfile"
    # 에디터로 편집
    ${EDITOR:-vi} "$tmpfile"
    # 편집 결과를 다시 커맨드라인에 복원
    READLINE_LINE="$(cat "$tmpfile")"
    READLINE_POINT=${#READLINE_LINE}
    rm "$tmpfile"
}

# Function to save only successful commands
save_successful_history() {
    local exit_code=$?
    if [[ $exit_code -eq 127 ]]; then
        # Remove the last command from history if that is typo command
        history -d $(history 1 | awk '{print $1}') 2> /dev/null || true
    else
        # history -a
        local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
        if [[ -n "$last_cmd" ]]; then
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "$timestamp $(pwd) $last_cmd" >> ~/.bash_history_dir/pid_$$
        fi
    fi
    return $exit_code
}

delete_history_entry() {
    local pid="$1"
    local entry="$2"
    local histfile="$HOME/.bash_history_dir/pid_$pid"
    local tmpfile
    tmpfile=$(mktemp)
    grep -F -v -- "$entry" "$histfile" > "$tmpfile" && mv "$tmpfile" "$histfile"
}
delete_history_entry_global() {
    local entry="$1"
    local histdir="$HOME/.bash_history_dir"
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

export PROMPT_COMMAND="save_successful_history"

get_full_field_list_per_process() {
    local pid="${1:-$$}"
    cat ~/.bash_history_dir/pid_"$pid" 2> /dev/null \
        | awk '{ key=""; for (i=3; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
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
        get_full_field_list_per_process \
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
get_full_field_list_global() {
    cat ~/.bash_history_dir/pid_* 2> /dev/null \
        | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
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

# Optional: Cleanup old PID files
cleanup_old_history() {
    find ~/.bash_history_dir -name "pid_*" -mtime +7 -delete
}

export -f delete_history_entry
export -f delete_history_entry_global
export -f get_full_field_list_per_process
export -f get_full_field_list_per_process_no_path
export -f get_full_field_list_global
export -f get_full_field_list_global_no_path

# Command aliases
alias hip='per_process_history'      # Current process history
alias hi='global_history'     # Global history across all processes
