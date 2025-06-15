export HISTFILE=~/.bash_history    # 히스토리 명령어가 저장되는 파일 경로
export HISTSIZE=500                # 현재 세션 동안 메모리에 유지되는 명령어 최대 개수
export HISTFILESIZE=200000         # 히스토리 파일에 저장될 명령어 최대 개수
export HISTCONTROL=ignoreboth      # 중복 명령어 및 공백으로 시작한 명령어는 저장하지 않음
export HISTIGNORE="ls:cd:exit:pwd" # 지정된 명령어들은 히스토리에 기록되지 않음
shopt -s histappend                # 히스토리를 덮어쓰지 않고 파일 끝에 추가
export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
# history -a: 현재 세션의 명령어를 즉시 히스토리 파일에 추가
# history -n: 히스토리 파일에서 새로운 명령어를 읽어와 메모리에 병합

unique_history() {
    eval "$(history | awk '{ key=""; for (i=4; i<=NF; i++) key = key $i OFS; if (!seen[key]++) print }' | sort -n -k1,1 | fzf --tac \
        \
        --bind 'ctrl-e:execute(printf "%s" {4..} | xclip -selection clipboard)+abort' \
        --bind 'ctrl-w:execute(printf "%s" {4..} | xclip -selection clipboard)' \
        | awk '{for (i=4; i<=NF; i++) printf "%s ", $i; print ""}')"

}

alias fhi='unique_history'
alias hi='fhi'
