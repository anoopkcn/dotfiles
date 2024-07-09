export LANG=en_US.UTF-8
export LC_ALL=en_GB.UTF-8
export TERM="xterm-256color"
export EDITOR='vim'

source ${HOME}/.utils.sh
source ${HOME}/.libs.sh

if ! [ $ZSH_VERSION ]; then
  bind TAB:menu-complete
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
fi
bindkey '^[^M' self-insert-unmeta

alias ls='exa'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tsend='tmux send -t'
alias ts='tmuxinator start'
alias vim='nvim'
alias duh="du -h -d 0 [^.]*"
alias sync="rsync -airzvc --exclude-from=${HOME}/.rsync-local-ignore --prune-empty-dirs"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
