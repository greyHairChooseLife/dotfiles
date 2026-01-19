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
# alias ai='aider --restore-chat-history --chat-mode architect --code-theme monokai --analytics-disable'
# alias ain='aider --chat-mode architect --code-theme monokai --analytics-disable'
# alias aiu='curl -LsSf https://aider.chat/install.sh | sh'
# alias air='aider --show-repo-map'
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

# https://github.com/clawscli/claws/cmd/claws
# go install github.com/clawscli/claws/cmd/claws@latest
alias aws-tui='claws'

# https://github.com/samyakbardiya/trex
# go install github.com/samyakbardiya/trex@latest
alias regex='trex'

alias db='sqlit'
# <<<
#
#
#
nmm1() {
    aws ssm start-session --target i-0a6da861072635265 \
        --document-name AWS-StartInteractiveCommand \
        --parameters 'command=["sudo -u ubuntu -i bash -c \"tmux new-session -A -s main\""]'

}
nmm2() {
    aws ssm start-session --target i-0c52d4471571c7e76 \
        --document-name AWS-StartInteractiveCommand \
        --parameters 'command=["sudo -u ubuntu -i bash -c \"tmux new-session -A -s main\""]'
}
nmm3() {
    aws ssm start-session --target i-04e337c7eeb34fb60 \
        --document-name AWS-StartInteractiveCommand \
        --parameters 'command=["sudo -u ubuntu -i bash -c \"tmux new-session -A -s main\""]'
}
