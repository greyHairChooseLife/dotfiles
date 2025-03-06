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

btkb() {
  if [ "$HOSTNAME" != "Lenovo-ideapad" ]; then
    exit 0
  fi

  DEVICE_NAME="AT Translated Set 2 keyboard" # 내장 키보드 이름

  if [ "$1" == "on" ]; then
    echo "Bluetooth 키보드를 사용합니다."
    xinput disable "$DEVICE_NAME"
    setxkbmap -option
    echo "  - 내장 키보드       : 비활성화"
    echo "  - ctrl/capsLck swap : 비활성화"

  elif [ "$1" == "off" ]; then
    echo "내장 키보드를 사용합니다."
    xinput enable "$DEVICE_NAME"

    # 내장 키보드가 활성화될 때까지 최대 10번 시도 (총 5초)
    for i in {1..10}; do
      DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")
      if [ -n "$DEVICE_ID" ]; then
        break
      fi
      sleep 0.5
    done

    if [ -z "$DEVICE_ID" ]; then
      echo "내장 키보드 ID를 찾을 수 없습니다. [btkb off]를 다시 실행하세요."
      return 1
    fi

    setxkbmap -device "$DEVICE_ID" -option ctrl:swapcaps
    echo "  - 내장 키보드       : 활성화"
    echo "  - ctrl/capsLck swap : 활성화"
  else
    echo "사용법: btkb {on|off}"
    return 1 # 오류 반환
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
