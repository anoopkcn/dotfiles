export LANG=en_US.UTF-8
export LC_ALL=en_GB.UTF-8
export TERM="xterm-256color"
export EDITOR='vim'

source ${HOME}/.config/zsh/utils.sh
source ${HOME}/.config/zsh/libs.sh
source ${HOME}/.env.zsh
export NOTES="/Users/akc/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"

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
alias ts='tmux new-session -A -s'
alias tls="tmux list-sessions"
alias vim='nvim'
alias duh="du -h -d 0 [^.]*"
alias sync="rsync --archive --itemize-changes --recursive --compress --verbose --checksum --exclude-from=${HOME}/.config/zsh/rsync-local-ignore --prune-empty-dirs"
alias explain="gh copilot explain"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

fpath+=~/.zfunc
# autoload -Uz compinit && compinit
# Created by `pipx` on 2024-07-26 00:10:46
export PATH="$PATH:/Users/akc/.local/bin"

#This makes Tab and ShiftTab, when pressed on the command line, cycle through listed completions, without changing what's listed in the menu:
bindkey              '^I'         menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete
