# Wrapper widgets for interactive functions
_clear_only_screen_widget() {
    clear_only_screen
    zle reset-prompt
}

_clear_screen_and_scrollback_widget() {
    clear_screen_and_scrollback
    zle reset-prompt
}

_edit_and_return_command_widget() {
    zle -I
    edit_and_return_command
}

_a_widget() {
    zle -I
    a < /dev/tty
    zle reset-prompt
}


# Register widgets
zle -N _clear_only_screen_widget
zle -N _clear_screen_and_scrollback_widget
zle -N _edit_and_return_command_widget
zle -N _a_widget

# Key bindings
# unmap
bindkey -e
bindkey -r "^[h"
bindkey -r "^[H"

bindkey '^L' _clear_only_screen_widget
bindkey '^[^L' _clear_screen_and_scrollback_widget  # Alt+Ctrl+L

bindkey '^O' _edit_and_return_command_widget  # 커스텀 커맨드
bindkey '^[^O' _a_widget  # Alt+Ctrl+o 커스텀 커맨드


# History navigation
bindkey '^P' up-history
bindkey '^N' down-history

fzf-fg() {
    local job tmpfile
    tmpfile=$(mktemp)
    jobs > "$tmpfile"
    cat "$tmpfile" >&2  # 디버그: 실제 내용 확인
    job=$(fzf-tmux -p < "$tmpfile" | sed -E 's/\[(.+)\].*/\1/')
    rm -f "$tmpfile"
    [[ -n "$job" ]] && fg %$job
}
zle -N fzf-fg
bindkey '^[z' fzf-fg
