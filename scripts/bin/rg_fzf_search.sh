#!/bin/bash
# rg_fzf_search.sh — ripgrep search with fzf preview + nvim open
#
# Passes arguments through to `rg`, pipes results through fzf + bat,
# and opens selection in nvim at matched line.
#
# Usage:
#   rg_fzf_search.sh <pattern> [rg flags] [paths...]
#
# Examples:
#   rg_fzf_search.sh foo src/
#   rg_fzf_search.sh -i 'error.*timeout'
#   rg_fzf_search.sh --hidden 'TODO' ~/project
#
# Dependencies: rg, fzf, bat
#
# Controls:
#   Enter      open selected file(s) in horizontal splits
#   Ctrl-f     peek selected file(s) in nvim (back to fzf on quit)
#   Tab        multi-select

set -euo pipefail

# --peek helper mode: called from fzf execute binding
# Receives: <file1> <file2> ... -- <line1> <line2> ...
if [ "${1:-}" = "--peek" ]; then
    shift
    FILES=()
    LINES=()
    mode=files
    for arg in "$@"; do
        if [ "$arg" = "--" ]; then
            mode=lines
            continue
        fi
        if [ "$mode" = "files" ]; then
            FILES+=("$arg")
        else
            LINES+=("$arg")
        fi
    done

    SCRIPT=$(mktemp /tmp/rgs-p-XXXX.vim)
    for i in "${!FILES[@]}"; do
        if [ "$i" -eq 0 ]; then
            printf "e %s\n%s\n" "${FILES[$i]}" "${LINES[$i]}"
        else
            printf "vsplit %s\n%s\n" "${FILES[$i]}" "${LINES[$i]}"
        fi
    done >> "$SCRIPT"
    printf "wincmd w\n" >> "$SCRIPT"

    nvim -S "$SCRIPT"
    rm -f "$SCRIPT"
    exit 0
fi

# --- Main search mode ---

if [ $# -eq 0 ]; then
    sed -n '6,15p' "$0"
    exit 1
fi

# Run rg with color=always for fzf preview; capture raw output
RAW=$(rg --color=always --line-number "$@" 2>/dev/null || true)

if [ -z "$RAW" ]; then
    echo "No matches found" >&2
    exit 0
fi

# Format: file:line:content (ansi-colored)
# jq-friendly parsing: pipe through awk to produce file:line:colored-content
DATA=$(echo "$RAW" \
    | awk -F: '{ match($0, /^[^:]+:[0-9]+:/); file_line = substr($0, RSTART, RLENGTH); rest = substr($0, RLENGTH+1); printf "%s\u001b[36m%s\u001b[0m\n", file_line, rest }')

SELECTED=$(echo "$DATA" \
    | fzf --ansi --multi \
        --delimiter ':' \
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5' \
        --bind "ctrl-f:execute(rg_fzf_search.sh --peek {+1} -- {+2})" \
        --header 'Enter: open in nvim (vsplits) | Ctrl-f: peek')

[ -z "$SELECTED" ] && exit 0

# Build vimscript to open each file at its exact line in vsplits
SCRIPT=$(mktemp /tmp/rgs-XXXXXX.vim)
trap 'rm -f "$SCRIPT"' EXIT

echo "$SELECTED" | awk -F: '
NR==1 { printf "e %s\n%s\n", $1, $2 }
NR>1  { printf "vsplit %s\n%s\n", $1, $2 }
END   { print "wincmd w" }
' > "$SCRIPT"

nvim -S "$SCRIPT"
