fzf_find_file() {
    local curr_dir=${PWD/$HOME/\~}
    fd --type file \
        | sort \
        | fzf --prompt 'Files (--depth=end) & '${curr_dir}'> ' \
            --header '<Alt+1~3>: depth lvl, <Enter>: editr' \
            --bind 'alt-1:change-prompt(Files (--depth=1) & '${curr_dir}'> )+reload(fd --type file --max-depth 1)' \
            --bind 'alt-2:change-prompt(Files (--depth=2) & '${curr_dir}'> )+reload(fd --type file --max-depth 2)' \
            --bind 'alt-3:change-prompt(Files (--depth=end) & '${curr_dir}'> )+reload(fd --type file)' \
            --bind 'enter:become(nvim {})' \
            --preview '[[ {} =~ ('.jpg'|'.JPG'|'.jpeg'|'.png'|'.PNG')$ ]] && catimg -r2 -w$COLUMNS {} || [[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}'
}

# include hidden files & gitignored
fzf_find_file_hidden() {
    local curr_dir=${PWD/$HOME/\~}
    fd --type file --hidden -I \
        | sort \
        | fzf --prompt '(+hidden) Files (--depth=end) & '${curr_dir}'> ' \
            --header '<Alt+1~3>: depth lvl, <Enter>: editr' \
            --bind 'alt-1:change-prompt((+hidden) Files (--depth=1) & '${curr_dir}'> )+reload(fd --type file --hidden -I --max-depth 1)' \
            --bind 'alt-2:change-prompt((+hidden) Files (--depth=2) & '${curr_dir}'> )+reload(fd --type file --hidden -I --max-depth 2)' \
            --bind 'alt-3:change-prompt((+hidden) Files (--depth=end) & '${curr_dir}'> )+reload(fd --type file --hidden -I)' \
            --bind 'enter:become(nvim {})' \
            --preview '[[ {} =~ ('.jpg'|'.JPG'|'.jpeg'|'.png'|'.PNG')$ ]] && catimg -r2 -w$COLUMNS {} || [[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}'
}

fzf_find_dir() {
    local curr_dir=${PWD/$HOME/\~}
    local dir
    dir=$(fd --type d --max-depth 1 \
        | sort \
        | fzf --prompt 'Dir (--depth=1) & '${curr_dir}'> ' \
            --header '<Alt+1~3>: depth lvl, <Enter>: CD' \
            --bind 'alt-1:change-prompt(Dir (--depth=1) & '${curr_dir}'> )+reload(fd --type d --max-depth 1)' \
            --bind 'alt-2:change-prompt(Dir (--depth=2) & '${curr_dir}'> )+reload(fd --type d --max-depth 2)' \
            --bind 'alt-3:change-prompt(Dir (--depth=end) & '${curr_dir}'> )+reload(fd --type d)' \
            --preview 'tree --gitignore -dC -L 3 {}')

    if [ -n "$dir" ]; then
        cd "$dir" && pwd && if [ $(fd --type d --max-depth 1 | wc -l) -gt 0 ]; then
            fzf_find_dir
        fi
    fi
}

fzf_find_dir_hidden() {
    local curr_dir=${PWD/$HOME/\~}
    local dir
    dir=$(fd --type d --hidden -I --max-depth 1 \
        | sort \
        | fzf --prompt '(+hidden) Dir (--depth=1) & '${curr_dir}'> ' \
            --header '<Alt+1~3>: depth lvl, <Enter>: CD' \
            --bind 'alt-1:change-prompt((+hidden) Dir (--depth=1) & '${curr_dir}'> )+reload(fd --type d --hidden -I --max-depth 1)' \
            --bind 'alt-2:change-prompt((+hidden) Dir (--depth=2) & '${curr_dir}'> )+reload(fd --type d --hidden -I --max-depth 2)' \
            --bind 'alt-3:change-prompt((+hidden) Dir (--depth=end) & '${curr_dir}'> )+reload(fd --type d --hidden -I)' \
            --preview 'tree --gitignore -dC -L 3 {}')

    if [ -n "$dir" ]; then
        cd "$dir" && pwd && if [ $(fd --type d --max-depth 1 --hidden -I | wc -l) -gt 0 ]; then
            fzf_find_dir
        fi
    fi
}

# Switch between Ripgrep mode and fzf filtering mode (CTRL-T)
smart_grep() {
    local curr_dir=${PWD/$HOME/\~}
    rm -f /tmp/rg-fzf-{r,f}
    local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"
    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --prompt 'ripgrep & '${curr_dir}'> ' \
        --header '<CTRL-T>: Toggle ripgrep / FZF' \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
        echo "rebind(change)+change-prompt(ripgrep & '${curr_dir}'> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
        echo "unbind(change)+change-prompt(FZF & '${curr_dir}'> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --delimiter : \
        --preview 'bat --theme=base16 --color=always {1} --highlight-line {2}' \
        --bind 'enter:become(nvim {1} +{2})'
}

smart_grep_hidden() {
    local curr_dir=${PWD/$HOME/\~}
    rm -f /tmp/rg-fzf-{r,f}
    local RG_PREFIX="rg --hidden --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"
    : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --prompt 'ripgrep & '${curr_dir}'> ' \
        --header '<CTRL-T>: Toggle ripgrep / FZF' \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
        echo "rebind(change)+change-prompt(ripgrep & '${curr_dir}'> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
        echo "unbind(change)+change-prompt(FZF & '${curr_dir}'> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --delimiter : \
        --preview 'bat --theme=base16 --color=always {1} --highlight-line {2}' \
        --bind 'enter:become(nvim {1} +{2})'
}

alias ff='fzf_find_file'
alias ff.='fzf_find_file_hidden'
alias ffd='fzf_find_dir'
alias ffd.='fzf_find_dir_hidden'
alias ffg='smart_grep'
alias ffg.='smart_grep_hidden'
