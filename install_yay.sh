# Install dependencies
sudo pacman -S --needed git base-devel

# Clone yay-bin repository
git clone https://aur.archlinux.org/yay-bin.git

# Build and install yay
cd yay-bin
makepkg -si

# Remove the build directory after installation
cd ..
rm -rf yay-bin
