#!/bin/sh
# This function requires the source_file function
# This is implemented in the .zshrc file
# function source_file() {
#    [ -f "$1" ] && source "$1"
# }

# ZSH PLUGIN MANAGER
function plugin() {
    local PLUGINS_DIR=${HOME}/.config/zsh-plugins

    if [ "$#" -lt 1 ]; then
        echo "Usage: zsh_plugin [add|update] [plugin_name]"
        return 1
    fi

    local ACTION=$1

    case "$ACTION" in
        "add")
            if [ "$#" -lt 2 ]; then
                echo "Usage: zsh_plugin add plugin_name"
                return 1
            fi
            local PLUGIN_PATH=$2
            local PLUGIN_NAME=$(echo $PLUGIN_PATH | cut -d "/" -f 2)

            if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
                source_file "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
                source_file "$PLUGINS_DIR/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
            else
                git clone "https://github.com/$PLUGIN_PATH.git" "$PLUGINS_DIR/$PLUGIN_NAME"
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
