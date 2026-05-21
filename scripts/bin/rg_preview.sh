#!/bin/bash
# Preview a ripgrep result line with bat, resolving relative path against saved CWD
# Usage: rg_preview.sh <file> <line>

FILE="$1"
LINE="$2"
CWD=$(cat /tmp/rg-fzf-cwd 2>/dev/null || echo ".")

bat --color=always --plain --highlight-line "$LINE" "$CWD/$FILE"
