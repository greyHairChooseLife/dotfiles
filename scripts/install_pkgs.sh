#!/bin/bash

sudo pacman -S --needed \
    7zip \
    alacritty \
    alsa-utils \
    base \
    base-devel \
    bat \
    bluez \
    bluez-utils \
    brightnessctl \
    btop \
    cmatrix \
    docker \
    dunst \
    efibootmgr \
    fd \
    feh \
    ffmpeg \
    fzf \
    gdu \
    git \
    git-delta \
    github-cli \
    gnome-themes-extra \
    i3-wm \
    i3lock \
    i3status \
    imagemagick \
    intel-ucode \
    jq \
    lsd \
    luarocks \
    magic-wormhole \
    man-db \
    man-pages \
    fastfetch \
    neovim \
    network-manager-applet \
    networkmanager \
    nodejs-lts-jod \
    noto-fonts \
    noto-fonts-emoji \
    npm \
    pulseaudio \
    pulseaudio-alsa \
    pulseaudio-bluetooth \
    ripgrep \
    rofi \
    sox \
    stow \
    sudo \
    tmux \
    trash-cli \
    tree \
    ttf-dejavu \
    ueberzug \
    xclip \
    xdg-utils \
    xdotool \
    xorg-bdftopcf \
    xorg-iceauth \
    xorg-mkfontscale \
    xorg-server \
    xorg-sessreg \
    xorg-setxkbmap \
    xorg-smproxy \
    xorg-x11perf \
    xorg-xauth \
    xorg-xbacklight \
    xorg-xcmsdb \
    xorg-xcursorgen \
    xorg-xdpyinfo \
    xorg-xdriinfo \
    xorg-xev \
    xorg-xgamma \
    xorg-xhost \
    xorg-xinit \
    xorg-xinput \
    xorg-xkbcomp \
    xorg-xkbevd \
    xorg-xkbprint \
    xorg-xkbutils \
    xorg-xkill \
    xorg-xlsatoms \
    xorg-xlsclients \
    xorg-xmodmap \
    xorg-xpr \
    xorg-xrandr \
    xorg-xrdb \
    xorg-xrefresh \
    xorg-xset \
    xorg-xsetroot \
    xorg-xvinfo \
    xorg-xwd \
    xorg-xwininfo \
    xorg-xwud \
    xterm \
    yazi \
    rsync \
    docker-compose \
    openssh \
    go \
    yq \
    cmus \
    rclone \
    fuse3 \
    ueberzugpp \
    tldr \
    cargo-binstall \
    tmuxp \
    time \
    wget \
    zathura \
    zathura-pdf-poppler \
    tlp \
    cmake \
    cppcheck \
    gdb \
    python-debugpy \
    ghostscript \
    lldb \
    pwndbg \
    ipython \
    i3exit \
    rustnet-bin

# Install AUR packages
yay -S --needed \
    brave-bin \
    i3-scrot \
    kime-bin \
    mons \
    python-edge-tts \
    python-openai-whisper \
    sysz \
    ttf-d2coding-nerd \
    ttf-dejavu-nerd \
    xbanish \
    vi-mongo \
    lazydocker \
    localsend-bin \
    wkhtmltopdf-bin \
    python-edge-tts

# Enable important services
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Config etc
# docker 사용 권한
sudo usermod -aG docker $USER
# npm global
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
mkdir -p $HOME/.local/state/bash.sub
# 기본 템플릿 파일
touch $HOME/.local/state/bash.sub/api-key.sh # template
touch $HOME/.local/state/bash.sub/ssh.sh # template
