# Install packages using yay (change to pacman/AUR helper of your choice)
yayinstall() {
  yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}' | xargs -ro yay -S
}
# Remove installed packages (change to pacman/AUR helper of your choice)
yayremove() {
  yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns
}

# Install packages using yay (change to pacman/AUR helper of your choice)
pacinstall() {
  pacman -Slq | fzf -q "$1" -m --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S
}
# Remove installed packages (change to pacman/AUR helper of your choice)
pacremove() {
  pacman -Qq | fzf -q "$1" -m --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns
}
