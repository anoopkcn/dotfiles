#!/usr/bin/env bash
alias ..='cd ..'
alias ls='ls -F'
alias l='ls -lhF'
alias c='clear'
alias p='pwd'
alias hls='h5ls'

# git alias
alias gits='git status'
alias gita='git add'
alias gitc='git commit'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'

#other
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"

#jupyter
alias jn='jupyter-notebook'

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
if [[ -d ${HOME}/.homebrew/Cellar/gcc/8.2.0/bin ]]; then
  alias gcc='gcc-8'
  alias cc='gcc-8'
  alias g++='g++-8'
  alias c++='c++-8'
  alias gfortran='gfortran-8'
fi
