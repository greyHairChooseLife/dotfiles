FROM archlinux:latest

# Update and install packages
RUN pacman -Syu --noconfirm && \
  pacman -S --noconfirm \
  base-devel \
  git \
  zsh \
  neovim \
  tmux \
  fzf \
  rsync \
  openssh \
  curl \
  wget \
  unzip \
  ripgrep \
  fd \
  bat \
  htop \
  man-db \
  jq \
  yq \
  lsd \
  xclip \
  && pacman -Scc --noconfirm

# Create user (same UID as host for volume permissions)
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID devuser && \
  useradd -m -u $UID -g $GID -s /bin/zsh devuser && \
  echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh plugins
RUN git clone --depth=1 https://github.com/Aloxaf/fzf-tab \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab && \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Create config directories
RUN mkdir -p ~/.config ~/.config/tmux ~/.local/bin ~/.local/state/zsh.sub \
    ~/.local/bin/tmux/plugins ~/.local/share/tmux/resurrect

# Install Portal (file transfer tool)
RUN curl -sL https://github.com/SpatiumPortae/portal/releases/download/v1.2.3/portal_1.2.3_Linux_x86_64.tar.gz | tar xz -C ~/.local/bin portal

# Default command
CMD ["zsh"]
