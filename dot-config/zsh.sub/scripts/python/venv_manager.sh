#!/bin/zsh

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
        # echo "# Virtual environment created: $name"
        venv_manager
    }

    make_venv-with_flag_site_pkg() {
        echo "Currently there are..."
        list_venv
        echo

        read -p "New Venv Name (--system-site-packages): " name
        python3 -m venv --system-site-packages $VENV_HOME/${name}--system-site-packages
        # echo "# Virtual environment created: $name"
        venv_manager
    }

    # Function to remove a virtual environment
    rm_venv() {
        local name=$(list_venv \
                 | fzf --header="Select a virtual environment to remove" \
                       --preview="du -sh $VENV_HOME/{}; echo; echo; stat $VENV_HOME/{}")

        if [[ -z $name ]]; then
            return 0
        fi

        rm -r --interactive $VENV_HOME/$name
        echo "# Virtual environment removed: $name"
        venv_manager
    }

    # List conda environments (by name)
    list_conda_envs() {
        conda env list | awk '/^\w/ {print $1}'
    }

    # Activate a conda environment
    activate_conda_env() {
        init_miniconda
        local selected=$(list_conda_envs \
            | fzf --header="Select a conda environment to activate" \
                  --preview="conda list -n {}")
        if [[ -z $selected ]]; then
            return 0
        fi
        conda activate "$selected"
    }

    # Create a new conda environment
    make_conda_env() {
        init_miniconda
        read -p "New Conda Env Name: " name
        read -p "Python version (e.g. 3.10, leave blank for default): " pyver
        if [[ -z $pyver ]]; then
            conda create -y -n "$name"
        else
            conda create -y -n "$name" python="$pyver"
        fi
        echo "# Conda environment created: $name"

        read -p "Will you activate? (y/n) " will_activate
        if [ "$will_activate" = "y" ] || [ "$will_activate" = " " ]; then
            activate_conda_env "$name"
        else
            venv_manager
        fi
    }

    # Remove a conda environment
    rm_conda_env() {
        init_miniconda
        local name=$(list_conda_envs \
            | fzf --header="Select a conda environment to remove" \
                  --preview="conda list -n {}")
        if [[ -z $name ]]; then
            return 0
        fi
        conda remove -y -n "$name" --all
        echo "# Conda environment removed: $name"
        venv_manager
    }

    # Source miniconda
    init_miniconda() {
        [ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
    }

    # Main menu
    commands="\n
activate_venv\n
make_venv\n
make_venv-with_flag_site_pkg\n
rm_venv\n
\n
activate_conda_env\n
make_conda_env\n
rm_conda_env"
    local selected_command=$(echo -e $commands | fzf \
        --header '<ctrl+t>: source conda ' \
        --bind 'ctrl-t:become(source /opt/miniconda3/etc/profile.d/conda.sh; venv_manager)' \
        --preview="echo -e '=== current venv list ===\n'; ls -o --time-style=long-iso -1 $VENV_HOME | \
        grep -v '^total' | \
        awk 'BEGIN { printf \"%-4s %-70s %-12s %-10s\\n\", \"No.\", \"Name\", \"Date\", \"Time\" } \
                   { printf \"%-4s %-70s %-12s %-10s\\n\", NR \".\", \$7, \$5, \$6 }'; \
        echo -e '\n\n===== conda env list ====='; conda env list 2>/dev/null | grep -v '^#'")

    if [[ -z $selected_command ]]; then
        return 0
    fi

    # Execute the selected command
    $selected_command
}

# DEPRECATED:: 2026-01-28
# This is for Bash
# # If script is sourced, just define the function
# # If script is executed directly, run the function
# if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
#     # Script is being sourced
#     # Just export the function
#     export -f venv_manager
# else
#     # Script is being executed directly
#     # Run the function
#     venv_manager
# fi

# Zsh 전용 실행/Source 감지 로직
# ZSH_EVAL_CONTEXT가 'toplevel'이면 스크립트가 직접 실행된 것
if [[ $ZSH_EVAL_CONTEXT == 'toplevel' ]]; then
    # 직접 실행된 경우 함수 실행
    # (주의: 직접 실행 시 activate는 하위 셸에서만 적용되고 종료됩니다. 현재 셸 적용은 source 필요)
    venv_manager
fi
# Source된 경우: 함수(venv_manager)가 현재 셸에 자동으로 정의되므로 별도 export 불필요
