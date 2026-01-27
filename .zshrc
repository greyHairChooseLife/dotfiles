# 1. Powerlevel10k Instant Prompt (최상단 필수)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. 기본 설정
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# 3. OMZ 최적화 플래그
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
ZSH_DISABLE_COMPFIX="true"
COMPLETION_WAITING_DOTS="false"
zstyle ':omz:lib:misc' aliases no
zstyle ':omz:alpha:lib:completion' autoreload no
zstyle ':omz:alpha:lib:terminfo' bracketed-paste-magic no

# 4. 플러그인 (최소화)
plugins=(git fzf-tab)

# 5. compinit 최적화 (하루 1회만 재생성)
autoload -Uz compinit
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 6. Oh My Zsh 실행
source $ZSH/oh-my-zsh.sh

# 7. 외부 플러그인 (lazy load 방식으로 변경 가능)
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 8. 서브 설정 파일 (캐시된 경로 사용)
() {
  local sub_dirs=("$HOME/.config/zsh.sub" "$HOME/.local/state/zsh.sub")
  local dir file
  for dir in $sub_dirs; do
    [[ -d $dir ]] || continue
    for file in $dir/*.sh(N); do
      source $file
    done
  done
}

# 9. fzf 초기화 (캐시 사용)
if [[ ! -f ~/.fzf.zsh ]] || [[ $(command -v fzf) -nt ~/.fzf.zsh ]]; then
  fzf --zsh > ~/.fzf.zsh 2>/dev/null
fi
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 10. p10k 설정
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 11. fzf-tab 설정
zstyle ':fzf-tab:*' fzf-flags '--bind=tab:accept'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' continuous-trigger '/'

# 12. 옵션
unsetopt nomatch
