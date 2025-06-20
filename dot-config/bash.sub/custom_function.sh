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
ex() {
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

# function pomo() {
#     arg1=$1
#     shift
#     args="$*"
#
#     min=${arg1:?Example: pomo 15 Take a break}
#     sec=$((min * 10))
#     msg="${args:?Example: pomo 15 Take a break}"
#
#     while true; do
#         sleep "${sec:?}" && echo "${msg:?}" && notify-send -u critical -t 0 "${msg:?}"
#     done
# }

function pomodorotimer() {
    arg1=$1
    shift
    args="$*"

    min=${arg1:?Example: pomo 15 Take a break}
    sec=$((min * 60))
    msg="${args:?Example: pomo 15 Take a break}"

    # 기본 작업 시간 타이머
    sleep "${sec:?}" && echo "${msg:?}" && notify-send -u normal -t 0 "${msg:?}" -h string:bgcolor:#3a0ff9

    # 40분 미만일 경우 종료 시 5분간 휴식
    if [ $sec -lt 2400 ]; then
        break_time=300
        (   
            while [ $break_time -gt 0 ]; do
                minutes=$((break_time / 60))
                seconds=$((break_time % 60))
                echo "# ${minutes}m ${seconds}s ..."
                sleep 1
                break_time=$((break_time - 1))
            done
        ) | zenity --progress --title="Break Time" --text="Starting break..." --percentage=0 --pulsate --auto-close --no-cancel --width=300 --height=100
    else
        # 40분 이상일 경우 40분마다 5분 휴식
        cycles=$((sec / 2400))
        for ((i = 1; i <= cycles; i++)); do
            sleep 2400
            msg="40 minutes passed! Take a 5-minute break."
            notify-send -u critical -t 0 "$msg"

            break_time=300
            (   
                while [ $break_time -gt 0 ]; do
                    minutes=$((break_time / 60))
                    seconds=$((break_time % 60))
                    echo "# ${minutes}m ${seconds}s ..."
                    sleep 1
                    break_time=$((break_time - 1))
                done
            ) | zenity --progress --title="Break Time" --text="Starting break..." --percentage=0 --pulsate --auto-close --no-cancel --width=300 --height=100
        done
    fi
}

mo() {
    pomodorotimer "$@" > /dev/null 2>&1 &
    disown
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

update_readme_with_english_study_note() {
    local source_dir="/home/sy/Documents/dev-wiki/notes/Area/나를_사랑하기/from_codecompanion_conversation"
    local readme_file="/home/sy/Documents/dev-wiki/README.md"

    # Check if src directory exist
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory '$source_dir' does not exist."
        return 1
    fi

    # Step 1: Get the last file's path by checking filename (assuming date format)
    local latest_file=$(find "$source_dir" -type f -name "*" | sort | tail -n 1)

    if [ -z "$latest_file" ]; then
        echo "No files found in $source_dir"
        return 1
    fi

    # Step 2: update readme with new study
    yes | cp -f "$latest_file" "$readme_file"

    if [ $? -ne 0 ]; then
        echo "Error copying file."
        return 1
    fi
}
