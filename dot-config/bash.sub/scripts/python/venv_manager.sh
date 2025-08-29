#!/bin/bash

export VENV_HOME="$HOME/.local/state/python_venv"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

activate_venv() {
    selected=$(ls -1 $VENV_HOME | fzf)

    if [[ -z $selected ]]; then
        exit 0
    fi

    # Instead of sourcing directly, print the command to be executed by the parent shell
    # source "$VENV_HOME/$selected/bin/activate"
    echo "source \"$VENV_HOME/$selected/bin/activate\""
}

make_venv() {
    echo "Curently there are..."
    ls -1 $VENV_HOME
    echo

    read -p "New Venv Name: " name
    python3 -m venv $VENV_HOME/$name
    echo "# Virtual environment created: $name"
}

rm_venv() {
    echo "Curently there are..."
    ls -1 $VENV_HOME
    echo

    read -p "Remove Venv Name: " name
    trash --interactive --recursive $VENV_HOME/$name
    echo "# Virtual environment removed: $name"
}

selected_command=$(printf "activate_venv\n make_venv\n rm_venv" | tr -d " " | fzf)

if [[ -z $selected_command ]]; then
    exit 0
fi

eval $selected_command
