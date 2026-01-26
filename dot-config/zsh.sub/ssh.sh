# 1. SSH 접속 (fzf 활용)
# 사용법: s
s() {
    local config_file="$HOME/.ssh/config"
    local host

    # Host 목록 추출 및 선택 (정확한 블록 매칭 프리뷰)
    host=$(grep -E "^Host [^-*]" "$config_file" | awk '{print $2}' \
            | fzf-tmux -p 60% \
                  --header "󰆟 SSH Connect to Host" \
                  --preview "sed -n '/^Host {}$/,/^$/p' $config_file" \
                  --preview-window "right,60%")

    if [[ -n "$host" ]]; then
        echo "󰄬 Connecting to $host..."
        ssh "$host"
    fi
}

# 2. SSH Config 특정 Host 설정 수정
# 사용법: se (ssh edit)
se() {
    local config_file="$HOME/.ssh/config"
    local host

    # 수정하고 싶은 Host 선택
    host=$(grep -E "^Host [^-*]" "$config_file" | awk '{print $2}' \
            | fzf-tmux -p 60% \
                  --header "󰏫 Select SSH Host to Edit" \
                  --preview "sed -n '/^Host {}$/,/^$/p' $config_file")

    if [[ -n "$host" ]]; then
        # 선택한 Host가 위치한 줄 번호를 찾아서 해당 위치로 에디터(vim) 열기
        local line_num
        line_num=$(grep -nE "^Host $host$" "$config_file" | cut -d: -f1)

        ${EDITOR:-vim} "$config_file" +$line_num
    fi
}

# 3. SSH Config 전체 파일 열기
# 사용법: se-all
se-all() {
    ${EDITOR:-vim} "$HOME/.ssh/config"
}

alias lzs='lazyssh'
