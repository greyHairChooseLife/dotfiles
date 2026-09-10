# MEMO::
# X 화면 보호기를 비활성화하고 디스플레이 전원 관리를 끕니다
# s off: 화면 보호기 비활성화
# -dpms: DPMS (Display Power Management Signaling) 비활성화
xset s off -dpms &
xset -b &

# MEMO:: swap ctrl:capslock
btkb() {
    case "$HOSTNAME" in
        "sy-Lenovo-ideapad" | "cbpm-labtop" | "sy-x390") ;;
        *) return 1
    esac

    local DEVICE_NAME="AT Translated Set 2 keyboard" # 내장 키보드 이름

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
        return 1
    fi

    for i in {1..10}; do
        setxkbmap -device "$DEVICE_ID" -option ctrl:swapcaps
        sleep 0.01
    done
}
btkb off &

feh --bg-max /home/sy/Pictures/bg/awk_cheat_sheet.jpg &

# 시스템d user 환경에 DISPLAY 전달 (xdg-desktop-portal-gtk 파일 다이얼로그가 필요)
systemctl --user set-environment DISPLAY=:0 XAUTHORITY="$HOME/.Xauthority" XDG_SESSION_TYPE=x11

exec i3
