# WARN:
# ..
# 1. 비밀번호 등 중요한 정보는 사용하지 않기(remote repository에 업로드 가능)

export NAS_SERVER="/mnt/cb-nas" # 충북프로메이커센터, 미래창업연구소

export HISTFILE=~/.bash_history    # 히스토리 명령어가 저장되는 파일 경로
export HISTSIZE=500                # 현재 세션 동안 메모리에 유지되는 명령어 최대 개수
export HISTFILESIZE=200000         # 히스토리 파일에 저장될 명령어 최대 개수
export HISTCONTROL=ignoreboth      # 중복 명령어 및 공백으로 시작한 명령어는 저장하지 않음
export HISTIGNORE="ls:cd:exit:pwd" # 지정된 명령어들은 히스토리에 기록되지 않음
shopt -s histappend                # 히스토리를 덮어쓰지 않고 파일 끝에 추가
export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
# history -a: 현재 세션의 명령어를 즉시 히스토리 파일에 추가
# history -n: 히스토리 파일에서 새로운 명령어를 읽어와 메모리에 병합

# about tmux
export TMUX_CONFIG_DIR="$HOME/.config/tmux"
export TMUX_PLUGIN_DIR="$HOME/.local/bin/tmux/plugins"
export TMUX_RESURRECT_DIR="$HOME/.local/state/tmux-resurrects/"

export MANPAGER='nvim +Man!'
export MANWIDTH=999

export LANG=en_US.UTF-8 # 이게 ssh servet-clinet간에 다르면 한글 랜더링 오류가 난다.

export PATH=$PATH:/opt/miniforge/bin  # miniforge 설치를 AUR에서 했다.

# for global theme
export GTK_THEME=Adwaita:dark

# font
export GTK_IM_MODULE=kime
export QT_IM_MODULE=kime
export XMODIFIERS=@im=kime
