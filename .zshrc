# 1. Pure prompt 설정
fpath+=($HOME/.zsh/pure)
autoload -Uz promptinit
promptinit
prompt pure
# Git 업데이트 체크 방지 (속도 향상)
export PURE_GIT_PULL=1
# PURE_PROMPT_SYMBOL="★"
PURE_SUSPENDED_JOBS_SYMBOL="󱅂 "
PURE_GIT_STASH_SYMBOL=" "
PURE_GIT_DOWN_ARROW="󰧩"
PURE_GIT_UP_ARROW="󰠽"
PURE_PROMPT_SYMBOL=""
PURE_PROMPT_VICMD_SYMBOL=" >"

# 2. Completion 시스템
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 3. Completion 스타일
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 4. fzf-tab (completion 강화)
[[ -d ~/.zsh/fzf-tab ]] && source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# 5. Syntax highlighting
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 6. 서브 설정 파일
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

# 7. fzf
if [[ ! -f ~/.fzf.zsh ]] || [[ $(command -v fzf) -nt ~/.fzf.zsh ]]; then
  fzf --zsh > ~/.fzf.zsh 2>/dev/null
fi
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 8. fzf-tab 설정
zstyle ':fzf-tab:*' fzf-flags '--bind=tab:accept'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' continuous-trigger '/'

# 9. 옵션
unsetopt nomatch
setopt auto_cd
setopt hist_ignore_dups
