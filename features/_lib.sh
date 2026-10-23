# Shared helpers for features/*/install.sh and uninstall.sh. Source, never execute.

link() { ln -sfn "$1" "$2" && echo "[ok] $2"; }

sudo_link() { sudo install -Dm755 "$1" "$2" && echo "[ok] $2"; }

unlink() { rm -f "$1" && echo "[removed] $1"; }

is_link() { [ -L "$1" ] && [ -e "$1" ]; }

sudo_remove() { sudo rm -f "$1" && echo "[removed] $1"; }
