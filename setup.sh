#!/bin/sh

# This repository is not meant to be used by others.
# It exist as a reference to my dotfiles.


PATH_TO_DOTFILES='/home/akc/develop/dotfiles'
# PATH_TO_DOTFILES='/Users/akc/develop/dotfiles'

if [ -z "$PATH_TO_DOTFILES" ]; then
  echo "PATH_TO_DOTFILES is not set."
  exit 1
fi

# ln -sf $PATH_TO_DOTFILES/ghostty  $HOME/.config/ghostty
ln -sf $PATH_TO_DOTFILES/nvim  $HOME/.config/nvim
# ln -sf $PATH_TO_DOTFILES/zsh  $HOME/.config/zsh
# ln -sf $PATH_TO_DOTFILES/zsh/zshrc $HOME/.zshrc

# bash (plugin manager + plugins not ported)
ln -sf $PATH_TO_DOTFILES/bash/bashrc $HOME/.bashrc
ln -sf $PATH_TO_DOTFILES/bash/bash_profile $HOME/.bash_profile

# bat — config + slate theme; rebuild syntax/theme cache afterwards
ln -sf $PATH_TO_DOTFILES/bat  $HOME/.config/bat
command -v bat >/dev/null 2>&1 && bat cache --build

# zathura — slate dark theme (recolor/dark mode on by default)
ln -sf $PATH_TO_DOTFILES/zathura  $HOME/.config/zathura

# picom — compositor config (vsync to stop screen tearing); X11/i3 only
# ln -sf $PATH_TO_DOTFILES/x11/picom  $HOME/.config/picom

# sway + waybar — Wayland WM and status bar
ln -sfn $PATH_TO_DOTFILES/wayland/sway    $HOME/.config/sway
ln -sfn $PATH_TO_DOTFILES/wayland/waybar  $HOME/.config/waybar

# environment.d — HiDPI/Wayland toolkit hints (Qt/Firefox/Java scaling)
ln -sfn $PATH_TO_DOTFILES/wayland/environment.d  $HOME/.config/environment.d

# fuzzel — fast Wayland launcher / dmenu replacement (slate theme)
ln -sfn $PATH_TO_DOTFILES/wayland/fuzzel  $HOME/.config/fuzzel

# dunst — notification daemon (slate theme, transparent backgrounds)
ln -sfn $PATH_TO_DOTFILES/dunst  $HOME/.config/dunst

# GTK apps: prefer dark to match the slate palette (Firefox is already dark)
command -v gsettings >/dev/null 2>&1 && \
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# GTK3 (Thunar etc.) — slate theme: tint Adwaita via gtk.css + force dark.
# Link individual files so GTK's own bookmarks/servers stay out of the repo.
mkdir -p $HOME/.config/gtk-3.0
ln -sf $PATH_TO_DOTFILES/gtk-3.0/gtk.css      $HOME/.config/gtk-3.0/gtk.css
ln -sf $PATH_TO_DOTFILES/gtk-3.0/settings.ini $HOME/.config/gtk-3.0/settings.ini

# btop — drop the slate theme in place (btop.conf stays btop-managed)
mkdir -p $HOME/.config/btop/themes
ln -sf $PATH_TO_DOTFILES/btop/themes/slate.theme $HOME/.config/btop/themes/slate.theme

# greetd + tuigreet — Wayland-native login manager (replaced lightdm).
# System-level config, needs root; copy manually (don't symlink into /etc):
#   sudo cp $PATH_TO_DOTFILES/wayland/greetd/config.toml /etc/greetd/config.toml
