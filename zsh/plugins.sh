#!/bin/sh
# PLUGIN MANAGER FOR ZSH

_source_plugin() {
    local plugins_dir=$1
    local plugin_name=$2
    local plugin_path="$1/$2"
    local files=(
        "$plugin_path/$plugin_name.plugin.zsh"
        "$plugin_path/$plugin_name.zsh"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            source "$file"
            return 0
        fi
    done
    echo "Warning: No source file found for $plugin_path"
    return 1
}

plugin() {
    local PLUGINS_DIR=${HOME}/.config/zsh-plugins
    # Create plugins directory if it doesn't exist
    mkdir -p "$PLUGINS_DIR"

    if [ "$#" -lt 1 ]; then
        cat << 'EOF'
Usage: plugin <action> [args]

Actions:
    add <gitrepo/plugin_name>  Install a new plugin
    update                     Update all plugins
    list                       Show installed plugins

Examples:
    plugin add zsh-users/zsh-syntax-highlighting
    plugin update
    plugin list
EOF
        return 1
    fi

    local ACTION=$1

    # Validate plugin path format
    if [ "$#" -eq 2 ] && ! echo "$2" | grep -q "^[^/]*/[^/]*$"; then
        echo "Error: Plugin path must be in format 'owner/repo'"
        return 1
    fi

    case "$ACTION" in
        "add")
            if [ "$#" -lt 2 ]; then
                echo "Usage: plugin add [gitrepo/plugin_name]"
                return 1
            fi
            local PLUGIN_REPO=$2
            local PLUGIN_NAME=$(echo $PLUGIN_REPO | cut -d "/" -f 2)

            if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
                _source_plugin $PLUGINS_DIR $PLUGIN_NAME
            else
                git clone "https://github.com/$PLUGIN_REPO.git" "$PLUGINS_DIR/$PLUGIN_NAME" && \
                _source_plugin $PLUGINS_DIR $PLUGIN_NAME
            fi
            ;;
        "update")
            if [ "$#" -eq 1 ]; then
                echo "Updating all ZSH plugins..."
                for plugin_dir in "$PLUGINS_DIR"/*; do
                    if [ -d "$plugin_dir" ]; then
                        (
                            cd "$plugin_dir"
                            local plugin_name=$(basename "$plugin_dir")
                            echo "Updating $plugin_name..."
                            git pull --quiet
                        ) &
                    fi
                done
                wait
                echo "All plugins updated"
            fi
            ;;
        "list")
            echo "Installed ZSH plugins:"
            if [ -d "$PLUGINS_DIR" ]; then
                for plugin_dir in "$PLUGINS_DIR"/*; do
                    if [ -d "$plugin_dir" ]; then
                        local plugin_name=$(basename "$plugin_dir")
                        echo "- $plugin_name"
                    fi
                done
            else
                echo "No plugins installed"
            fi
            ;;
        *)
            echo "Invalid action. Use 'add', 'list' or 'update'"
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
--bind up:preview-up,down:preview-down
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
