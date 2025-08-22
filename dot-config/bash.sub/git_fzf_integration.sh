# MEMO:: checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
look_branch_or_tag() {
    local tags branches target
    local header="<Enter>: checkout to the Ref & detach, <C-e>: Ref cp & abort, <A-e>: Ref cp"

    branches=$(
        git --no-pager branch --all \
            --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
            | sed '/^$/d'
    ) || return

    tags=$(
        git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}'
    ) || return

    target=$(
        (   
            echo "$branches"
            echo "$tags"
        ) \
            | fzf \
                --no-hscroll --no-multi -n 2 --ansi \
                --header="$header" \
                --preview="git --no-pager log -150 --pretty=format:%s '..{2}'" \
                --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
                --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)'
    ) || return

    git checkout $(awk '{print $2}' <<< "$target")
}

alias git_log_no_graph='git log --color=always --format="%C(auto)%h%d %s    %C(brightblack dim italic)%cr% C(ul)%an%C(reset) " "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always %'"

# MEMO:: checkout git commit with previews
look_commit() {
    local commit

    local header="<Enter>: show commit with delta, <C-e>: Hash cp & abort, <A-e>: Hash cp"

    commit=$(
        git_log_no_graph \
            | fzf \
                --no-sort --tiebreak=index --no-multi --ansi \
                --header="$header" \
                --preview="$_viewGitLogLine" \
                --bind "ctrl-e:execute($_gitLogLineToHash | xclip -selection clipboard)+abort" \
                --bind "alt-e:execute($_gitLogLineToHash | xclip -selection clipboard)"
    )

    git log -p -1 $(echo "$commit" | sed "s/ .*//") | delta
}

look_graph_log() {
    local command_list=$(
        cat << EOF
total state    :  git log                 --all  --decorate --simplify-by-decoration
oneline        :  git log
oneline --all  :  git log --pretty=MY     --all
medium         :  git log --pretty=medium
medium  --all  :  git log --pretty=medium --all
medium  --stat :  git log --pretty=medium        --stat
fetched        :  git log --pretty=medium               HEAD..FETCH_HEAD
to push        :  git log --pretty=medium               origin/HEAD..
EOF
    )

    local header="<Enter>: run the command,  common option: '--oneline --graph --color=always'"
    local myPretty="--pretty=format:'%C(blue)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    local cmd=$(echo "$command_list" | fzf \
        --header="$header" \
        --preview="echo {} | sed 's/.*:  //' | sed 's/git log/git log --oneline --graph --color=always/' | sed \"s/MY/$myPretty/\" | bash")

    eval $(echo "$cmd" | sed "s/.*:  //" | sed "s/git log/git log --oneline --graph --color=always/" | sed "s/MY/$myPretty/")
}

_async_fetch_all() {
    echo
    echo '  fetching everything ...'
    echo
    git fetch --all \
                  && gg
}

gg() {
    local command_list=$(
        cat << EOF
_async_fetch_all
look_graph_log
look_commit
look_branch_or_tag
EOF
    )

    local prompt="$PWD "
    local header="take a look..."

    eval $(
           echo "$command_list" | fzf --reverse --padding 20% \
             --prompt="$prompt" \
             --header="$header"
    )
}

export -f gg
