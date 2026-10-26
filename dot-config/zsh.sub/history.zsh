# Create history directory if it doesn't exist
mkdir -p ~/.zsh_history_dir

# Single history store, shared by every shell. One line per recorded command:
#   timestamp<TAB>pid<TAB>pwd<TAB>command
# Reads and rewrites live in the `zsh-history` helper; the append below takes the
# same flock as those rewrites so a truncation never eats a concurrent append.
HISTDIR=~/.zsh_history_dir
HISTSTORE=$HISTDIR/history

# Separate zsh internal history from custom history
export HISTFILE=~/.zsh_history_dir/.zsh_internal_hist_$$
export HISTSIZE=500
export SAVEHIST=0

edit_and_return_command() {
    # 현재 줄을 임시 파일에 저장
    local tmpfile=$(mktemp)
    echo "$BUFFER" > "$tmpfile"
    # 에디터로 편집
    ${EDITOR:-vi} "$tmpfile" < /dev/tty > /dev/tty
    # 편집 결과를 다시 커맨드라인에 복원
    BUFFER="$(cat "$tmpfile")"
    CURSOR=${#BUFFER}
    rm "$tmpfile"
    zle reset-prompt
}

# Store format: timestamp<TAB>pid<TAB>pwd<TAB>command
# Function to save only successful commands
save_successful_history() {
    local exit_code=$?
    if [[ $exit_code -ne 127 ]]; then
        local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
        if [[ -n "$last_cmd" ]] && [[ "$last_cmd" != "hi" ]] && [[ "$last_cmd" != "hip" ]]; then
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            { flock 9; printf '%s\t%s\t%s\t%s\n' "$timestamp" "$$" "$PWD" "$last_cmd" >&9 } 9>>"$HISTSTORE"
        fi
    fi
    return $exit_code
}

# Use precmd hook for zsh
precmd_functions+=(save_successful_history)

# List/delete logic lives in the `zsh-history` script on $PATH so it is also
# available inside fzf's execute()/reload() subshells (zsh can't export functions).
per_process_history() {
    local pid="${1:-$$}"
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%m-%d')")

    local selected
    selected=$(
        COLUMNS=$COLUMNS zsh-history list-process ${pid} --reverse \
            | fzf \
            --ansi \
            --multi \
            --delimiter '\t' \
            --with-nth=1 \
            --track \
            --id-nth 2 \
            --header '<Alt+1>: filter by '${PWD}' | <Alt+2>: filter by Date(today) | <Alt+d>: delete' \
            --prompt 'history -PID- > ' \
            --preview 'printf %s {2}' \
            --preview-window 'down,3,hidden,wrap' \
            --bind 'enter:clear-selection+accept' \
            --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
            --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
            --bind "alt-3:reload(zsh-history list-process --reverse ${pid})" \
            --bind "alt-4:reload(zsh-history list-process --no-path --reverse ${pid})" \
            --bind "resize:reload(zsh-history list-process --reverse ${pid})" \
            --bind "alt-d:execute(zsh-history delete-process --ask ${pid} {s+2})+clear-selection+reload(zsh-history list-process --reverse ${pid})" \
            | awk -F'\t' '{print $2}'
    )
    if [[ -n "$selected" ]]; then
        if zle; then
            BUFFER="$selected"
            CURSOR=${#BUFFER}
            zle reset-prompt
        else
            print -s -- "$selected"
            eval "$selected"
        fi
    fi
}
zle -N per_process_history

# Global history function
global_history() {
    local pwd_escaped=$(printf ' %s ' "'${PWD}")
    local today=$(printf ' %s ' "'$(date '+%m-%d')")

    local selected
    selected=$(
        COLUMNS=$COLUMNS zsh-history list-global --reverse \
            | fzf \
            --ansi \
            --multi \
            --delimiter '\t' \
            --with-nth=1 \
            --track \
            --id-nth 2 \
            --header '<Alt+1>: filter by '${PWD}' | <Alt+2>: filter by Date(today) | <Alt+d>: delete' \
            --prompt 'history -Global- > ' \
            --preview 'printf %s {2}' \
            --preview-window 'down,3,hidden,wrap' \
            --bind 'enter:clear-selection+accept' \
            --bind 'ctrl-e:execute(printf "%s" {2} | xclip -selection clipboard)+abort' \
            --bind 'alt-e:execute(printf "%s" {2} | xclip -selection clipboard)' \
            --bind "alt-1:put(${pwd_escaped})" \
            --bind "alt-2:put(${today})" \
            --bind "alt-3:reload(zsh-history list-global --reverse)" \
            --bind "alt-4:reload(zsh-history list-global --no-path --reverse)" \
            --bind "resize:reload(zsh-history list-global --reverse)" \
            --bind "alt-d:execute(zsh-history delete-global --ask {s+2})+clear-selection+reload(zsh-history list-global --reverse)" \
            | awk -F'\t' '{print $2}'
    )
    if [[ -n "$selected" ]]; then
        if zle; then
            BUFFER="$selected"
            CURSOR=${#BUFFER}
            zle reset-prompt
        else
            print -s -- "$selected"
            eval "$selected"
        fi
    fi
}
zle -N global_history

# LRU cleanup: keep the store under MAX_HISTORY_LINES entries
MAX_HISTORY_LINES=50000

# One background pass per shell start: fold any leftover per-pid history files
# (old layout) into the single store, then trim it at most once a day. Both run
# inside zsh-history, which takes the store flock, so a concurrent append from
# another shell is never lost while the file is rewritten.
(
    zsh-history import-legacy
    if flock -n 8; then
        marker="$HISTDIR/.last_cleanup"
        if [[ ! -f "$marker" ]] || [[ "$(cat "$marker")" != "$(date '+%Y-%m-%d')" ]]; then
            zsh-history trim "$MAX_HISTORY_LINES" && date '+%Y-%m-%d' > "$marker"
        fi
    fi
) 8>"$HISTDIR/.cleanup.lock" > /dev/null 2>&1 &!

# Command aliases
alias hip=' per_process_history'      # Current process history
alias hi=' global_history'     # Global history across all processes
