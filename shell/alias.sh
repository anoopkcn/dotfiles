#!/usr/bin/env bash
alias ll='ls -al'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'

#other
alias vim='nvim'
alias workon='conda activate'
alias workoff='conda deactivate'
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# if [[ -d ${HOME}/.homebrew/Cellar/gcc/8.2.0/bin ]]; then
#   alias gcc='gcc-8'
#   alias cc='gcc-8'
#   alias g++='g++-8'
#   alias c++='c++-8'
#   alias gfortran='gfortran-8'
# fi

#Aiida
alias vl='verdi process list'
# alias diff="eval subl --command \'sbs_compare_files {\"A\":\"$1\", \"B\":\"$2\"}\'"
