#!/bin/bash

# Set up the virtual environment home directory
export VENV_HOME="$HOME/.local/state/python_venv"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

venv_manager() {
    # Function to list available virtual environments
    list_venv() {
        ls -1 $VENV_HOME
    }

    # Function to activate a selected virtual environment
    activate_venv() {
        local selected=$(list_venv \
                     | fzf --header="Select a virtual environment to activate" \
                           --preview="source $VENV_HOME/{}\/bin/activate && python --version && pip list")

        if [[ -z $selected ]]; then
            return 0
        fi

        # Directly source the activate script
        source "$VENV_HOME/$selected/bin/activate"
    }

    # Function to create a new virtual environment
    make_venv() {
        echo "Currently there are..."
        list_venv
        echo

        read -p "New Venv Name: " name
        python3 -m venv $VENV_HOME/$name
        echo "# Virtual environment created: $name"
    }

    # Function to remove a virtual environment
    rm_venv() {
        local name=$(list_venv \
                 | fzf --header="Select a virtual environment to remove" \
                       --preview="du -sh $VENV_HOME/{}; echo; echo; stat $VENV_HOME/{}")

        if [[ -z $name ]]; then
            return 0
        fi

        rm -r $VENV_HOME/$name
        echo "# Virtual environment removed: $name"
    }

    # Show menu to select action
    local selected_command=$(printf "activate_venv\\nmake_venv\\nrm_venv" | fzf --header="Choose an action")

    if [[ -z $selected_command ]]; then
        return 0
    fi

    # Execute the selected command
    $selected_command
}

# If script is sourced, just define the function
# If script is executed directly, run the function
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced
    # Just export the function
    export -f venv_manager
else
    # Script is being executed directly
    # Run the function
    venv_manager
fi
