fman() {
    # 모든 실행 가능한 명령어, 함수, alias 목록 가져오기 및 중복 제거
    local commands=$(compgen -c | sort | uniq)

    # 사용자 정의 함수 목록 가져오기
    local functions=$(declare -F | cut -d' ' -f3)

    # Alias 목록 가져오기
    local aliases=$(alias | cut -d'=' -f1 | sed "s/alias //g")

    # 함수와 alias 제거
    commands=$(echo "$commands" | grep -vxF -f <(echo "$functions") | grep -vxF -f <(echo "$aliases"))

    # fzf를 사용하여 명령어 선택 및 tldr, man 페이지 미리보기 및 열기
    local cmd=$(echo "$commands" | fzf -q "$1" -m --preview "tldr {}")
    if [ -z "$cmd" ]; then
        echo "No command selected."
        return
    fi
    tldr $cmd > /tmp/tldr_preview.txt
    if man $cmd &> /dev/null; then
        man $cmd > /tmp/man_preview.txt
    else
        echo "No man page found for $cmd" > /tmp/man_preview.txt
    fi
    nvim -c "tabnew /tmp/man_preview.txt" -c "normal gt" /tmp/tldr_preview.txt
}

# # ex - archive extractor
# # usage: ex <file>
ext() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}


# webm >> gif 만들기
webm2gif() {
    ffmpeg -y -i "$1" -vf palettegen _tmp_palette.png
    ffmpeg -y -i "$1" -i _tmp_palette.png -filter_complex paletteuse -r 10 -loop 0 "${1%.webm}.gif"
    rm -f _tmp_palette.png
}

clear_only_screen() {
    printf "\e[H\e[2J"
}

clear_screen_and_scrollback() {
    printf "\e[H\e[3J"
}

y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

review() {
    local url="$1"
    local commit_hash repo_url repo_name tmp_dir

    # Usage message
    local usage="Usage: review https://github.com/{owner}/{repo}/commit/{commit_hash}"

    # Check for argument and basic URL pattern
    if [[ -z "$url" || ! "$url" =~ ^https://github.com/[^/]+/[^/]+/commit/[0-9a-fA-F]+$ ]]; then
        echo "$usage"
        return 1
    fi

    # Extract commit hash and repo info
    commit_hash="${url##*/}"
    repo_url="$(echo "$url" | sed -E 's|https://github.com/([^/]+/[^/]+)/commit/.*|\1|')"
    repo_name="${repo_url##*/}"
    tmp_dir="/tmp/${repo_name}-${commit_hash:0:7}"

    # Clone into /tmp path
    git clone "https://github.com/$repo_url.git" "$tmp_dir"

    # Open Neovim in that dir and run Diffview
    (
        cd "$tmp_dir" || exit
        git checkout $commit_hash
        nvim -c "DiffviewOpen $commit_hash^..$commit_hash"
    )
}

