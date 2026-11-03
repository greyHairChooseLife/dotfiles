#!/usr/bin/env bash
# Force the kime input category to Latin.
#
# Why this exists: kime has no control interface. kime-indicator.sock is written
# by the engine only (it drives the tray icon), so the category can be changed
# only by feeding kime the toggle key. The current category can be read back
# from the same socket -- 1 byte, 1 = Hangul, 0 = Latin -- which is what makes
# this deterministic instead of a blind toggle. The read is only meaningful with
# `global_category_state: true` in ~/.config/kime/config.yaml; otherwise that
# byte is just the last client that changed category.
#
# xdotool delivers the key to the focused X window, and only a terminal forwards
# it to kime, so this acts on the terminal, not on an arbitrary app. It exits
# silently when kime, xdotool or X are not available.

set -u

sock="${XDG_RUNTIME_DIR:-/tmp}/kime-indicator.sock"

[ -S "$sock" ] || exit 0
[ -n "${DISPLAY:-}" ] || exit 0
command -v xdotool >/dev/null 2>&1 || exit 0
command -v nc >/dev/null 2>&1 || exit 0

read_category() {
    nc -U -w1 "$sock" 2>/dev/null | od -An -tu1 | tr -d ' \n'
}

# Hangul is 1. Re-read after the key so a dropped event is retried; the cap keeps
# a stale read from toggling twice and landing back on Hangul.
attempt=0
while [ "$attempt" -lt 3 ]; do
    [ "$(read_category)" = "1" ] || break
    xdotool key --clearmodifiers Hangul || break
    sleep 0.15
    attempt=$((attempt + 1))
done

exit 0
