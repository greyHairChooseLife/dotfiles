# WARN:
# ..
# 1. 비밀번호 등 중요한 정보는 사용하지 않기(remote repository에 업로드 가능)

export NAS_SERVER="/mnt/cb-nas" # 충북프로메이커센터, 미래창업연구소

# about tmux
export TMUX_CONFIG_DIR="$HOME/.config/tmux"
export TMUX_PLUGIN_DIR="$HOME/.local/bin/tmux/plugins"
export TMUX_RESURRECT_DIR="$HOME/.local/state/tmux-resurrects/"

export MANPAGER='nvim +Man!'
export MANWIDTH=999

export LANG=en_US.UTF-8 # 이게 ssh servet-clinet간에 다르면 한글 랜더링 오류가 난다.

# for global theme
export GTK_THEME=Adwaita:dark

# font
# MEMO::
# - kime는 ghostty에서 안된다. 도대체 왜!!!
# - ibus는 버그가 많다. 아님 내가 설정을 못하는건가?
export GTK_IM_MODULE=kime
export QT_IM_MODULE=kime
export XMODIFIERS=@im=kime
# export GTK_IM_MODULE=ibus
# export QT_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus
