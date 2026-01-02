# >>> QOL(quality of life)
alias lsd='lsd --group-directories-first' # pacman -S lsd (https://github.com/lsd-rs/lsd)
alias ll='lsd -lXFt'
alias lla='lsd -lAXtF'
alias cp="cp -i"     # confirm before overwriting something
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias rm='trash'
# alias cat='bat'
# alias grep='rg --ignore-case'
alias rg='rg --ignore-case'
alias gr='rg --ignore-case'
alias ..='cd ..'
alias ...='cd ../..'
alias m='pwd | xclip -selection clipboard'
alias mm='cd "$(xclip -selection clipboard -o)"'
alias clear='clear_only_screen'
alias c='clear_only_screen'
alias ccc='clear_screen_and_scrollback && clear_only_screen'
alias e='exit'
alias tree='tree -C -I "node_modules/"'
alias x='xdg-open'
alias C='xclip -selection clipboard'
alias V='xclip -selection clipboard -o'
alias vi='nvim'
alias suvi='sudoedit'
alias ee='nohup pcmanfm $PWD > /dev/null 2>&1 &'
# <<<

# >>> manage package
alias pacup='sudo pacman -Syyu'
alias yayup='yay -Syyu'
# <<<

# >>> docker
alias d='docker'
alias di='docker images'
alias dc='docker-compose'
alias lzd='lazydocker'
# <<<

# >>> system & server
alias k='kubectl'
alias ssz='sysz' # forked for customizations, save it under HOME/.local/bin/sysz
# <<<

# >>> AI
alias ai='aider --restore-chat-history --chat-mode architect --code-theme monokai --analytics-disable'
alias ain='aider --chat-mode architect --code-theme monokai --analytics-disable'
alias aiu='curl -LsSf https://aider.chat/install.sh | sh'
alias air='aider --show-repo-map'
# <<<

# >>> etc
alias youtube-mp3="youtube-dl --extract-audio --audio-format mp3" # usage : youtube-mp3 url
alias make-mp3="ffmpeg -i"                                        # usage : make-mp3 original-file.mp4 new-name.mp3
alias b='btop'
alias h='htop'
alias time='/usr/bin/time -f $"========== time report ==========\n실행시간: %E\nCPU: %P\n메모리: %M KB\n========== end =========="'
alias nnd='~/.local/bin/nnd'
alias dbg='gdb --quiet'
alias gdb='gdb --quiet'
alias xx='xargs'
alias dot='cd $HOME/dotfiles'
alias mk='make -s'
alias fzf='fzf --ansi'
# <<<

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

ssh_from_ssh-config() {
    # ~/.ssh/config에서 Host 항목 추출 (주석과 빈 줄 제외)
    local hosts=$(grep '^Host ' ~/.ssh/config | awk '{print $2}' | grep -v '^\*$')

    # fzf로 호스트 선택
    local selected=$(echo "$hosts" | fzf --prompt="Select SSH host: ")

    # 선택된 호스트가 있으면 ssh 실행
    if [ -n "$selected" ]; then
        ssh "$selected"
    fi
}
