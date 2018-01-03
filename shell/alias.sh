#!/usr/bin/env bash
alias ..='cd ..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -lhF'
alias c='clear'
alias p='pwd'

#application links
alias vi='nvim -u NONE'
alias vim='nvim'
alias chrome='open -a Google\ Chrome'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'
# alias tls="tmux ls" #moved to tmux_finctions.sh

#git
alias gs='git status -s'

#other
alias duh="du -h -d 0 [^.]*"
alias js="bundle exec jekyll serve"

#jupyter
alias jn='jupyter notebook'

#task 
alias t='task'
alias calc='task calc'
alias in='task add +in'
alias tick='tickle'
alias think='tickle +1d'