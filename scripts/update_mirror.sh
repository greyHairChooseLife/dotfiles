#!/bin/bash
set -e

echo "Reflector 설치 중..."
sudo pacman -S --needed reflector rsync

echo "빠른 미러 서버로 업데이트 중..."
sudo reflector \
    --country 'KR' \
    --latest 10 \
    --sort rate \
    --save /etc/pacman.d/mirrorlist

echo "pacman 데이터베이스 새로고침..."
sudo pacman -Syyu

echo "미러 서버 업데이트 완료!"
