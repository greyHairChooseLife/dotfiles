#!/bin/bash

# 기본 실행 스크립트 작성하면 되겠다.

btkb() {
  if [ "$HOSTNAME" != "Lenovo-ideapad" ]; then
    exit 0
  fi

  DEVICE_NAME="AT Translated Set 2 keyboard"  # 내장 키보드 이름

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

btkb off
