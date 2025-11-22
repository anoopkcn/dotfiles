#!/usr/bin/env bash
# PLUGIN MANAGER FOR ZSH

_source_plugin() {
    local plugin_name="$2"
    local plugin_path="$1/$2"

    if [ -f "$plugin_path/$plugin_name.plugin.zsh" ]; then
        source "$plugin_path/$plugin_name.plugin.zsh"
        return 0
    fi
    if [ -f "$plugin_path/$plugin_name.zsh" ]; then
        source "$plugin_path/$plugin_name.zsh"
        return 0
    fi

    echo "Warning: No source file found for $plugin_path"
    return 1
}

plugin() {
    local PLUGINS_DIR
    local PLUGIN_REPO
    local PLUGIN_NAME
    local plugin_base_name

    setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

    PLUGINS_DIR=${HOME}/.config/zsh-plugins
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

    local ACTION="$1"

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
            PLUGIN_REPO="$2"
            PLUGIN_NAME=$(echo "$PLUGIN_REPO" | cut -d "/" -f 2)

            if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
                _source_plugin "$PLUGINS_DIR" "$PLUGIN_NAME"
            else
                git clone "https://github.com/$PLUGIN_REPO.git" "$PLUGINS_DIR/$PLUGIN_NAME" && \
                _source_plugin "$PLUGINS_DIR" "$PLUGIN_NAME"
            fi
            ;;
        "update")
            if [ "$#" -eq 1 ]; then
                echo "Updating all ZSH plugins..."
                for plugin_dir in "$PLUGINS_DIR"/*; do
                    if [ -d "$plugin_dir" ]; then
                        (
                            cd "$plugin_dir" || return
                            plugin_base_name=$(basename "$plugin_dir")
                            echo "Updating $plugin_base_name..."
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
                        plugin_base_name=$(basename "$plugin_dir")
                        echo "- $plugin_base_name"
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
