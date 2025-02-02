#!/bin/bash

# 고정 notification ID 설정 (밝기 조절용)
BRIGHTNESS_NOTIFY_ID=2593

# 메시지 설정 (인수가 없으면 기본값 "BRIGHTNESS" 사용)
message=${1:-"CURRENT"}

# 최대 밝기 가져오기
max_brightness=$(brightnessctl m)

# 현재 밝기 가져오기
current_brightness=$(brightnessctl g)

# 밝기 퍼센트 계산
brightness_percent=$(( current_brightness * 100 / max_brightness ))

# 알림 전송 (같은 ID로 업데이트)
notify-send --icon=" " \
           --replace-id=$BRIGHTNESS_NOTIFY_ID \
           --expire-time=1000 \
           --transient \
           --app-name "brightnessctl" \
           "$message" \
           "\r$current_brightness/$max_brightness ($brightness_percent%)"
