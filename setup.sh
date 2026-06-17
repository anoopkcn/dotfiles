#!/bin/sh

# This repository is not meant to be used by others.
# It exist as a reference to my dotfiles.


PATH_TO_DOTFILES='/Users/akc/develop/dotfiles'

if [ -z "$PATH_TO_DOTFILES" ]; then
  echo "PATH_TO_DOTFILES is not set."
  exit 1
fi

ln -sf $PATH_TO_DOTFILES/ghostty  $HOME/.config/ghostty
ln -sf $PATH_TO_DOTFILES/nvim  $HOME/.config/nvim
ln -sf $PATH_TO_DOTFILES/zsh  $HOME/.config/zsh
ln -sf $PATH_TO_DOTFILES/zsh/zshrc $HOME/.zshrc

# bat — config + slate theme; rebuild syntax/theme cache afterwards
ln -sf $PATH_TO_DOTFILES/bat  $HOME/.config/bat
command -v bat >/dev/null 2>&1 && bat cache --build

# btop — drop the slate theme in place (btop.conf stays btop-managed)
mkdir -p $HOME/.config/btop/themes
ln -sf $PATH_TO_DOTFILES/btop/themes/slate.theme $HOME/.config/btop/themes/slate.theme
