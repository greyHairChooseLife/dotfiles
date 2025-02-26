#!/bin/bash

echo ""

read -p "config symlink를
(u)업데이트, (d)제거, (c)취소: " answer

if [ $answer == 'c' ]; then
    echo "취소하였습니다."
    exit 1
  elif [ $answer == 'd' ]; then
    stow --target $HOME --dotfiles -D .
    echo "config symlink가 모두 제거되었습니다."
    exit 1
fi

if [ $answer != 'u' ]; then
    echo "잘못된 입력입니다."
    bash $0
fi

# .Xresources 파일이 있다면 먼저 삭제
[ -f "$HOME/.Xresources" ] && rm "$HOME/.Xresources"

# --dotfiles는 이름이 'dot-'으로 시작하는 것을 '.'으로 번역해준다. ed) `dot-config -> .config`
stow --target $HOME --dotfiles -R .

# 동일한 이름의 plain text 파일이 있다면 실패할 수 있다.
if [ $? -ne 0 ]; then exit 1; fi


read -p "생성을 완료하였습니다. 변경 내용을 반영하시겠습니까? (y/n): " answer
if [ $answer != 'y' ]; then
    echo "취소하였습니다."
    exit 1
fi

read -p "dunst를 reload하시겠습니까? (y/n): " answer
if [ $answer == 'y' ]; then dunstctl reload; fi

read -p ".Xresources를 reload하시겠습니까? (y/n): " answer
if [ $answer == 'y' ]; then xrdb -merge ~/.Xresources; fi

read -p ".xprofile을 reload하시겠습니까? (y/n): " answer
if [ $answer == 'y' ]; then source ~/.xprofile; fi
