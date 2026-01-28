#!/bin/zsh
CHEAT_LANGUAES=${HOME}/dotfiles/dot-config/zsh.sub/scripts/tmux/tmux-cht-languages
CHEAT_COMMAND=${HOME}/dotfiles/dot-config/zsh.sub/scripts/tmux/tmux-cht-command

selected=$(cat $CHEAT_LANGUAES $CHEAT_COMMAND | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if grep -qs "$selected" $CHEAT_LANGUAES; then
    query=$(echo $query | tr ' ' '+')
    tmux neww zsh -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
else
    # tmux neww zsh -c "curl -s cht.sh/$selected~$query | more"
    tmux neww zsh -c "curl -s cht.sh/$selected~$query; read -p 'Press Enter to close...'"
fi
