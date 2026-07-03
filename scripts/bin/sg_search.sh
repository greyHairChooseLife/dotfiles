#!/bin/bash
# sg_search.sh — ast-grep search with fzf preview + nvim open
#
# Passes arguments through to `ast-grep`, adds --json, pipes results
# through jq + fzf + bat, and opens selection in nvim at matched line.
#
# Usage:
#   sg_search.sh -p '<pattern>' -l <lang> [paths...]   # inline pattern
#   sg_search.sh -r <rule.yml> [paths...]               # rule file
#   sg_search.sh -k <kind> -l <lang>                    # kind-based
#
# Examples:
#   sg_search.sh -p 'def $NAME($$): $$$BODY' -l python
#   sg_search.sh -p 'console.log($$$ARGS)' -l typescript
#   sg_search.sh -r ~/script.yml src/
#
# Dependencies: ast-grep, jq, fzf, bat
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

    SCRIPT=$(mktemp /tmp/sg-p-XXXX.vim)
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

# Append --json if not already present
HAS_JSON=false
for arg in "$@"; do
    [ "$arg" = "--json" ] && HAS_JSON=true && break
done

if $HAS_JSON; then
    RAW=$(ast-grep "$@" 2>/dev/null)
else
    RAW=$(ast-grep "$@" --json 2>/dev/null)
fi

DATA=$(echo "$RAW" \
    | jq -r '.[] | "\(.file):\(.range.start.line + 1):\u001b[36m\(.text | split("\n")[0])\u001b[0m"' 2>/dev/null)

if [ -z "$DATA" ]; then
    echo "No matches found" >&2
    exit 0
fi

SELECTED=$(echo "$DATA" \
    | fzf --ansi --multi \
        --delimiter ':' \
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5' \
        --bind "ctrl-f:execute(sg_search.sh --peek {+1} -- {+2})" \
        --header 'Enter: open in nvim (vsplits) | Ctrl-f: peek')

[ -z "$SELECTED" ] && exit 0

# Build vimscript to open each file at its exact line in vsplits
# nvim's +line on command line applies only to the last file, so -S is used
SCRIPT=$(mktemp /tmp/sg-XXXXXX.vim)
trap 'rm -f "$SCRIPT"' EXIT

echo "$SELECTED" | awk -F: '
NR==1 { printf "e %s\n%s\n", $1, $2 }
NR>1  { printf "vsplit %s\n%s\n", $1, $2 }
END   { print "wincmd w" }
' > "$SCRIPT"

nvim -S "$SCRIPT"
