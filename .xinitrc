# MEMO::
# X 화면 보호기를 비활성화하고 디스플레이 전원 관리를 끕니다
# s off: 화면 보호기 비활성화
# -dpms: DPMS (Display Power Management Signaling) 비활성화
xset s off -dpms &
xset -b &

btkb off &

feh --bg-max /home/sy/Pictures/bg/awk_cheat_sheet.jpg &

# 시스템d user 환경에 DISPLAY 전달 (xdg-desktop-portal-gtk 파일 다이얼로그가 필요)
systemctl --user set-environment DISPLAY=:0 XAUTHORITY="$HOME/.Xauthority" XDG_SESSION_TYPE=x11

exec i3
