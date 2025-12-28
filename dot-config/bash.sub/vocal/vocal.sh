#!/bin/bash

# 1. 절대 경로 설정 (스크립트 위치 기준)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_DIR="$SCRIPT_DIR/python"
AUDIO_FILE="/tmp/vocal_recording.wav"
NOTIFY_ID_FILE="/tmp/vocal_notify_id"

# --- 설정 ---
MODE="api" # "local" 또는 "api"로 설정

# API 설정 (MODE="api"일 때)
API_KEY=$OPENAI_API_KEY
MODEL_API="whisper-1"

# 로컬 설정 (MODE="local"일 때)
MODEL_LOCAL="base"
MODEL_PATH="$HOME/whisper"

# --- 취소 ---
if [ "$1" = "cancel" ]; then
    if pgrep -x "rec" > /dev/null; then
        pkill -x "rec"
        if [ -f "$NOTIFY_ID_FILE" ]; then
            LAST_ID=$(cat "$NOTIFY_ID_FILE")
            notify-send -r "$LAST_ID" -h string:bgcolor:#f1502f -h string:fgcolor:#333342 -t 1500 "Vocal" "Recording cancelled"
        fi
        rm -f "$AUDIO_FILE" "$NOTIFY_ID_FILE"
    fi
    exit 0
fi

# --- 녹음 중단(완료) ---
if pgrep -x "rec" > /dev/null; then
    # 1. 녹음 중단
    pkill -x "rec"

    # rec 프로세스가 완전히 종료될 때까지 대기 (파일 저장 보장)
    while pgrep -x "rec" > /dev/null; do sleep 0.1; done

    # 이전 알림 ID 가져오기
    if [ -f "$NOTIFY_ID_FILE" ]; then
        LAST_ID=$(cat "$NOTIFY_ID_FILE")
        # 기존 알림을 갱신하여 "변환 중" 메시지 표시 (노란색 느낌을 위해 critical 사용 가능, 혹은 일반)
        notify-send -r "$LAST_ID" -h string:bgcolor:#50cd5a -h string:fgcolor:#333342 "Vocal" "Transcribing..."
    else
        notify-send "Vocal" "Transcribing..."
    fi

    # 2. 전사 수행
    if [ "$MODE" = "api" ]; then
        RESULT=$(python3 "$PYTHON_DIR/openai_uploader.py" "$API_KEY" "$AUDIO_FILE" "$MODEL_API" "text" "0" "60")
    else
        RESULT=$(python3 "$PYTHON_DIR/transcribe.py" "$AUDIO_FILE" "$MODEL_LOCAL" "$MODEL_PATH")
    fi

    # 3. 결과 입력 (xdotool 사용)
    if [ -n "$RESULT" ]; then
        # 한글 입력 오류 방지를 위해 클립보드 복사 -> 붙여넣기 방식으로 변경
        echo -n "$RESULT" | xclip -selection clipboard

        # 클립보드 반영을 위해 아주 짧은 대기 후 붙여넣기 실행
        sleep 0.2
        xdotool key --clearmodifiers ctrl+shift+v

        # 완료 알림 (기존 알림 덮어쓰기)
        if [ -n "$LAST_ID" ]; then
            notify-send -r "$LAST_ID" -t 2000 "Vocal" "Transcription complete"
        else
            notify-send "Vocal" "Transcription complete"
        fi
    else
        if [ -n "$LAST_ID" ]; then
            notify-send -r "$LAST_ID" -h string:bgcolor:#ffcc00 -h string:fgcolor:#004F4F "Vocal" "Error: Transcription failed"
        else
            notify-send "Vocal" "Error: Transcription failed"
        fi
    fi

    rm -f "$AUDIO_FILE"
    rm -f "$NOTIFY_ID_FILE"
else
    # 녹음 시작
    # -t 0: 알림이 사라지지 않음
    # -u critical: 긴급 수준 (보통 강조된 색상/노란색 or 빨간색)
    # -p: 알림 ID 출력 -> 파일에 저장
    NOTIFY_ID=$(notify-send -p -t 0 -h string:bgcolor:#ffcc00 -h string:fgcolor:#004F4F "Vocal" "Recording started... (Listening)")
    echo "$NOTIFY_ID" > "$NOTIFY_ID_FILE"

    rec -q -c 1 -r 16000 "$AUDIO_FILE" &
fi
