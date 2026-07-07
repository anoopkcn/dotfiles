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

# bash (plugin manager + plugins not ported)
ln -sf $PATH_TO_DOTFILES/bash/bashrc $HOME/.bashrc
ln -sf $PATH_TO_DOTFILES/bash/bash_profile $HOME/.bash_profile

# bat — config + slate theme; rebuild syntax/theme cache afterwards
ln -sf $PATH_TO_DOTFILES/bat  $HOME/.config/bat
command -v bat >/dev/null 2>&1 && bat cache --build

# zathura — slate dark theme (recolor/dark mode on by default)
ln -sf $PATH_TO_DOTFILES/zathura  $HOME/.config/zathura

# picom — compositor config (vsync to stop screen tearing); X11/i3 only
ln -sf $PATH_TO_DOTFILES/picom  $HOME/.config/picom

# sway + waybar — Wayland WM and status bar
ln -sfn $PATH_TO_DOTFILES/sway    $HOME/.config/sway
ln -sfn $PATH_TO_DOTFILES/waybar  $HOME/.config/waybar

# environment.d — HiDPI/Wayland toolkit hints (Qt/Firefox/Java scaling)
ln -sfn $PATH_TO_DOTFILES/environment.d  $HOME/.config/environment.d

# fuzzel — fast Wayland launcher / dmenu replacement (slate theme)
ln -sfn $PATH_TO_DOTFILES/fuzzel  $HOME/.config/fuzzel

# btop — drop the slate theme in place (btop.conf stays btop-managed)
mkdir -p $HOME/.config/btop/themes
ln -sf $PATH_TO_DOTFILES/btop/themes/slate.theme $HOME/.config/btop/themes/slate.theme
