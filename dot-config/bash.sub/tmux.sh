export TMUX_CONFIG_DIR="$HOME/.config/tmux"
export TMUX_PLUGIN_DIR="$HOME/.local/bin/tmux/plugins"
export TMUX_RESURRECT_DIR="$HOME/.local/state/tmux-resurrects/"
export TMUXP_CONFIGDIR="$HOME/.config/tmuxp"

alias t='tmux'
alias tt='tmux attach \
  \; choose-tree -swZ -F "#{?pane_format,#[fg=green] #{pane_current_command} #[fg=brightblack]#{pane_current_path},#{?window_format,#[fg=#0000ff]  #[fg=#c1cdc1]#{?#{window_active},#[bg=#181d5f],} #{=|7|...;p10:window_name} #{?window_flags,#[fg=brightblack#,bg=default] 󰇘 #[fg=#0000ff]#{?#{window_last_flag},󰽒, }#{?#{window_zoomed_flag}, , },},#{?session_grouped, (group #{session_group}: #{session_group_list}),}#{?session_attached,#[fg=violet] ,''}#{?#{==:#{@copied_client_session},#{session_name}}, #[fg=brightblack]󰇘 #[fg=brightred]󰋜 now,}}}" \
  || tmux new-session'

alias tp='tmuxp'

alias tpl='sel=$(tp ls | tac | fzf --header="Attach or Create the selected session" --preview "bat --color=always ${TMUXP_CONFIGDIR}/{}.yaml"); \
  [ -n "$sel" ] && tmuxp load -y "$sel"'
alias tpl.='tmuxp load ./tmuxp.yaml'

alias tpe='sel=$(tp ls | tac | fzf --header="Edit the selected session spec" --preview "bat --color=always ${TMUXP_CONFIGDIR}/{}.yaml"); \
  [ -n "$sel" ] && tmuxp edit "$sel"'
alias tpe.='tmuxp edit ./tmuxp.yaml'

# 외않되
# set_pane_title() {
#     printf '\033]2;%s\033\\' "$1"
# }

tm.1_title() {
    local name="${1:-$(ps -o comm= -p "$PPID")}"
    # [ -n "$TMUX" ] && tmux set -p @mytitle "$name"
    [ -n "$TMUX" ] && tmux set -p -t "$TMUX_PANE" @mytitle "$name"
}

tm.2_toggle_border() {
    current=$(tmux show -svg @pane_border_toggle 2> /dev/null)
    if [ "$current" = "on" ]; then
        tmux set -s @pane_border_toggle ""
    else
        tmux set -s @pane_border_toggle on
    fi
}

alias 1='tm.1_title'
alias 2='tm.2_toggle_border'
# select tmux window and copy its layout
alias tlayout='bash /home/sy/dotfiles/dot-config/bash.sub/scripts/tmux/cp_layout_fzf.sh'
