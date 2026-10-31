#!/bin/zsh
# tmux >= 3.8 dumps v2 JSON to a plain client. Old-style strings (with the CRC-16
# header) are only emitted to a control-mode client without the new-layouts flag,
# so query the session through a short-lived control client.
S=$(tmux display -p '#S')
CUR=$(tmux display -p '#{window_index}')

layout=$(printf 'list-windows -F "#{window_index}|#{window_layout}"\ndetach-client\n' \
              | tmux -C attach -f ignore-size -t "$S" 2>/dev/null \
              | sed -n "s/^${CUR}|//p")

if [[ -z $layout ]]; then
        tmux display-message "layout copy failed"
        exit 1
fi

printf '%s\n' "$layout" | tee >(xclip -selection clipboard)
tmux display-message "layout copyed"
