#!/bin/bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -alF'
alias ll='ls -l'
alias c='clear'
#application links
alias vi='nvim -u NONE'
alias vim='nvim'
alias inkimg='/Applications/Inkscape.app/Contents/Resources/script'
alias chrome='open -a Google\ Chrome'

# tmux alias
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias tkill='tmux kill-session -t'
alias ts='tmuxinator start'

#git
alias gs='git status'
alias gn='git next'
alias gp='git prev'

#other
alias duh="du -h -d 0 [^.]*"

