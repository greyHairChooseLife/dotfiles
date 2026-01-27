#!/bin/bash

echo ""

# Check if yay is installed, if not install it
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    bash scripts/install_yay.sh

    if [ $? -ne 0 ]; then
        echo "Failed to install yay. Exiting."
        exit 1
    fi
    echo "yay installed successfully."
fi

read -p "Update mirror server? (y/n): " update_mirror_answer
if [ "$update_mirror_answer" == 'y' ]; then
    echo "Starting mirror server updating..."
    bash scripts/update_mirror.sh
fi

# Ask if user wants to install packages
read -p "Install basic packages? (y/n): " install_answer
if [ "$install_answer" == 'y' ]; then
    echo "Starting package installation..."
    bash scripts/install_pkgs.sh
    echo "Update mime desktop at '/usr/share/applications/'"
    sudo bash scripts/mime_desktop.sh

    if [ $? -ne 0 ]; then
          echo "An error occurred during package installation."
          read -p "Do you want to continue? (y/n): " continue_answer
        if [ "$continue_answer" != 'y' ]; then
              echo "Canceled."
            exit 1
        fi
    else
          echo "Package installation completed."
    fi
fi

# Install zsh plugins if not exists
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

read -p "
Symlink completed.

Would you like to apply the changes? (y/n): " answer

if [ $answer != 'y' ]; then
      echo "Canceled."
    exit 1
fi

read -p "Would you like to reload dunst? (y/n): " answer
if [ $answer == 'y' ]; then dunstctl reload; fi

read -p "Would you like to reload .Xresources? (y/n): " answer
if [ $answer == 'y' ]; then xrdb -merge ~/.Xresources; fi

read -p "Would you like to reload .xprofile? (y/n): " answer
if [ $answer == 'y' ]; then source ~/.xprofile; fi
