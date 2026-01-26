#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install docker if not present
if ! command -v docker &>/dev/null; then
    echo "Docker not found. Installing..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm docker
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y docker.io
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y docker
    elif command -v yum &>/dev/null; then
        sudo yum install -y docker
    else
        echo "Unknown package manager. Install docker manually."
        exit 1
    fi
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    echo "Docker installed. You may need to log out and back in for group changes."
    echo "Then run this script again."
    exit 0
fi
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="devbox"
CONTAINER_NAME="devbox"

# Build image if not exists or --build flag
if [[ "$1" == "--build" ]] || [[ -z "$(docker images -q $IMAGE_NAME 2>/dev/null)" ]]; then
    echo "Building $IMAGE_NAME..."
    docker build \
        --build-arg UID=$(id -u) \
        --build-arg GID=$(id -g) \
        -t $IMAGE_NAME \
        "$SCRIPT_DIR"
fi

# Remove existing container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker rm -f $CONTAINER_NAME >/dev/null 2>&1
fi

echo "Starting $CONTAINER_NAME..."
docker run -it \
    --name $CONTAINER_NAME \
    --hostname devbox \
    -v "$DOTFILES_DIR/.zshrc:/home/devuser/.zshrc:ro" \
    -v "$DOTFILES_DIR/.p10k.zsh:/home/devuser/.p10k.zsh:ro" \
    -v "$DOTFILES_DIR/.dir_colors:/home/devuser/.dir_colors:ro" \
    -v "$DOTFILES_DIR/dot-config/zsh.sub:/home/devuser/.config/zsh.sub:ro" \
    -v "$DOTFILES_DIR/dot-config/nvim:/home/devuser/.config/nvim:ro" \
    -v "$DOTFILES_DIR/dot-config/tmux/tmux.conf:/home/devuser/.config/tmux/tmux.conf:ro" \
    -v "$HOME/workspace:/home/devuser/workspace" \
    -w /home/devuser \
    $IMAGE_NAME \
    zsh
