#!/bin/sh

# This repository is not meant to be used by others.
# It exist as a reference to my dotfiles.


PATH_TO_DOTFILES='/home/akc/develop/dotfiles'
# PATH_TO_DOTFILES='/Users/akc/develop/dotfiles'

if [ -z "$PATH_TO_DOTFILES" ]; then
  echo "PATH_TO_DOTFILES is not set."
  exit 1
fi

ln -sfn $PATH_TO_DOTFILES/ghostty  $HOME/.config/ghostty
ln -sf $PATH_TO_DOTFILES/nvim  $HOME/.config/nvim
# ln -sf $PATH_TO_DOTFILES/zsh  $HOME/.config/zsh
# ln -sf $PATH_TO_DOTFILES/zsh/zshrc $HOME/.zshrc

# bash (plugin manager + plugins not ported)
ln -sf $PATH_TO_DOTFILES/bash/bashrc $HOME/.bashrc
ln -sf $PATH_TO_DOTFILES/bash/bash_profile $HOME/.bash_profile

# kitty — terminal (slate theme)
ln -sfn $PATH_TO_DOTFILES/kitty  $HOME/.config/kitty

# zathura — slate dark theme (recolor/dark mode on by default)
ln -sf $PATH_TO_DOTFILES/zathura  $HOME/.config/zathura

# Hyprland + waybar — Wayland WM and status bar
ln -sfn $PATH_TO_DOTFILES/wayland/hypr    $HOME/.config/hypr
ln -sfn $PATH_TO_DOTFILES/wayland/waybar  $HOME/.config/waybar

# environment.d — HiDPI/Wayland toolkit hints (Qt/Firefox/Java scaling)
ln -sfn $PATH_TO_DOTFILES/wayland/environment.d  $HOME/.config/environment.d

# fuzzel — fast Wayland launcher / dmenu replacement (slate theme)
ln -sfn $PATH_TO_DOTFILES/wayland/fuzzel  $HOME/.config/fuzzel

# dunst — notification daemon (slate theme, transparent backgrounds)
ln -sfn $PATH_TO_DOTFILES/dunst  $HOME/.config/dunst

# wireplumber — stop HDMI audio from becoming default when a monitor connects
ln -sfn $PATH_TO_DOTFILES/wireplumber  $HOME/.config/wireplumber

# GTK apps: prefer dark to match the slate palette (Firefox is already dark)
command -v gsettings >/dev/null 2>&1 && \
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# scripts — personal helpers linked onto PATH via ~/.local/bin
mkdir -p $HOME/.local/bin
for s in $PATH_TO_DOTFILES/scripts/*; do
  [ -f "$s" ] && ln -sf "$s" $HOME/.local/bin/"$(basename "$s")"
done
# .desktop launchers — so scripts show up in the fuzzel (SUPER+D) app picker
mkdir -p $HOME/.local/share/applications
for d in $PATH_TO_DOTFILES/scripts/applications/*.desktop; do
  [ -f "$d" ] && ln -sf "$d" $HOME/.local/share/applications/"$(basename "$d")"
done

# btop — drop the slate theme in place (btop.conf stays btop-managed)
mkdir -p $HOME/.config/btop/themes
ln -sf $PATH_TO_DOTFILES/btop/themes/slate.theme $HOME/.config/btop/themes/slate.theme

# systemd user units — session daemons (bar, applets, wallpaper, clipboard,
# dropbox…) all hang off graphical-session.target; hypr/conf/autostart.lua
# starts hyprland-session.target once the compositor is up. Link individual
# files: systemctl manages its own symlinks (*.wants) in the same directory.
mkdir -p $HOME/.config/systemd/user
for f in hyprland-session.target nm-applet.service polkit-gnome.service cliphist@.service; do
  ln -sf $PATH_TO_DOTFILES/wayland/systemd/$f $HOME/.config/systemd/user/$f
done
for d in blueman-applet.service.d dunst.service.d dropbox.service.d; do
  ln -sfn $PATH_TO_DOTFILES/wayland/systemd/$d $HOME/.config/systemd/user/$d
done
systemctl --user daemon-reload
# units with [Install] sections:
systemctl --user enable waybar hypridle hyprpaper nm-applet polkit-gnome \
  cliphist@text cliphist@image
# shipped units without a usable [Install] (static / default.target):
systemctl --user add-wants graphical-session.target \
  blueman-applet.service dunst.service dropbox.service
# dropbox must NOT also start at login — pre-session it can't see the display:
systemctl --user disable dropbox 2>/dev/null

# Login: no display manager — getty on tty1, bash_profile execs start-hyprland
# after login (see bash/bash_profile). If a greeter is still enabled:
#   sudo systemctl disable greetd.service
