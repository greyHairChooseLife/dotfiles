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

_fzf_find_file_unified_widget() {
    zle -I
    fzf_find_file_unified < /dev/tty
    zle reset-prompt
}

_smart_grep_widget() {
    zle -I
    smart_grep < /dev/tty
    zle reset-prompt
}

# _fzf_find_dir_widget() {
#     zle -I
#     fzf_find_dir
#     zle reset-prompt
# }

# Register widgets
zle -N _clear_only_screen_widget
zle -N _clear_screen_and_scrollback_widget
zle -N _edit_and_return_command_widget
zle -N _a_widget
zle -N _fzf_find_file_unified_widget
zle -N _smart_grep_widget
# zle -N _fzf_find_dir_widget

# Key bindings
bindkey '^L' _clear_only_screen_widget
bindkey '^[^L' _clear_screen_and_scrollback_widget  # Alt+Ctrl+L

bindkey '^O' _edit_and_return_command_widget  # 커스텀 커맨드
bindkey '^[^O' _a_widget  # 커스텀 커맨드

bindkey '^K' _fzf_find_file_unified_widget
bindkey '^[^K' _smart_grep_widget
# bindkey '^J' _fzf_find_dir_widget  # C-j는 전통적으로 \n에 해당한다

# History navigation
bindkey '^P' up-history
bindkey '^N' down-history
