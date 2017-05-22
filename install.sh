#!/bin/bash

# Installation file for bash, vim, tmux, etc..
# (Optional)install Ag using `brew install the_silver_searcher`
# tmux is configured using reattach-usernamespace (install using brew)

ln -sf ~/Dropbox/Dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/Dropbox/Dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/Dropbox/Dotfiles/bash/inputrc ~/.inputrc

ln -sf ~/Dropbox/Dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/Dropbox/Dotfiles/tmux/tmuxinator ~/.tmuxinator

ln -sf ~/Dropbox/Dotfiles/python/pip ~/.pip
ln -sf ~/Dropbox/Dotfiles/git/gitconfig ~/.gitconfig

ln -sf ~/Dropbox/Dotfiles/vim/init.vim ~/.vimrc
ln -sf ~/Dropbox/Dotfiles/vim ~/.vim
