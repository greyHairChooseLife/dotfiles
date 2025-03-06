# conda initialization before activate virtual environment
_conda_initialize() {
    __conda_setup="$('/opt/miniforge/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        echo "conda initialized A"
        eval "$__conda_setup"
    else
        if [ -f "/opt/miniforge/etc/profile.d/conda.sh" ]; then
        echo "conda initialized B"
            . "/opt/miniforge/etc/profile.d/conda.sh"
        else
          echo "conda initialized C"
            export PATH="$PATH:/opt/miniforge/bin"
        fi
    fi
    unset __conda_setup

    if [ -f "/opt/miniforge/etc/profile.d/mamba.sh" ]; then
        . "/opt/miniforge/etc/profile.d/mamba.sh"
    fi
}

alias conda_activate='_conda_initialize && conda activate'
