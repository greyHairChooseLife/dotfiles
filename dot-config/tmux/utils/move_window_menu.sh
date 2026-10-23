#!/bin/zsh
# Build a display-menu listing all sessions (except the current one) and move
# the current window to the picked session. Invoked from the Window Menu.

current="$(tmux display-message -p '#{session_name}')"

# menu items: "  <name>  (<n> windows)" <index-key> "move-window -t <name>"
items=()
i=1
while IFS=$'\t' read -r name; do
  [ "$name" = "$current" ] && continue
  items+=("  $name  " "$i" "move-window -t \"$name:\"")
  i=$((i + 1))
done < <(tmux list-sessions -F '#{session_name}')

if [ ${#items[@]} -eq 0 ]; then
  tmux display-message "No other session to move to"
  exit 0
fi

tmux display-menu -S "fg=blue" -b "heavy" -H "bg=#4169e1,fg=black" \
  -x C -y C -T "#[align=centre fg=blue] Move window to… " \
  "                                        " Escape "" \
  "${items[@]}"
