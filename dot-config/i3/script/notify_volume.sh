#!/bin/bash

# 고정 notification ID 설정 (볼륨 조절용)
VOLUME_NOTIFY_ID=2594

# 메시지 설정 (인수가 없으면 기본값 "BRIGHTNESS" 사용)
message=${1:-"CURRENT"}

# 현재 볼륨 상태 가져오기
volume="\r$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1)"
is_mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$is_mute" == "yes" ]; then
    volume=""
    message="MUTE ON"
elif [ "$message" == "MUTE TOGGLE" ]; then
    message="MUTE OFF"
fi


# 알림 전송 (같은 ID로 업데이트)
notify-send --icon=" " \
           --replace-id=$VOLUME_NOTIFY_ID \
           --expire-time=1000 \
           --transient \
           --app-name "pactl(음량)" \
           "$message" \
           "$volume"
