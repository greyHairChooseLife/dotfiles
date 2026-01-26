# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Return if not interactive
[[ -o interactive ]] || return

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# fzf-tab configuration (must be before plugins load)
# Use Tab to accept selection
zstyle ':fzf-tab:*' fzf-flags '--bind=tab:accept'
zstyle ':fzf-tab:*' continuous-trigger '/'

# Plugins
plugins=(
  git
  fzf-tab
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# dircolors
if type dircolors > /dev/null 2>&1; then
    if [[ -f ~/.dir_colors ]]; then
        eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval $(dircolors -b /etc/DIR_COLORS)
    fi
fi

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias c='clear'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

xhost +local:root > /dev/null 2>&1

# Zsh options
setopt INTERACTIVE_COMMENTS
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Editor
export EDITOR=/usr/bin/nvim
export editor=/usr/bin/nvim
export SUDO_EDITOR=/usr/bin/nvim
export SYSTEMD_EDITOR=/usr/bin/nvim

# Source additional config files
if [[ -d ~/.config/zsh.sub ]]; then
    for file in ~/.config/zsh.sub/*.sh; do
        [[ -r "$file" ]] && source "$file"
    done
fi

if [[ -d ~/.local/state/zsh.sub ]]; then
    for file in ~/.local/state/zsh.sub/*.sh; do
        [[ -r "$file" ]] && source "$file"
    done
fi

export PATH=$HOME/.local/bin:$PATH

# fzf integration
eval "$(fzf --zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
