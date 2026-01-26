#
# ~/.zshrc
#

# Return if not interactive
[[ -o interactive ]] || return

colors() {
    local fgc bgc vals seq0

    printf "Color escapes are %s\n" '\e[${value};...;${value}m'
    printf "Values 30..37 are \e[33mforeground colors\e[m\n"
    printf "Values 40..47 are \e[43mbackground colors\e[m\n"
    printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

    # foreground colors
    for fgc in {30..37}; do
        # background colors
        for bgc in {40..47}; do
            fgc=${fgc#37} # white
            bgc=${bgc#40} # black

            vals="${fgc:+$fgc;}${bgc}"
            vals=${vals%%;}

            seq0="${vals:+\e[${vals}m}"
            printf "  %-9s" "${seq0:-(default)}"
            printf " ${seq0}TEXT\e[m"
            printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
        done
        echo
        echo
    done
}

# Zsh completion system
autoload -Uz compinit
compinit

# Change the window title of X terminals
case ${TERM} in
    xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
        precmd() {
            print -Pn "\e]0;%n@%m:%~\a"
        }
        ;;
    screen*)
        precmd() {
            print -Pn "\e_%n@%m:%~\e\\"
        }
        ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(<>/etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type dircolors > /dev/null 2>&1 \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color}; then
    # Enable colors for ls, etc.
    if type dircolors > /dev/null 2>&1; then
        if [[ -f ~/.dir_colors ]]; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]]; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    if [[ ${EUID} == 0 ]]; then
        PS1='%1~%# '
    else
        PS1='%1~%# '
    fi

    alias ls='ls --color=auto'
    alias ll='ls -la'
    alias c='clear'
    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
    alias fgrep='fgrep --colour=auto'
else
    if [[ ${EUID} == 0 ]]; then
        PS1='%1~%# '
    else
        PS1='%~%# '
    fi
fi

unset use_color safe_term match_lhs

# export PATH="/opt/flutter/bin:$PATH"
# export JAVA_HOME='/usr/lib/jvm/java-8-openjdk/jre'
# export PATH=$JAVA_HOME/bin:$PATH
# export ANDROID_SDK_ROOT='/opt/android-sdk'
# export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools/
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin/
# export PATH=$PATH:$ANDROID_ROOT/emulator
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools/

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
