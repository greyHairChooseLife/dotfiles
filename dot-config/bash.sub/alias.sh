# >>> QOL(quality of life)
alias lsd='lsd --group-directories-first' # pacman -S lsd (https://github.com/lsd-rs/lsd)
alias ll='lsd -lXFt'
alias lla='lsd -lAXtF'
alias cp="cp -i"     # confirm before overwriting something
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
alias rm='trash'
alias cat='bat'
alias grep='rg --ignore-case'
alias ..='cd ..'
alias ...='cd ../..'
alias m='pwd | C'
alias mm='cd `V`'
alias clear='clear_only_screen'
alias c='clear_only_screen'
alias e='exit'
alias tree='tree -C -I "node_modules/"'
alias x='xdg-open'
alias C='xclip -selection clipboard'
alias V='xclip -o'
alias vi='nvim'
alias suvi='sudoedit'
alias ee='nohup pcmanfm $PWD > /dev/null 2>&1 &'
# <<<

# >>> manage package
alias pacup='sudo pacman -Syyu'
alias yayup='yay -Syyu'
# <<<

# >>> git
alias ga='git add'
alias gco='git commit'
alias gch='git checkout'
alias gch!='git checkout $(git branch | fzf)'
alias gp='git push'
alias gt='git tag'
alias gf='git fetch --all &'

alias gb='git branch'
alias gs='git status'
alias gl='git log'
alias gd='git --no-pager diff | delta --diff-so-fancy'
alias gst='git stash'

alias gls='git log --oneline --simplify-by-decoration --all'
alias glg='git log --oneline --graph --pretty=medium --stat'
alias glga='git log --oneline --graph --all --pretty=medium'
alias glgo='git log --oneline --graph'
alias glgao='git log --oneline --graph --all'
alias glgoa='glgao'
alias glgF='glg HEAD..' # check fetched
alias glgP='glg origin/HEAD..' # check to be pushed
alias glMM='git log --pretty=format:"COMMIT : %h%nTITLE  : %s%nMESSAGE: %b%n%cd==================================== %ae%n%n" --date=short'
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
# <<<
