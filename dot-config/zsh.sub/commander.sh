# DEPRECATED:: 2025-12-30
# alias a='eval $(cat ~/.commands | sed '/^#/d' | fzf --reverse)'

a() {
    local selected
    local ansi_strip="s/\x1b\[[0-9;]*m//g"

    # 1. 구분선(---)은 제외하고 목록을 보여줌
    # 2. fzf 프리뷰에서 bat을 통해 쉘 문법 강조 적용
    selected=$(grep -vE "^(#|$)" ~/.commands | fzf-tmux -p 60% \
        --ansi \
        --height 40% \
        --border \
        --padding 0 \
        --color='border:green' \
        --preview "grep -B 1 -F -- {} ~/.commands | bat --color=always --style=plain --language=sh" \
        --preview-window='top:5' \
        --header "ENTER: 실행 | CTRL-C: 취소")

    # 선택된 줄이 있고, 주석(#)으로 시작하지 않을 때만 실행
    if [[ -n "$selected" ]]; then
        if [[ "$selected" =~ ^# ]]; then
            echo "주석은 실행할 수 없습니다: $selected"
        else
            # 히스토리에 기록하고 실행
            print -s "$selected" 2> /dev/null || history -s "$selected"

            # ANSI 색상 코드 제거 (순수 텍스트 추출)
            selected=$(echo "$selected" | sed "$ansi_strip")

            echo -e "\033[1;32mExecuting:\033[0m $selected"
            eval "$selected"
        fi
    fi
}
