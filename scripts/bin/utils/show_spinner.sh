#!/bin/bash

set -euo pipefail

pid=$1
delay=0.1
spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
i=0
n=${#spinstr}
msg="uploading..."

tput civis  # 커서 숨기기

while kill -0 $pid 2>/dev/null; do
    c=${spinstr:i++%n:1}
    printf " %s  %s\r" "$msg" "$c"
    sleep $delay
done

# 메시지 전체 길이만큼 공백으로 덮어쓰기
clear_line=$(printf "%*s\r" $(( ${#msg} + 10 )) "")
printf "%s" "$clear_line"
printf "\n"

tput cnorm  # 커서 다시 보이기
