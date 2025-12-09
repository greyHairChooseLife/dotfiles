source /usr/share/bash-completion/completions/git

__git_complete ga _git_add
__git_complete gco _git_commit
__git_complete gch _git_checkout
__git_complete gp _git_push
__git_complete gt _git_tag
__git_complete gfd _git_fetch
__git_complete gb _git_branch
__git_complete gba _git_branch
__git_complete gs _git_status
__git_complete gst _git_stash
__git_complete gf _git_fetch
__git_complete gd _git_diff
__git_complete gl _git_log
__git_complete glgo _git_log
__git_complete gls _git_log
__git_complete glo _git_log
__git_complete gloa _git_log
__git_complete glao _git_log
__git_complete glg _git_log
__git_complete glgo _git_log
__git_complete glga _git_log
__git_complete glgao _git_log
__git_complete glgoa _git_log

# >>> git
alias ga='git add'
alias gco='git commit'
alias gch='git checkout'
alias gch!='git checkout $(git branch | fzf)'
alias gp='git push'
alias gt='git tag'
# alias gf='git fetch --all &'
alias gfd='git fetch --dry-run'

alias gb='git branch'
alias gba='git branch --all'
alias gs='git status'
alias gl='git log'
# alias gd='git --no-pager diff | delta --diff-so-fancy'
function gd() {
    git --no-pager diff "$@" | delta --diff-so-fancy
}
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
alias glgF='glg HEAD..' # check fetched
alias glgP='glg origin/HEAD..' # check to be pushed
alias glMM='git log --pretty=format:"COMMIT : %h%nTITLE  : %s%nMESSAGE: %b%n%cd==================================== %ae%n%n" --date=short'

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
    cmd="git fetch $remote $branch:refs/remotes/$remote/$branch"

    echo "Running: $cmd"
    eval "$cmd"
}

gf() {
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
        git fetch "$remote" "$branch:refs/remotes/$remote/$branch"
    done
}

# DEPRECATED:: 2025-12-09
# function gf() {
#     fetch_cmd=$(git fetch --dry-run --all 2>&1 \
#                 | tac \
#                 | fzf \
#                 | awk '/new branch/ {split($NF,a,"/"); remote=a[1]; branch=a[2]; print "git fetch " remote " " branch ":refs/remotes/" remote "/" branch}')
#
#     if [[ -z $fetch_cmd ]]; then
#         exit 0
#     fi
#
#     eval $fetch_cmd
# }
