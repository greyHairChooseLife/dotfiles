export TMUX_CONFIG_DIR="$HOME/.config/tmux"
export TMUX_PLUGIN_DIR="$HOME/.local/bin/tmux/plugins"
export TMUX_RESURRECT_DIR="$HOME/.local/state/tmux-resurrects/"
export TMUXP_CONFIGDIR="$HOME/.config/tmuxp"

alias t='tmux'
alias tt='tmux attach \
  \; choose-tree -swZ -F "#{?pane_format,#[fg=green] #{pane_current_command} #[fg=brightblack]#{pane_current_path},#{?window_format,#[fg=#0000ff]  #[fg=#c1cdc1]#{?#{window_active},#[bg=#181d5f],} #{=|7|...;p10:window_name} #{?window_flags,#[fg=brightblack#,bg=default] 󰇘 #[fg=#0000ff]#{?#{window_last_flag},󰽒, }#{?#{window_zoomed_flag}, , },},#{?session_grouped, (group #{session_group}: #{session_group_list}),}#{?session_attached,#[fg=violet] ,''}#{?#{==:#{@copied_client_session},#{session_name}}, #[fg=brightblack]󰇘 #[fg=brightred]󰋜 now,}}}" \
  || tmux new-session'


tp() {
    local entries=()
    local files
    files=$(fd . "$TMUXP_CONFIGDIR" --max-depth 1 -e yaml -e json | sort -r | sed "s|.*/tmuxp/||")
    [ -f ./tmuxp.yaml ] && entries+=("./tmuxp.yaml")
    entries+=(${(f)files})

    local out key sel
    local cfgdir="$TMUXP_CONFIGDIR"
    out=$(printf '%s\n' "${entries[@]}" | fzf-tmux -p 80%,80% \
            --header="enter:load  alt-1:edit  alt-2:new" \
            --preview "[ {} = ./tmuxp.yaml ] && bat --color=always {} || bat --color=always ${cfgdir}/{}" \
        --expect="alt-1,alt-2")

    key=$(head -1 <<< "$out")
    sel=$(tail -1 <<< "$out")

    case "$key" in
        alt-1)
            [ -z "$sel" ] && return
            local fpath
            [[ $sel == ./tmuxp.yaml ]] && fpath="$PWD/tmuxp.yaml" || cd ${TMUXP_CONFIGDIR} && fpath="${TMUXP_CONFIGDIR}/$sel"
            tmuxp edit "$fpath"
            ;;
        alt-2)
            local scope
            scope=$(printf 'global\nlocal' | fzf-tmux -p 40%,20% --header="New tmuxp config: global or local?")
            [ -z "$scope" ] && return
            local example="${TMUXP_CONFIGDIR}/example.yaml"
            if [ "$scope" = local ]; then
                local target="$PWD/tmuxp.yaml"
                cp "$example" "$target"
                cd $PWD
                tmuxp edit "$target"
            else
                printf "Config name (without extension): "
                read -r name < /dev/tty
                [ -z "$name" ] && return
                local target="${TMUXP_CONFIGDIR}/${name}.yaml"
                cp "$example" "$target"
                cd ${TMUXP_CONFIGDIR}
                tmuxp edit "$target"
            fi
            ;;
        *)
            [ -z "$sel" ] && return
            local fpath
            [[ $sel == ./tmuxp.yaml ]] && fpath="$PWD/tmuxp.yaml" || fpath="${TMUXP_CONFIGDIR}/$sel"
            tmuxp load -y "$fpath"
            ;;
    esac
}

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
alias tlayout='zsh ${HOME}/dotfiles/dot-config/zsh.sub/scripts/tmux/cp_layout_fzf.sh'

# tmux new session with title
tn() {
    local title="${1:-anon}"
    if [ -n "$TMUX" ]; then
        tmux new-session -d -s "$title" && tmux switch-client -t "$title"
    else
        tmux new-session -s "$title"
    fi
}
