#!/bin/bash

echo ""

# Check prerequisites (must be installed during Arch installation)
PREREQS=(git stow nvim grub-install)
MISSING_PREREQS=()
for cmd in "${PREREQS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING_PREREQS+=("$cmd")
    fi
done

if [ ${#MISSING_PREREQS[@]} -ne 0 ]; then
    echo "ERROR: Missing prerequisites (install these during Arch setup):"
    for cmd in "${MISSING_PREREQS[@]}"; do
        echo "  - $cmd"
    done
    echo ""
    echo "Run: pacman -S git stow neovim grub"
    exit 1
fi

# Check if yay is installed, if not install it
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    bash setup.d/install_yay.sh

    if [ $? -ne 0 ]; then
        echo "Failed to install yay. Exiting."
        exit 1
    fi
    echo "yay installed successfully."
fi

read -p "Update mirror server? (y/n): " update_mirror_answer
if [ "$update_mirror_answer" == 'y' ]; then
    echo "Starting mirror server updating..."
    bash setup.d/update_mirror.sh
fi

# 1. Install packages first (zsh, stow, git, etc. are required for next steps)
read -p "Install basic packages? (y/n): " install_answer
if [ "$install_answer" == 'y' ]; then
    echo "Starting package installation..."
    bash setup.d/install_pkgs.sh

    echo "Package installation completed."
fi

# 2. Install zsh plugins (zsh is now installed)
if [ ! -d "$HOME/.zsh/pure" ]; then
    read -p "zsh plugins not found. Install pure prompt and fzf-tab? (y/n): " install_zsh
    if [ "$install_zsh" == 'y' ]; then
        mkdir -p ~/.zsh

        echo "Installing pure prompt..."
        git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure

        echo "Installing fzf-tab plugin..."
        git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab

        echo "zsh plugins installation completed."
    fi
fi

# 3. Symlink dotfiles (stow is now installed)
read -p "
Config symlink (u)pdate, (d)elete, (c)ancel: " answer

if [ $answer == 'c' ]; then
    echo "Canceled."
    exit 1
elif [ $answer == 'd' ]; then
    stow --target $HOME --dotfiles -D .
    echo "All config symlinks have been removed."
    exit 1
fi

if [ $answer != 'u' ]; then
    echo "Invalid input."
    bash $0
fi

# .Xresources 파일이 있다면 먼저 삭제
[ -f "$HOME/.Xresources" ] && rm "$HOME/.Xresources"

# --dotfiles는 이름이 'dot-'으로 시작하는 것을 '.'으로 번역해준다. ed) `dot-config -> .config`
stow --target $HOME --dotfiles -R .

# 동일한 이름의 plain text 파일이 있다면 실패할 수 있다.
if [ $? -ne 0 ]; then exit 1; fi

# 4. features (each one owns its install.sh / uninstall.sh)
for feature_dir in features/*/; do
    feature=$(basename "$feature_dir")
    # 참고용 디렉터리(install.sh 없음)는 아직 설치할 것이 없다
    [ -f "${feature_dir}install.sh" ] || continue
    description=$(awk 'NR>1 && NF {print; exit}' "$feature_dir/README.md" 2>/dev/null)

    if bash "$feature_dir/install.sh" --status >/dev/null 2>&1; then
        read -p "feature '$feature' is already installed. Reinstall/update? (y/n): " feature_answer
    else
        read -p "Install feature '$feature'? $description (y/n): " feature_answer
    fi

    if [ "$feature_answer" == 'y' ]; then
        if ! bash "$feature_dir/install.sh"; then
            echo "WARNING: '$feature' installation failed."
        fi
    fi
done

# 5. Set zsh as default shell (dotfiles are now symlinked, so zsh config is ready)
if [ "$SHELL" != "$(which zsh)" ]; then
    read -p "Set zsh as default shell? (y/n): " zsh_answer
    if [ "$zsh_answer" == 'y' ]; then
        chsh -s "$(which zsh)"
        echo "Default shell set to zsh. Re-login to apply."
    fi
fi

echo "
Setup complete. Please re-login to apply shell change."
