#!/bin/sh
# PLUGIN MANAGER FOR ZSH

_check_and_source(){
    [ -f "$1" ] && source "$1"
}

plugin() {
    local PLUGINS_DIR=${HOME}/.config/zsh-plugins

    if [ "$#" -lt 1 ]; then
        echo "Usage: plugin [add|update] [gitrepo/plugin_name]"
        return 1
    fi

    local ACTION=$1

    case "$ACTION" in
        "add")
            if [ "$#" -lt 2 ]; then
                echo "Usage: plugin add [gitrepo/plugin_name]"
                return 1
            fi
            local PLUGIN_PATH=$2
            local PLUGIN_NAME=$(echo $PLUGIN_PATH | cut -d "/" -f 2)

            if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
                _check_and_source "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
                _check_and_source "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
            else
                git clone "https://github.com/$PLUGIN_PATH.git" "$PLUGINS_DIR/$PLUGIN_NAME" && \
                _check_and_source "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
                _check_and_source "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
            fi
            ;;
        "update")
            if [ "$#" -eq 1 ]; then
                # Update all plugins
                echo "Updating all ZSH plugins..."
                for plugin_dir in "$PLUGINS_DIR"/*; do
                    if [ -d "$plugin_dir" ]; then
                        local plugin_name=$(basename "$plugin_dir")
                        echo "Updating plugin $plugin_name..."
                        cd "$plugin_dir"
                        git pull
                        cd - > /dev/null
                    fi
                done
            else
                # Update specific plugin
                local PLUGIN_PATH=$2
                local PLUGIN_NAME=$(echo $PLUGIN_PATH | cut -d "/" -f 2)
                if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
                    echo "Updating plugin $PLUGIN_NAME..."
                    cd "$PLUGINS_DIR/$PLUGIN_NAME"
                    git pull
                    cd - > /dev/null
                else
                    echo "Plugin $PLUGIN_NAME doesn't exist. Use 'add' to install it first."
                fi
            fi
            ;;
        *)
            echo "Invalid action. Use 'add' or 'update'"
            return 1
            ;;
    esac
}

# TOOLS
source <(brew shellenv)
source <(fzf --zsh)
source <(zoxide init --cmd cd zsh)

export BAT_THEME="one_dark"

export FZF_DEFAULT_OPTS='
--scrollbar=""
--info="right"
--height 50%
--layout reverse
--border rounded
--prompt="❯ "
--marker="+"
--color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#282c34,pointer:#3c8494,prompt:#afaf87
'
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude .git . "$1"
}

_fzf_comprun(){
  local cmd="$1"
  shift
  case "$cmd" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig +nocmd {}' "$@";;
    *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

# PLUGINS
plugin add "zshzoo/macos"
plugin add "zsh-users/zsh-syntax-highlighting"
plugin add "zsh-users/zsh-autosuggestions"
plugin add "zsh-users/zsh-completions"

# plugin settings
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
