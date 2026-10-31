#!/bin/zsh
# tmux >= 3.8 dumps v2 JSON to a plain client. Old-style strings (with the CRC-16
# header) are only emitted to a control-mode client without the new-layouts flag,
# so query the session through a short-lived control client.
S=$(tmux display -p '#S')

windows=$(printf 'list-windows -F "#{window_index}: #{window_name}\t#{window_layout}"\ndetach-client\n' \
                | tmux -C attach -f ignore-size -t "$S" 2>/dev/null \
                | grep '^[0-9][0-9]*: ')

selected=$(printf '%s\n' "$windows" | fzf --prompt='window> ')

if [[ -n $selected ]]; then
        printf '%s\n' "${selected#*$'\t'}" | tee >(xclip -selection clipboard)
fi
