#!/bin/bash

# Installation file for bash, vim, tmux, etc..
# (Optional)install Ag using `brew install the_silver_searcher`
# tmux is configured using reattach-usernamespace (install using brew)

ln -sf ~/Dropbox/dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/Dropbox/dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/Dropbox/Dotfiles/bash/inputrc ~/.inputrc
ln -sf ~/Dropbox/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/Dropbox/dotfiles/bash/lazy ~/.bash_it/themes/lazy
ln -sf /Users/lazy/Dropbox/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf /Users/lazy/Dropbox/dotfiles/tmux/tmuxinator ~/.tmuxinator
#ln -sf /Users/lazy/Dropbox/dotfiles/vim ~/.config/nvim
ln -sf /Users/lazy/Dropbox/dotfiles/vimrc ~/.vimrc
