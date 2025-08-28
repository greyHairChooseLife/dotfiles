export TMUX_CONFIG_DIR="$HOME/.config/tmux"
export TMUX_PLUGIN_DIR="$HOME/.local/bin/tmux/plugins"
export TMUX_RESURRECT_DIR="$HOME/.local/state/tmux-resurrects/"
export TMUXP_CONFIGDIR="$HOME/.config/tmuxp"

alias t='tmux'
alias tt='tmux attach \
  \; choose-tree -swZ -F "#{?pane_format,#[fg=green] #{pane_current_command} #[fg=brightblack]#{pane_current_path},#{?window_format,#[fg=#0000ff]  #[fg=#c1cdc1]#{?#{window_active},#[bg=#181d5f],} #{=|7|...;p10:window_name} #{?window_flags,#[fg=brightblack#,bg=default] 󰇘 #[fg=#0000ff]#{?#{window_last_flag},󰽒, }#{?#{window_zoomed_flag}, , },},#{?session_grouped, (group #{session_group}: #{session_group_list}),}#{?session_attached,#[fg=violet] ,''}#{?#{==:#{@copied_client_session},#{session_name}}, #[fg=brightblack]󰇘 #[fg=brightred]󰋜 now,}}}" \
  || tmux new-session'

alias tp='tmuxp'

alias tpl='sel=$(tp ls | tac | fzf --preview "bat --color=always ${TMUXP_CONFIGDIR}/{}.yaml"); \
  [ -n "$sel" ] && tmuxp load -y "$sel"'

alias tpe='sel=$(tp ls | tac | fzf --preview "bat --color=always ${TMUXP_CONFIGDIR}/{}.yaml"); \
  [ -n "$sel" ] && tmuxp edit "$sel"'
