#!/bin/bash
# Helper for rg_picker.sh — prints fzf reload+change-prompt action string

ACTION="$1"

HIDDEN=$(cat /tmp/rg-fzf-hidden-state)
GLOB=$(cat /tmp/rg-fzf-glob-state)

case "$ACTION" in
    toggle-hidden)
        if [[ "$HIDDEN" -eq 0 ]]; then
            HIDDEN=1
            echo 1 > /tmp/rg-fzf-hidden-state
        else
            HIDDEN=0
            echo 0 > /tmp/rg-fzf-hidden-state
        fi
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROMPT=""
[[ "$HIDDEN" -eq 1 ]] && PROMPT="(+hidden) "
[[ -n "$GLOB" ]] && PROMPT="${PROMPT}(glob:$GLOB) "
PROMPT="${PROMPT}Search> "

echo "reload($SCRIPT_DIR/rg_search.sh)+change-prompt($PROMPT)+clear-query"
