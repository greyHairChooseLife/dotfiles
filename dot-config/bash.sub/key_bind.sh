bind -x '"\C-l": clear_only_screen'
bind -x '"\e\C-l": clear_screen_and_scrollback'  # Alt+Ctrl+L
bind '"\C-p": previous-history'
bind '"\C-n": next-history'
bind -x '"\C-k": ff'
bind -x '"\e\C-k": ff.'
bind -x '"\C-j": ffd'
bind -x '"\e\C-j": ffd.'

# inputrc
# bind '"\C-o": edit-and-execute-command'
bind -x '"\C-o": edit_and_return_command' # 커스텀 커맨드
