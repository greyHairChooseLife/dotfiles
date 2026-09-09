# >>> git
alias g='git'
alias ga='git add'
alias gco='git commit'
alias gch='git checkout'
alias gch!='git checkout $(git branch | fzf)'
alias gp='git push'
alias gme='git merge'
alias gre='git reset'
alias gt='git tag'
alias gcl='git clean -i .'
# alias gf='git fetch --all &'
alias gfd='git fetch --dry-run'

alias gb='git branch'
alias gba='git branch --all'
alias gsc='git switch'
alias gs='git status'
alias gl='git log'
# alias gd='git --no-pager diff | delta --diff-so-fancy'
# function gd() { git --no-pager diff "$@" | delta --diff-so-fancy }
gd() {
    local original_path repo_root abs
    original_path=$(pwd)

    repo_root=$(git-root) || return 1
    [ -n "$repo_root" ] || return 1

    abs=""
    if [ -n "$1" ]; then
        abs=$(realpath -e -- "$1") || return 1
        case "$abs" in
            "$repo_root"|"$repo_root"/*) ;;
            *) echo "error: '$1' is not inside $repo_root" >&2; return 1 ;;
        esac
    fi

    local -a ps=()
    [ -n "$abs" ] && ps=(-- "$abs")

    local psq=""
    [ -n "$abs" ] && psq="-- $(printf '%q' "$abs")"

    cd "$repo_root" || return 1

    local modefile
    modefile=$(mktemp) || return 1
    echo unstaged > "$modefile"

    if [ -z "$(git diff --name-only "${ps[@]}")" ] &&
    [ -z "$(git diff --cached --name-only "${ps[@]}")" ] &&
    [ -z "$(git ls-files --others --exclude-standard "${ps[@]}")" ]; then
        echo "No changes."
        rm -f "$modefile"
        cd "$original_path"
        return 0
    fi

    local header='<Enter>: Fugitive | <Ctrl-f>: peek | <A-1/2/3/4>: unstaged|staged|untracked|all'
    [ -n "$abs" ] && header="scope: ${abs#$repo_root/} | $header"

    local files
    files=$(
        git diff --name-only "${ps[@]}" \
            | fzf -m \
            --bind "alt-1:execute-silent(echo unstaged  > $modefile)+reload(git diff --name-only $psq)+change-prompt(1-unstaged> )" \
            --bind "alt-2:execute-silent(echo staged    > $modefile)+reload(git diff --cached --name-only $psq)+change-prompt(2-staged> )" \
            --bind "alt-3:execute-silent(echo untracked > $modefile)+reload(git ls-files --others --exclude-standard $psq)+change-prompt(3-untracked> )" \
            --bind "alt-4:execute-silent(echo all       > $modefile)+reload({ git diff HEAD --name-only $psq; git ls-files --others --exclude-standard $psq; })+change-prompt(4-all> )" \
            --bind "ctrl-f:execute(nvim -O {+})" \
            --bind "enter:execute(nvim -c 'G' -c 'only')" \
            --bind "ctrl-c:abort" \
            --prompt 'unstaged> ' \
            --preview 'm=$(cat '"$modefile"'); f={}; case $m in
                unstaged)  git diff --color=always -- "$f" | bat -p --color=always -l diff ;;
                staged)    git diff --cached --color=always -- "$f" | bat -p --color=always -l diff ;;
                untracked) bat -p --color=always "$f" ;;
                all)       git diff HEAD --color=always -- "$f" 2>/dev/null | bat -p --color=always -l diff || bat -p --color=always "$f" ;;
            esac' \
            --header "$header"
    )

    rm -f "$modefile"
    # [[ -n "$files" ]] && nvim -O "${(@f)files}"
    cd "$original_path"
}

alias gdv='vi -c "lua require(\"snacks\").picker.git_diff({ layout = { fullscreen = true } })"'

alias gst='git stash'
alias gls='git log --oneline --simplify-by-decoration --all'
alias glo='git log --oneline'
alias gloa='git log --oneline --all'
alias glao='gloa'
alias glg='git log --oneline --graph --pretty=medium --stat'
alias glgo='git log --oneline --graph'
alias glga='git log --graph --all --pretty=medium'
alias glgao='git log --oneline --graph --all'
alias glgoa='glgao'

git-root() {
    git rev-parse --show-toplevel 2> /dev/null || {
        echo "Error: Not inside a git repository." >&2
        return 1
    }
}
# <<<

gf_origin() {
    # 1. 모든 리모트의 브랜치 목록을 가져옵니다 (서버 직접 조회)
    # 형식: remote/branch-name
    target=$(
        for remote in $(git remote); do
            git ls-remote --heads --quiet "$remote" \
                | awk -v r="$remote" '{sub("refs/heads/", "", $2); print r "/" $2}'
        done | fzf --prompt="Fetch Remote Branch> " --preview "echo {} | sed 's#/# #' | xargs git ls-remote"
    )

    if [[ -z "$target" ]]; then
        return 0
    fi

    # 2. 선택된 문자열(remote/branch)을 분리합니다.
    # ${target%%/*} : 첫 번째 / 앞부분 (remote)
    # ${target#*/}  : 첫 번째 / 뒷부분 (branch, 슬래시 포함 가능)
    remote="${target%%/*}"
    branch="${target#*/}"

    # 3. 명령어 생성 및 실행
    # 로컬의 refs/remotes/remote/branch 에 강제로 업데이트합니다.
    cmd="git fetch ${remote} ${branch}:refs/remotes/${remote}/${branch}"

    echo "Running: $cmd"
    eval "$cmd"
}

# Unalias if exists (oh-my-zsh conflict)
unalias gf 2> /dev/null

gf() {
    # git 저장소인지 확인
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository."
        return 1
    fi

    # fzf -m 옵션 추가
    targets=$(
        for remote in $(git remote); do
            git ls-remote --heads --quiet "$remote" \
                | awk -v r="$remote" '{sub("refs/heads/", "", $2); print r "/" $2}'
        done | fzf -m --prompt="Select Branches (Tab to multi-select)> "
    )

    if [[ -z "$targets" ]]; then
        return 0
    fi

    # 선택된 줄들을 반복하며 실행
    echo "$targets" | while read -r line; do
        remote="${line%%/*}"
        branch="${line#*/}"

        echo "Fetching $remote/$branch..."
        git fetch "$remote" "${branch}:refs/remotes/${remote}/${branch}"
    done
}

wts() {
    # local prev=$(pwd)
    local first="$1"
    if [[ -z "$first" ]]; then
        wt switch
    elif [[ "$first" == "-"  ]]; then
        wt switch -
    else
        wt switch --create "$@"
    fi
    # cd "$prev" # back to original worktree
}
