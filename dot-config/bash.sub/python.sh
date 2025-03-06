# conda initialization before activate virtual environment
_conda_initialize() {
    __conda_setup="$('/opt/miniforge/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/miniforge/etc/profile.d/conda.sh" ]; then
            . "/opt/miniforge/etc/profile.d/conda.sh"
        else
            export PATH="$PATH:/opt/miniforge/bin"
        fi
    fi
    unset __conda_setup

    if [ -f "/opt/miniforge/etc/profile.d/mamba.sh" ]; then
        . "/opt/miniforge/etc/profile.d/mamba.sh"
    fi
}

alias conda_activate='_conda_initialize && conda activate'
