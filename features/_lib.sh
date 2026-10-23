# Shared helpers for features/*/install.sh and uninstall.sh. Source, never execute.

link() { ln -sfn "$1" "$2" && echo "[ok] $2"; }

sudo_link() { sudo install -Dm755 "$1" "$2" && echo "[ok] $2"; }

unlink() { rm -f "$1" && echo "[removed] $1"; }

is_link() { [ -L "$1" ] && [ -e "$1" ]; }

sudo_remove() { sudo rm -f "$1" && echo "[removed] $1"; }

# bin/ convention: every file under <feature>/bin is linked into ~/.local/bin.
# features without a bin/ directory (reference-only dirs) are ignored.
link_bin() {
    local f
    [ -d "$1/bin" ] || return 0
    mkdir -p "$HOME/.local/bin"
    for f in "$1"/bin/*; do
        link "$f" "$HOME/.local/bin/$(basename "$f")"
    done
}

unlink_bin() {
    local f
    [ -d "$1/bin" ] || return 0
    for f in "$1"/bin/*; do
        unlink "$HOME/.local/bin/$(basename "$f")"
    done
}

# Succeeds when every <feature>/bin file is linked and the link is not dangling.
status_bin() {
    local f
    [ -d "$1/bin" ] || return 0
    for f in "$1"/bin/*; do
        is_link "$HOME/.local/bin/$(basename "$f")" || return 1
    done
}
