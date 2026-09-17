#!/usr/bin/env bash
# Keep tmux cursor-colour aligned with the mode the focused client is in.
#
# Why this exists: cursor-colour accepts only a literal colour and rejects
# formats ("bad colour"), so it cannot be derived from @current_mode_format
# inside tmux.conf. It is recomputed on demand instead, from the tmux hooks
# and the switch_mode_* command aliases.
#
# cursor-colour is a session option, and -t <client> resolves to that client's
# session. Scoping the write that way keeps clients sitting on different
# sessions independent of each other.
#
# Usage: sync_cursor_colour.sh [client_name]
#        With no argument the focused client is used.

set -u

client="${1:-}"

if [ -z "$client" ]; then
    client=$(tmux list-clients -F '#{client_name} #{client_flags}' 2>/dev/null |
        awk '/focused/ {print $1; exit}')
fi
if [ -z "$client" ]; then
    client=$(tmux list-clients -F '#{client_name}' 2>/dev/null | head -n1)
fi
[ -z "$client" ] && exit 0

# pane_in_mode must win over client_key_table: copy mode keeps the client key
# table at "root" and exposes itself only through the pane.
state=$(tmux display-message -p -t "$client" \
    '#{pane_in_mode} #{client_key_table}' 2>/dev/null) || exit 0
[ -z "$state" ] && exit 0

in_mode=${state%% *}
table=${state##* }

if [ "$in_mode" = "1" ]; then
    colour="#ffa500"
else
    case "$table" in
        session-mode)     colour="#ff0000" ;;
        window-mode)      colour="#4169e1" ;;
        pane-mode)        colour="#00ff00" ;;
        pane-resize-mode) colour="#ff00ff" ;;
        *)                colour="#008b8b" ;;
    esac
fi

tmux set-option -t "$client" cursor-colour "$colour"
