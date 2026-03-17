#!/bin/bash

# Set GOPATH before installing go to prevent ~/go from being created
export GOPATH="$HOME/.go"
export GOBIN="$HOME/.go/bin"
export PATH="$GOBIN:$PATH"

FAILED_PACMAN=()
FAILED_AUR=()

install_pacman() {
    local pkg=$1
    if ! sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
        FAILED_PACMAN+=("$pkg")
    fi
}

install_aur() {
    local pkg=$1
    if ! yay -S --needed --noconfirm "$pkg" 2>/dev/null; then
        FAILED_AUR+=("$pkg")
    fi
}

PACMAN_PKGS=(
    7zip
    alacritty
    alsa-utils
    base
    base-devel
    bat
    bluez
    bluez-utils
    brightnessctl
    btop
    cmatrix
    docker
    dunst
    efibootmgr
    fd
    feh
    ffmpeg
    fzf
    gdu
    git
    git-delta
    github-cli
    gnome-themes-extra
    i3-wm
    i3lock
    i3status
    imagemagick
    intel-ucode
    jq
    lsd
    luarocks
    magic-wormhole
    man-db
    man-pages
    fastfetch
    neovim
    network-manager-applet
    networkmanager
    noto-fonts
    noto-fonts-emoji
    npm
    pulseaudio
    pulseaudio-alsa
    pulseaudio-bluetooth
    ripgrep
    rofi
    sox
    stow
    sudo
    tmux
    trash-cli
    tree
    ttf-dejavu
    ueberzugpp
    xclip
    xdg-utils
    xdotool
    xorg-server
    xorg-bdftopcf
    xorg-iceauth
    xorg-mkfontscale
    xorg-sessreg
    xorg-setxkbmap
    xorg-smproxy
    xorg-x11perf
    xorg-xauth
    xorg-xbacklight
    xorg-xcmsdb
    xorg-xcursorgen
    xorg-xdpyinfo
    xorg-xdriinfo
    xorg-xev
    xorg-xgamma
    xorg-xhost
    xorg-xinit
    xorg-xinput
    xorg-xkbcomp
    xorg-xkbevd
    xorg-xkbprint
    xorg-xkbutils
    xorg-xkill
    xorg-xlsatoms
    xorg-xlsclients
    xorg-xmodmap
    xorg-xpr
    xorg-xrandr
    xorg-xrdb
    xorg-xrefresh
    xorg-xset
    xorg-xsetroot
    xorg-xvinfo
    xorg-xwd
    xorg-xwininfo
    xorg-xwud
    xterm
    yazi
    rsync
    docker-compose
    openssh
    go
    yq
    cmus
    rclone
    fuse3
    tldr
    cargo-binstall
    tmuxp
    time
    wget
    zathura
    zathura-pdf-poppler
    tlp
    cmake
    cppcheck
    gdb
    python-debugpy
    ghostscript
    lldb
    pwndbg
    ipython
    ruby
    autorandr
    perf
    bear
    valgrind
    entr
    sshfs
    zoxide
    lsof
    serie
    sig
    tailscale
    pass
    zsh
    bluetui
)

AUR_PKGS=(
    brave-bin
    claude-code
    claude-code-acp
    eternalterminal
    i3-scrot
    i3exit
    kime-git
    lazyactions-bin
    lazydocker
    lazyssh-bin
    libtexprintf
    localsend-bin
    mons
    mutagen.io-bin
    pandoc-bin
    portal-bin
    pvw-bin
    python-edge-tts
    python-openai-whisper
    rustnet-bin
    sqlit
    stu
    sysz
    ttf-d2coding-nerd
    ttf-dejavu-nerd
    vi-mongo
    wifitui
    wkhtmltopdf-bin
    xbanish
    ytdl
    aws-session-manager-plugin
)

echo "Installing pacman packages..."
for pkg in "${PACMAN_PKGS[@]}"; do
    echo -n "  $pkg ... "
    if sudo pacman -S --needed --noconfirm "$pkg" &>/dev/null; then
        echo "ok"
    else
        echo "FAILED"
        FAILED_PACMAN+=("$pkg")
    fi
done

echo ""
echo "Installing AUR packages..."
for pkg in "${AUR_PKGS[@]}"; do
    echo -n "  $pkg ... "
    if yay -S --needed --noconfirm "$pkg" &>/dev/null; then
        echo "ok"
    else
        echo "FAILED"
        FAILED_AUR+=("$pkg")
    fi
done

# Enable important services
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# docker 사용 권한
sudo usermod -aG docker $USER

# npm global
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

mkdir -p $HOME/.local/state/bash.sub
touch $HOME/.local/state/bash.sub/api-key.sh # template
touch $HOME/.local/state/bash.sub/ssh.sh     # template

# Summary
echo ""
if [ ${#FAILED_PACMAN[@]} -eq 0 ] && [ ${#FAILED_AUR[@]} -eq 0 ]; then
    echo "All packages installed successfully."
else
    if [ ${#FAILED_PACMAN[@]} -gt 0 ]; then
        echo "Failed pacman packages:"
        for pkg in "${FAILED_PACMAN[@]}"; do echo "  - $pkg"; done
    fi
    if [ ${#FAILED_AUR[@]} -gt 0 ]; then
        echo "Failed AUR packages:"
        for pkg in "${FAILED_AUR[@]}"; do echo "  - $pkg"; done
    fi
fi
