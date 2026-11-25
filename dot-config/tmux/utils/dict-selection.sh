#!/usr/bin/env bash
# dict-selection.sh - look up the tmux copy-mode selection in the Naver dictionary.
#
# Bind in tmux (selection arrives on stdin, pane id as argument):
#   bind -T copy-mode-vi C-o send-keys -X copy-pipe-and-cancel "bash \
#     $TMUX_CONFIG_DIR/utils/dict-selection.sh #{pane_id}"
#
# Reuses dict-popup, so the popup keeps its prompt: another word, or Ctrl-c to quit.
set -uo pipefail

pid=${1:-}
dict_popup="$HOME/.local/bin/dict-popup"

sel=$(cat)
# Flatten the selection to one line and trim the surrounding whitespace.
word=$(printf '%s' "${sel//$'\n'/ }")
word=${word#"${word%%[![:space:]]*}"}
word=${word%"${word##*[![:space:]]}"}
[[ -z $word ]] && exit 0

target=()
[[ -n $pid ]] && target=(-t "$pid")

# dict-popup reads its prompt from the terminal, not from the selection pipe.
tmux display-popup "${target[@]}" -E -w 40% -h 40% \
    "$(printf '%q' "$dict_popup") $(printf '%q' "$word") </dev/tty"
