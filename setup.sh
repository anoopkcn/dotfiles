#!/bin/sh

# This repository is not meant to be used by others.
# It exist as a reference to my dotfiles.


PATH_TO_DOTFILES=''

if [ -z "$PATH_TO_DOTFILES" ]; then
  echo "PATH_TO_DOTFILES is not set."
  exit 1
fi

# PATH_TO_DOTFILES=$HOME/Dropbox/dotfiles

# ln -sf $PATH_TO_DOTFILES/tmux  $HOME/.config/tmux
# ln -sf $PATH_TO_DOTFILES/zed  $HOME/.config/zed
ln -sf $PATH_TO_DOTFILES/ghostty  $HOME/.config/ghostty
ln -sf $PATH_TO_DOTFILES/nvim  $HOME/.config/nvim
ln -sf $PATH_TO_DOTFILES/zsh  $HOME/.config/zsh
ln -sf $PATH_TO_DOTFILES/zsh/zshrc $HOME/.zshrc
source $HOME/.zshrc
