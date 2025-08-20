bind -x '"\C-l": clear_only_screen'
bind -x '"\e\C-l": clear_screen_and_scrollback'  # Alt+Ctrl+L

bind -x '"\C-o": edit_and_return_command' # 커스텀 커맨드

bind -x '"\C-k": fzf_find_file_unified'
bind -x '"\e\C-k": smart_grep'
# bind -x '"\C-j": fzf_find_dir && echo -e "  󱞪  $(pwd)/\n   $(tree --metafirst | tail -1)" && echo'
bind -x '"\C-j": echo && fzf_find_dir && echo "   $(pwd)/"'
bind -x '"\e\C-j": echo && fzf_find_dir_hidden && echo "   $(pwd)/"'

# inputrc
# bind '"\C-o": edit-and-execute-command'
bind '"\C-p": previous-history'
bind '"\C-n": next-history'
