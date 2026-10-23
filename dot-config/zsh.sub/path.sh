# feature commands are linked into ~/.local/bin (see ~/dotfiles/features/*/bin)
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
