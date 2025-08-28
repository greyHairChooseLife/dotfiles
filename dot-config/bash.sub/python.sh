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

alias py='python'
# alias src='source .venv/bin/activate'
# alias conda='mamba'
# alias rconda='/opt/miniforge/bin/conda'  # 실제 conda 실행 가능하도록 백업

# initialize miniconda
# insalled miniconda with AUR, 2025-08-27
# Version                       : 25.5.1.1-2
# Description                   : Mini version of Anaconda Python distribution
# URL                           : https://conda.io/en/latest/miniconda
# Provides                      : conda
# AUR URL                       : https://aur.archlinux.org/packages/miniconda3
init_miniconda() {
    [ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
}
