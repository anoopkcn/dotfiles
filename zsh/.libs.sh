# support libraries and links for zsh

NODE_PATH="$HOME/.node/lib/node_modules:$NODE_PATH"
MANPATH="/usr/local/man:$HOME/.node/share/man:$MANPATH"
export PATH="/Library/TeX/texbin/:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/akc/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/akc/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/akc/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/akc/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ZSH plugins
if [ -f "/Users/akc/.config/zsh-plugins/znap/znap.zsh" ]; then
    source /Users/akc/.config/zsh-plugins/znap/znap.zsh
    znap source zdharma-continuum/fast-syntax-highlighting
    znap source zshzoo/macos
    znap source zsh-users/zsh-autosuggestions
    bindkey '^y' autosuggest-accept
fi

if [ -x "$(command -v zoxide)" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

if [ -x "$(command -v starship)" ]; then
    eval "$(starship init zsh)"
fi

