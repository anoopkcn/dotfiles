#!/bin/bash

#Installation file for bash, vim, tmux, etc..
#(Optional)install Ag using `brew install the_silver_searcher`

ln -sf ~/.dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/.dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/.dotfiles/bash/inputrc ~/.inputrc

ln -sf ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/tmux/dottmux ~/.tmux

ln -sf ~/.dotfiles/vim~/.conf/nvim

ln -sf ~/.dotfiles/pip ~/.pip
# ln -sf ~/.dotfiles/ssh/config ~/.ssh/config

