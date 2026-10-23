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

# libexec convention: helpers that are not user commands live in
# ~/.local/libexec/<name> and are referenced by absolute path.
link_libexec() { # $1 feature dir, $2 installed name
    local f
    [ -d "$1/libexec" ] || return 0
    mkdir -p "$HOME/.local/libexec/$2"
    for f in "$1"/libexec/*; do
        link "$f" "$HOME/.local/libexec/$2/$(basename "$f")"
    done
}

unlink_libexec() {
    local f
    [ -d "$1/libexec" ] || return 0
    for f in "$1"/libexec/*; do
        unlink "$HOME/.local/libexec/$2/$(basename "$f")"
    done
}

status_libexec() {
    local f
    [ -d "$1/libexec" ] || return 0
    for f in "$1"/libexec/*; do
        is_link "$HOME/.local/libexec/$2/$(basename "$f")" || return 1
    done
}

# Install a feature this one depends on, when it is not in place yet.
require_feature() { # $1 features dir, $2 feature name
    local script="$1/$2/install.sh"
    if [ ! -f "$script" ]; then
        echo "require_feature: feature '$2' not found" >&2
        return 1
    fi
    bash "$script" --status >/dev/null 2>&1 && return 0
    echo "[dep] installing feature '$2'"
    bash "$script"
}
