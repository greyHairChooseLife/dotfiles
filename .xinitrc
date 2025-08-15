# MEMO::
# X 화면 보호기를 비활성화하고 디스플레이 전원 관리를 끕니다
# s off: 화면 보호기 비활성화
# -dpms: DPMS (Display Power Management Signaling) 비활성화
xset s off -dpms &

# MEMO:: swap ctrl:capslock
btkb off &

feh --bg-scale ~/bg.png &

exec i3
