# File operations
alias ls='ls --color=auto'
alias lsd='lsd --group-directories-first --date "+%Y-%m-%d %H:%M"'
alias ll='lsd -lXFt'
alias lla='lsd -lAXtF'
alias cp='cp -i'
alias rm='trash'
alias tree='tree -C -I "node_modules/"'

# System info
alias df='df -h'
alias free='free -m'

# Search
alias rg='rg --ignore-case'
alias gr='rg --ignore-case'

# Navigation
alias .='cd $HOME/dotfiles'
alias ..='cd ..'
alias ...='cd ../..'

# Clipboard
alias m='pwd | xclip -selection clipboard'
alias mm='cd "$(xclip -selection clipboard -o)"'
alias C='xclip -selection clipboard'
alias V='xclip -selection clipboard -o'

# Terminal
alias clear='clear_only_screen'
alias c='clear_only_screen'
alias ccc='clear_screen_and_scrollback && clear_only_screen'
alias e='exit'

# Editor & file manager
alias vi='nvim'
alias suvi='sudoedit'
alias x='xdg-open'
alias ee='nohup pcmanfm $PWD > /dev/null 2>&1 &'

# Package management
alias pacup='sudo pacman -Syyu'
alias yayup='yay -Syyu'

# Docker & containers
alias d='docker'
alias di='docker images'
alias dc='docker-compose'
alias lzd='lazydocker'
alias lza='lazyactions'

# Kubernetes
alias k='kubectl'

# System monitoring
alias b='btop'
alias h='htop'
alias ssz='sysz'
alias time='/usr/bin/time -f $"========== time report ==========\n실행시간: %E\nCPU: %P\n메모리: %M KB\n========== end =========="'

# Development tools
alias dbg='gdb --quiet'
alias gdb='gdb --quiet'
alias mk='make -s'
alias xx='xargs'
alias fzf='fzf --ansi'

# Media conversion
alias youtube-mp3='youtube-dl --extract-audio --audio-format mp3'
alias make-mp3='ffmpeg -i'

# Third-party tools
alias aws-tui='claws'     # github.com/clawscli/claws
alias regex='trex'        # github.com/samyakbardiya/trex
alias db='sqlit'
alias nnd='~/.local/bin/nnd'
