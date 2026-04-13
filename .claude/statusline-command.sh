#!/bin/bash

# Read Claude Code context from stdin
input=$(cat)
# echo "$input" > /tmp/statusline_debug.json

# ── Extract information from stdin JSON ──
model=$(echo "$input" | jq -r '.model.display_name // ""')
[ -z "$model" ] && model="Claude"
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // ""')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // ""')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // ""')
rate_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // ""')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // ""')
rate_7d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // ""')

# ── ANSI Colors ──
C_RESET="\033[0m"
C_DIM="\033[2m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"
C_GRAY="\033[38;5;249m"
C_PATH="\033[38;5;67m"

# ── Git status symbols ──
GIT_SYM_STASH="*"      # stash count
GIT_SYM_STAGED="+"     # staged files
GIT_SYM_MODIFIED="!"   # modified (unstaged) files
GIT_SYM_UNTRACKED="?"  # untracked files
GIT_SYM_CONFLICT="~"   # conflicted files

PATH_TRUNCATE_LEFT=40

KERNEL_TYPE=$(uname -s)

# ── Helper: colored context bar (10 chars) ──
colored_bar() {
    local percent=${1:-0}
    local width=10
    local filled=$(((percent * width) / 100))
    local empty=$((width - filled))
    local color
    if [ "$percent" -ge 85 ] 2> /dev/null; then
        color="$C_RED"
    elif [ "$percent" -ge 70 ] 2> /dev/null; then
        color="$C_YELLOW"
    else
        color="$C_GREEN"
    fi
    local bar=""
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    local ebar=""
    for ((i = 0; i < empty; i++)); do ebar+="░"; done
    echo "${color}${bar}${C_DIM}${ebar}${C_RESET}"
}

# ── Helper: context color ──
get_ctx_color() {
    local percent=${1:-0}
    if [ "$percent" -ge 85 ] 2> /dev/null; then
        echo "$C_RED"
    elif [ "$percent" -ge 70 ] 2> /dev/null; then
        echo "$C_YELLOW"
    else
        echo "$C_GREEN"
    fi
}

# ── Get plan name from credentials ──
get_plan_name() {
    local sub_type=""
    if [ "$KERNEL_TYPE" = "Darwin" ]; then
        local creds
        creds=$(/usr/bin/security find-generic-password -s "Claude Code-credentials" -a "$USER" -w 2> /dev/null)
        if [ -n "$creds" ]; then
            sub_type=$(echo "$creds" | jq -r '.claudeAiOauth.subscriptionType // ""' 2> /dev/null)
        fi
    else
        local creds_file="$HOME/.claude/.credentials.json"
        if [ -f "$creds_file" ]; then
            sub_type=$(jq -r '.claudeAiOauth.subscriptionType // ""' "$creds_file" 2> /dev/null)
        fi
    fi
    # Normalize
    local lower=$(echo "$sub_type" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
        *max*) echo "Max" ;;
        *pro*) echo "Pro" ;;
        *team*) echo "Team" ;;
        *) echo "" ;;
    esac
}

# ── Helper: format epoch reset time as relative duration ──
format_epoch_reset() {
    local reset_epoch="$1"
    [ -z "$reset_epoch" ] || [ "$reset_epoch" = "null" ] && return
    local now diff_s
    now=$(date +%s)
    diff_s=$((reset_epoch - now))
    [ "$diff_s" -le 0 ] && return
    local diff_m=$(((diff_s + 59) / 60))
    if [ "$diff_m" -lt 60 ]; then
        echo "${diff_m}m"
    else
        local h=$((diff_m / 60))
        local m=$((diff_m % 60))
        [ "$m" -gt 0 ] && echo "${h}h ${m}m" || echo "${h}h"
    fi
}

# ── Helper: parse ISO8601 timestamp to epoch (supports GNU date & macOS /bin/date) ──
parse_iso_to_epoch() {
    local ts="$1"
    [ -z "$ts" ] || [ "$ts" = "null" ] && return
    local stripped="${ts%%.*}"  # remove fractional seconds
    stripped="${stripped%%Z}"   # remove trailing Z
    local epoch
    # Try GNU date first (works on Linux, and macOS with coreutils)
    epoch=$(date -d "$ts" +%s 2> /dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return
    fi
    # Fallback: macOS native /bin/date
    epoch=$(/bin/date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2> /dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return
    fi
    # Last resort: python3
    epoch=$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('${ts}'.replace('Z','+00:00')).timestamp()))" 2> /dev/null)
    [ -n "$epoch" ] && echo "$epoch"
}

# ── Format reset time as relative duration ──
format_reset_time() {
    local reset_str="$1"
    [ "$reset_str" = "null" ] || [ -z "$reset_str" ] && return
    local now reset_epoch diff_s
    now=$(date +%s)
    reset_epoch=$(parse_iso_to_epoch "$reset_str")
    [ -z "$reset_epoch" ] && return
    diff_s=$((reset_epoch - now))
    [ "$diff_s" -le 0 ] && return
    local diff_m=$(((diff_s + 59) / 60))
    if [ "$diff_m" -lt 60 ]; then
        echo "${diff_m}m"
    else
        local h=$((diff_m / 60))
        local m=$((diff_m % 60))
        if [ "$m" -gt 0 ]; then
            echo "${h}h ${m}m"
        else
            echo "${h}h"
        fi
    fi
}

# ── Calculate session duration from transcript ──
get_session_duration() {
    [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && return
    local first_ts
    # First line may have null timestamp (file-history-snapshot), find first non-null
    first_ts=$(head -20 "$transcript_path" 2> /dev/null | jq -r '.timestamp // empty' 2> /dev/null | head -1)
    [ -z "$first_ts" ] && return
    local start_epoch now
    start_epoch=$(parse_iso_to_epoch "$first_ts")
    [ -z "$start_epoch" ] && return
    now=$(date +%s)
    local diff_s=$((now - start_epoch))
    local mins=$((diff_s / 60))
    if [ "$mins" -lt 1 ]; then
        echo "<1m"
    elif [ "$mins" -lt 60 ]; then
        echo "${mins}m"
    else
        local h=$((mins / 60))
        local m=$((mins % 60))
        echo "${h}h ${m}m"
    fi
}

# ── Get Claude Code process memory (PID:MB) ──
get_claude_memory() {
    local pid=$$
    local claude_pid=""
    while [ "$pid" -gt 1 ] 2> /dev/null; do
        pid=$(ps -o ppid= -p "$pid" 2> /dev/null | tr -d ' ')
        [ -z "$pid" ] && break
        [ "$pid" -le 1 ] && break
        local cmd
        cmd=$(ps -o comm= -p "$pid" 2> /dev/null)
        if [[ "$cmd" == *"node"* ]] || [[ "$cmd" == *"claude"* ]]; then
            claude_pid="$pid"
        fi
    done
    [ -z "$claude_pid" ] && return
    local all_pids="$claude_pid"
    local queue="$claude_pid"
    while [ -n "$queue" ]; do
        local next_queue=""
        for p in $queue; do
            local children
            children=$(pgrep -P "$p" 2> /dev/null)
            if [ -n "$children" ]; then
                all_pids="$all_pids $children"
                next_queue="$next_queue $children"
            fi
        done
        queue=$(echo "$next_queue" | xargs)
    done
    local total_rss=0
    for p in $all_pids; do
        local rss
        rss=$(ps -o rss= -p "$p" 2> /dev/null | tr -d ' ')
        if [ -n "$rss" ] && [ "$rss" -gt 0 ] 2> /dev/null; then
            total_rss=$((total_rss + rss))
        fi
    done
    local mb=$((total_rss / 1024))
    local gb_int=$((mb / 1024))
    local gb_dec=$(((mb % 1024) * 10 / 1024))
    echo "${claude_pid}:${gb_int}.${gb_dec}"
}

get_memory_color() {
    local gb_str=$1
    local gb_int="${gb_str%%.*}"
    if [ "$gb_int" -lt 1 ] 2> /dev/null; then
        echo "$C_GREEN"
    elif [ "$gb_int" -lt 2 ] 2> /dev/null; then
        echo "$C_YELLOW"
    elif [ "$gb_int" -lt 4 ] 2> /dev/null; then
        echo "$C_MAGENTA"
    else
        echo "$C_RED"
    fi
}

# ════════════════════════════════════════════
# Collect data
# ════════════════════════════════════════════

# CWD display (abbreviate home, truncate left if > $PATH_TRUNCATE_LEFT chars)
if [[ "$cwd" == "$HOME"* ]]; then
    cwd_display="~${cwd#$HOME}"
else
    cwd_display="$cwd"
fi
if [ "${#cwd_display}" -gt $PATH_TRUNCATE_LEFT ]; then
    truncated_len=$((PATH_TRUNCATE_LEFT - 3))
    cwd_display="...${cwd_display: -$truncated_len}"
fi

# Git branch + status
git_branch=""
git_stash=0
git_staged=0
git_modified=0
git_untracked=0
git_conflict=0
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2> /dev/null \
                                                                     || git -C "$cwd" describe --tags --exact-match 2> /dev/null \
                                                                         || git -C "$cwd" rev-parse --short HEAD 2> /dev/null)
    git_stash=$(git -C "$cwd" stash list 2> /dev/null | wc -l | tr -d ' ')
    git_staged=$(git -C "$cwd" diff --cached --name-only 2> /dev/null | wc -l | tr -d ' ')
    git_modified=$(git -C "$cwd" diff --name-only 2> /dev/null | wc -l | tr -d ' ')
    git_untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2> /dev/null | wc -l | tr -d ' ')
    git_conflict=$(git -C "$cwd" diff --name-only --diff-filter=U 2> /dev/null | wc -l | tr -d ' ')
fi

# Plan name
plan_name=$(get_plan_name)

# Memory
mem_info=$(get_claude_memory)
claude_pid=""
mem_mb=""
if [ -n "$mem_info" ]; then
    claude_pid="${mem_info%%:*}"
    mem_mb="${mem_info##*:}"
fi

# Session duration
session_dur=$(get_session_duration)

# ════════════════════════════════════════════
# LINE 1: [Model | Plan] ContextBar XX% | project git:(branch) | PID / MEM
# ════════════════════════════════════════════
line1=""

# Model + Plan badge
model_badge="$model"
if [ -n "$plan_name" ]; then
    model_badge="$model | $plan_name"
fi
line1+="${C_CYAN}[${model_badge}]${C_RESET}"

# Git branch + status: (*1 +3 !2 ?1 ~1)
if [ -n "$git_branch" ]; then
    line1+=" | ${C_MAGENTA}${git_branch}${C_RESET}"
    # Build git status string
    git_status_parts=""
    [ "$git_stash" -gt 0 ] 2> /dev/null && git_status_parts+="${GIT_SYM_STASH}${git_stash} "
    [ "$git_staged" -gt 0 ] 2> /dev/null && git_status_parts+="${GIT_SYM_STAGED}${git_staged} "
    [ "$git_modified" -gt 0 ] 2> /dev/null && git_status_parts+="${GIT_SYM_MODIFIED}${git_modified} "
    [ "$git_untracked" -gt 0 ] 2> /dev/null && git_status_parts+="${GIT_SYM_UNTRACKED}${git_untracked} "
    [ "$git_conflict" -gt 0 ] 2> /dev/null && git_status_parts+="${GIT_SYM_CONFLICT}${git_conflict} "
    if [ -n "$git_status_parts" ]; then
        git_status_parts="${git_status_parts% }"  # remove trailing space
        line1+=" ${C_YELLOW}(${git_status_parts})${C_RESET}"
    fi
else
    line1+=" | ${C_GRAY}X${C_RESET}"
fi

# Full path
line1+=" | ${C_PATH}${cwd_display}${C_RESET}"

# PID | Memory
if [ -n "$mem_mb" ] && [ "$mem_mb" != "0" ]; then
    mem_color=$(get_memory_color "$mem_mb")
    line1+=" | ${mem_color}Mem ${mem_mb}GB${C_RESET} ${C_GRAY}(pid:${claude_pid})${C_RESET}"
fi

# ════════════════════════════════════════════
# LINE 2: 5h: QuotaBar XX% (reset Xh Xm) | Duration | HH:MM:SS
# ════════════════════════════════════════════
line2=""
line2_parts=()

# 5-hour rate limit
if [ -n "$rate_5h" ] && [ "$rate_5h" != "null" ]; then
    five_int=$(printf "%.0f" "$rate_5h" 2> /dev/null)
    if [ "$five_int" -ge 90 ] 2> /dev/null; then
        rcolor="$C_RED"
    elif [ "$five_int" -ge 75 ] 2> /dev/null; then
        rcolor="$C_YELLOW"
    else
        rcolor="$C_PATH"
    fi
    five_display="5h ${rcolor}${five_int}%${C_RESET}"
    five_reset_str=$(format_epoch_reset "$rate_5h_reset")
    [ -n "$five_reset_str" ] && five_display+=" ${C_GRAY}(${five_reset_str})${C_RESET}"
    line2_parts+=("$five_display")
else
    line2_parts+=("${C_GRAY}5h -${C_RESET}")
fi

# 7-day rate limit
if [ -n "$rate_7d" ] && [ "$rate_7d" != "null" ]; then
    seven_int=$(printf "%.0f" "$rate_7d" 2> /dev/null)
    if [ "$seven_int" -ge 90 ] 2> /dev/null; then
        rcolor="$C_RED"
    elif [ "$seven_int" -ge 75 ] 2> /dev/null; then
        rcolor="$C_YELLOW"
    else
        rcolor="$C_PATH"
    fi
    seven_display="7d ${rcolor}${seven_int}%${C_RESET}"
    seven_reset_str=$(format_epoch_reset "$rate_7d_reset")
    [ -n "$seven_reset_str" ] && seven_display+=" ${C_GRAY}(${seven_reset_str})${C_RESET}"
    line2_parts+=("$seven_display")
else
    line2_parts+=("${C_GRAY}7d -${C_RESET}")
fi

# Context bar + remaining % (always show; default to 0% used / 100% remaining if no messages yet)
if [ -z "$ctx_used" ] || [ "$ctx_used" = "null" ]; then
    ctx_used=0
fi
if [ -z "$ctx_remaining" ] || [ "$ctx_remaining" = "null" ]; then
    ctx_remaining=100
fi
ctx_bar=$(colored_bar "$ctx_used")
local_ctx_color="$C_GREEN"
if [ "$ctx_remaining" -lt 10 ] 2> /dev/null; then
    local_ctx_color="$C_RED"
elif [ "$ctx_remaining" -lt 20 ] 2> /dev/null; then
    local_ctx_color="$C_YELLOW"
fi
line2_parts+=("Ctx ${ctx_bar} ${local_ctx_color}${ctx_remaining}%${C_RESET}")

# Session duration (always show; default to 0m if transcript not available yet)
if [ -z "$session_dur" ]; then
    session_dur="0m"
fi
line2_parts+=("${C_GRAY}session: ${session_dur}${C_RESET}")

# Join line2 parts with " | "
for i in "${!line2_parts[@]}"; do
    if [ "$i" -gt 0 ]; then
        line2+=" | "
    fi
    line2+="${line2_parts[$i]}"
done

# ════════════════════════════════════════════
# Output
# ════════════════════════════════════════════
echo -e "${line1}\n${line2}"
