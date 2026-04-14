#!/bin/bash
# Runs rg with state from /tmp/rg-fzf-* state files

HIDDEN=$(cat /tmp/rg-fzf-hidden-state 2>/dev/null || echo 0)
GLOB=$(cat /tmp/rg-fzf-glob-state 2>/dev/null || echo "")

args=("--line-number" "--no-heading" "--color=always")
[[ "$HIDDEN" -eq 1 ]] && args+=("--hidden" "-u")
[[ -n "$GLOB" ]] && args+=("--glob" "$GLOB")
args+=("")

rg "${args[@]}" || true
