# >>> QOL(quality of life)
alias ls='lsd --group-directories-first' # pacman -S lsd (https://github.com/lsd-rs/lsd)
alias ll='ls -lXF --group-directories-first'
alias lla='ls -lAXtF --group-directories-first'
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
alias c='clear'
alias e='exit'
alias tree='tree -C -I "node_modules/"'
alias x='xdg-open'
alias C='xclip'
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

alias gb='git branch'
alias gs='git status'
alias gd='git --no-pager diff | delta --diff-so-fancy'
alias gdn='git diff HEAD | diffnav'
alias gst='git stash'
alias gl='git log'

alias glo='git log --oneline'
alias glg='git log --oneline --graph --branches'
alias glgr='git log --oneline --graph --remotes'
alias glga='git log --oneline --graph --all'
alias glgHEAD='git log --oneline --graph HEAD'
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


# >>> note-taking
alias docup='(cd /home/sy/Documents/dev-wiki && git add . && git diff-index --quiet HEAD || git commit -m "write" && git push) && (cd /home/sy/Documents/job-wiki && git add . && git diff-index --quiet HEAD || git commit -m "write" && git push)'
alias doc1='cd /home/sy/Documents/dev-wiki && nvim -c "VimwikiIndex"'
alias doc2='cd /home/sy/Documents/job-wiki && nvim -c "2VimwikiIndex"'
# <<<


# >>> AI
alias ai='aider --chat-mode architect --code-theme monokai --analytics-disable'
# <<<


# >>> tmux
alias t='tmux attach \
  \; choose-tree -swZ -F "#{?pane_format,#[fg=green] #{pane_current_command} #[fg=brightblack]#{pane_current_path},#{?window_format,#[fg=#0000ff]  #[fg=#c1cdc1]#{?#{window_active},#[bg=#181d5f],} #{=|7|...;p10:window_name} #{?window_flags,#[fg=brightblack#,bg=default] 󰇘 #[fg=#0000ff]#{?#{window_last_flag},󰽒, }#{?#{window_zoomed_flag}, , },},#{?session_grouped, (group #{session_group}: #{session_group_list}),}#{?session_attached,#[fg=violet] ,''}#{?#{==:#{@copied_client_session},#{session_name}}, #[fg=brightblack]󰇘 #[fg=brightred]󰋜 now,}}}" \
  || tmux new-session'
# <<<


# >>> etc
alias youtube-mp3="youtube-dl --extract-audio --audio-format mp3" # usage : youtube-mp3 url
alias make-mp3="ffmpeg -i"                                        # usage : make-mp3 original-file.mp4 new-name.mp3
alias py='python'
# <<<
