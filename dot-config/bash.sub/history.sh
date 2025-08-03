# Create history directory if it doesn't exist
mkdir -p ~/.bash_history_dir

# PID-based history file
export HISTFILE=~/.bash_history_dir/pid_$$
export HISTSIZE=500
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:cd:exit:pwd"
# shopt -s histappend

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

export PROMPT_COMMAND="save_successful_history"

per_process_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}\\")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    eval "$(cat ~/.bash_history_dir/pid_$$ 2> /dev/null \
        | awk '{ key=""; for (i=3; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
        | sort \
            -n -k1,2 \
        | fzf \
            --tac \
            --header '<Alt+1>: filter by '${PWD}' ' \
            --prompt 'history -PID- > ' \
            --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
            \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
        |
        # --bind 'ctrl-w:execute(printf "%s" {4..} | xclip -selection clipboard)' \
          awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}')"
}

# Global history function (using rg)
global_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%Y-%m-%d')")

    eval "$(cat ~/.bash_history_dir/pid_* 2> /dev/null \
        | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' \
        | sort \
            -n -k1,2 \
        | fzf \
            --tac \
            --header '<Alt+1>: filter by '${PWD}' ' \
            --prompt 'history -Global- > ' \
            --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
            \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
        |
        # --bind 'ctrl-w:execute(printf "%s" {4..} | xclip -selection clipboard)' \
          awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}')"
}

# Optional: Cleanup old PID files
cleanup_old_history() {
    find ~/.bash_history_dir -name "pid_*" -mtime +7 -delete
}

# Command aliases
alias hip='per_process_history'      # Current process history
alias hi='global_history'     # Global history across all processes

# DEPRECATED:: 2025-06-16
# export HISTFILE=~/.bash_history    # 히스토리 명령어가 저장되는 파일 경로
# export HISTSIZE=500                # 현재 세션 동안 메모리에 유지되는 명령어 최대 개수
# export HISTFILESIZE=200000         # 히스토리 파일에 저장될 명령어 최대 개수
# export HISTCONTROL=ignoreboth      # 중복 명령어 및 공백으로 시작한 명령어는 저장하지 않음
# export HISTIGNORE="ls:cd:exit:pwd" # 지정된 명령어들은 히스토리에 기록되지 않음
# shopt -s histappend                # 히스토리를 덮어쓰지 않고 파일 끝에 추가
# export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
# # history -a: 현재 세션의 명령어를 즉시 히스토리 파일에 추가
# # history -n: 히스토리 파일에서 새로운 명령어를 읽어와 메모리에 병합
# unique_history() {
#     eval "$(history | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' | sort -n -k1,1 | fzf --tac \
#         \
#         --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
#         --bind 'ctrl-w:execute(printf "%s" {4..} | xclip -selection clipboard)' \
#         | awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}')"
# }
# alias fhi='unique_history'
# alias hi='fhi'
