#!/bin/sh
# TMUX SESSION MANAGEMENT TOOL (TS)
# Author: @anoopkcn
# License: MIT
# Requires fd, fzf, tmux

# Version
NAME="TS"
VERSION="1.0.0"
AUTHOR="@anoopkcn"
LICENSE="MIT"
# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Colors for FZF preview
FZF_SESSION_COLOR='\033[1;36m'    # Bright Cyan
FZF_SEPARATOR_COLOR='\033[1;34m'   # Bright Blue
FZF_WINDOW_COLOR='\033[0;32m'      # Green
FZF_TREE_COLOR='\033[0;34m'        # Blue
FZF_PANE_COLOR='\033[0;33m'        # Yellow
FZF_ACTIVE_COLOR='\033[1;32m'      # Bright Green

# To set interactive mode(FZF) as default `export TM_USE_FZF=1`
# Default to direct commands unless TM_USE_FZF is set
: "${TM_USE_FZF:=0}"

# Function to handle the interaction mode selection
use_fzf() {
    local direct_mode="$1"

    if [ "$direct_mode" = "interactive" ]; then
        return 0
    elif [ "$direct_mode" = "direct" ]; then
        return 1
    elif [ "$TM_USE_FZF" = "1" ]; then
        return 0
    fi
    return 1
}

check_active_sessions() {
    if ! tmux list-sessions >/dev/null 2>&1; then
        echo "${GREEN}No active tmux sessions${NC}"
        return 1
    fi
    return 0
}

# Core functions that contain the main logic
core_create_session() {
    local session_name="$1"
    local new_session_name

    if [ -z "$session_name" ]; then
        new_session_name=$(basename "$(pwd)" | tr '.' '-')

        if tmux has-session -t "$new_session_name" 2>/dev/null; then
            local i=1
            while tmux has-session -t "$new_session_name-$i" 2>/dev/null; do
                i=$((i + 1))
            done
            new_session_name="$new_session_name-$i"
        fi

        echo "${GREEN}Using default session name: $new_session_name${NC}"
    else
        new_session_name="$session_name"
    fi

    if [ -n "$TMUX" ]; then
        tmux new-session -d -s "$new_session_name"
        tmux switch-client -t "$new_session_name"
    else
        tmux new-session -A -s "$new_session_name"
    fi
}

core_rename_session() {
    local old_name="$1"
    local new_name="$2"
    tmux rename-session -t "$old_name" "$new_name"
    echo "${BLUE}Renamed session '$old_name' to '$new_name'${NC}"
}

core_kill_session() {
    local session_name="$1"
    if [ "$session_name" = "KILL-ALL-SESSIONS" ]; then
        tmux kill-server
        echo "${BLUE}Killed all tmux sessions${NC}"
    else
        tmux kill-session -t "$session_name"
        echo "${BLUE}Killed session: $session_name${NC}"
    fi
}

core_attach_session() {
    local session_name="$1"
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session_name"
        echo "${BLUE}Switched to session: $session_name${NC}"
    else
        tmux attach-session -t "$session_name"
    fi
}

core_detach_session() {
    local session_name="$1"
    if [ -z "$session_name" ]; then
        tmux detach-client
        echo "${BLUE}Detached from current session${NC}"
    else
        tmux detach-client -s "$session_name"
        echo "${BLUE}Detached all clients from session: $session_name${NC}"
    fi
}

# Command line interface functions
cmd_create_session() {
    core_create_session "$1"
}

cmd_rename_session() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "${YELLOW}Error: Both old and new session names required${NC}"
        return 1
    fi

    if tmux has-session -t "$1" 2>/dev/null; then
        core_rename_session "$1" "$2"
    else
        echo "${YELLOW}Session '$1' does not exist${NC}"
        return 1
    fi
}

cmd_kill_session() {
    if [ -z "$1" ]; then
        if tmux list-sessions >/dev/null 2>&1; then
            tmux kill-session
            echo "${BLUE}Killed active session${NC}"
        else
            echo "${YELLOW}No active tmux sessions to kill${NC}"
        fi
    else
        if tmux has-session -t "$1" 2>/dev/null; then
            core_kill_session "$1"
        else
            echo "${YELLOW}Session '$1' does not exist${NC}"
            return 1
        fi
    fi
}

cmd_attach_session() {
    if [ -z "$1" ]; then
        echo "${YELLOW}Error: Session name required${NC}"
        return 1
    fi

    if tmux has-session -t "$1" 2>/dev/null; then
        core_attach_session "$1"
    else
        echo "${YELLOW}Session '$1' does not exist${NC}"
        return 1
    fi
}

cmd_detach_session() {
    if [ -z "$1" ]; then
        if [ -n "$TMUX" ]; then
            core_detach_session
        else
            echo "${YELLOW}Error: Not currently in a tmux session${NC}"
            return 1
        fi
    else
        if tmux has-session -t "$1" 2>/dev/null; then
            local clients=$(tmux list-clients -t "$1" 2>/dev/null)
            if [ -n "$clients" ]; then
                core_detach_session "$1"
            else
                echo "${GREEN}No clients attached to session: $1${NC}"
            fi
        else
            echo "${YELLOW}Session '$1' does not exist${NC}"
            return 1
        fi
    fi
}

cmd_list_sessions() {
    if tmux list-sessions 2>/dev/null; then
        :
    else
        echo "${GREEN}No active tmux sessions${NC}"
    fi
}


# FZF FUNCTIONS

fzf_generate_session_tree() {
    echo 'echo "Session: {1}"; \
          tmux list-windows -t {1} -F "Window #{window_index}: #{window_name}" | while read -r window; do \
              echo "├─ $window"; \
              window_num=$(echo "$window" | cut -d: -f1 | cut -d" " -f2); \
              tmux list-panes -t {1}:$window_num -F "│  ├─ Pane #{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height}) #{?pane_active,(active),}"; \
          done;'
}

fzf_select_session() {
    local header="$1"
    shift
    tmux list-sessions -F "#{session_name}" | \
        fzf "$@" --header="$header" \
        --preview "$(fzf_generate_session_tree)"
}

fzf_create_session() {
    local selected
    selected=$(fd --type d --max-depth 1 . ~/work/develop ~/Dropbox/projects ~/ ~/work ~/Dropbox | \
        fzf "$@" --header="Select directory for new session")

    if [ -z "$selected" ]; then
        return 0
    fi

    local selected_name=$(basename "$selected" | tr . _)

    if ! tmux has-session -t="$selected_name" 2> /dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$selected_name"
    else
        tmux attach-session -t "$selected_name"
    fi
}

fzf_kill_session() {
    check_active_sessions || return 1
    local selected
    local RED='\033[0;31m'
    local NC='\033[0m'
    # Add option to kill all sessions
    selected=$(printf "$(tmux list-sessions -F '#{session_name}')\n${RED}kill-all${NC}" | \
        fzf --ansi --header="$(printf "Select session to kill (or 'kill-all' sessions)")" "$@")

    if [ -n "$selected" ]; then
        if [ "$selected" = "kill-all" ]; then
            core_kill_session "KILL-ALL-SESSIONS"
        else
            core_kill_session "$selected"
        fi
    fi
}

fzf_list_sessions() {
    check_active_sessions || return 1
    fzf_select_session "All available sessions" "$@"
}

fzf_attach_session() {
    check_active_sessions || return 1
    local selected
    selected=$(fzf_select_session "Select session to attach" "$@")

    if [ -n "$selected" ]; then
        core_attach_session "$selected"
    fi
}

fzf_rename_session() {
    check_active_sessions || return 1
    local old_name
    old_name=$(fzf_select_session "Select session to rename" "$@")

    if [ -n "$old_name" ]; then
        echo -n "Enter new name: "
        read -r new_name
        if [ -n "$new_name" ]; then
            core_rename_session "$old_name" "$new_name"
        fi
    fi
}

show_help() {
    cat << EOF
Tmux Session Management Tool (TS)

Usage: ts [options]

Mode Options:
  -i, --interactive     Use interactive (FZF) mode
  -f, --direct          Use direct command mode (default)

Operation Options:
  -n, --new [name]     Create a new tmux session
  -a, --attach [name]  Attach to an existing session
  -d, --detach [name]  Detach from current session or specified session
  -l, --list          List all tmux sessions
  -k, --kill [name]   Kill a specific session
  -r, --rename <old> <new>  Rename a session

Other Options:
  -h, --help          Show this help message
  -v, --version       Show version information

Environment Variables:
  TM_USE_FZF         Set to 1 to always use FZF mode (can be overridden by flags)

Examples:
  ts -n              Create new session with default name
  ts -n mysession    Create new session named 'mysession'
  ts -l              List all sessions
  ts -k mysession    Kill session "mysession"
  ts -r old new      Rename session 'old' to 'new'
EOF
}

show_version() {
    local verbose="$1"
    if [ "$verbose" = "full" ]; then
        cat << EOF
${NAME} ${VERSION}

Version
  - version: ${VERSION}
  - license: ${LICENSE}
Configuration
  - Dependencies: tmux, fzf(optional), fd(optional)
  - Repository: https://github.com/anoopkcn/dotfiles/blob/main/tmux/tmuxtools.sh
EOF
    else
        echo "${VERSION}"
    fi
}

# Main function to parse arguments and call appropriate functions
ts() {
    local mode=""
    local operation=""

    # Show help if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        return 1
    fi

    # Check if tmux is installed
    if ! command -v tmux >/dev/null 2>&1; then
        echo "${YELLOW}Error: tmux is not installed${NC}"
        return 1
    fi

    # Function to handle operation conflicts
    check_operation() {
        if [ -n "$operation" ]; then
            echo "${YELLOW}Error: Cannot combine operation flags. Use only one of: -n, -a, -d, -l, -k, -r${NC}"
            return 1
        fi
        return 0
    }

    # Function to execute operation
    execute_operation() {
        local op=$1
        local arg1=$2
        local arg2=$3

        case "$op" in
            "new")
                if use_fzf "$mode"; then
                    fzf_create_session
                else
                    cmd_create_session "$arg1"
                fi
                ;;
            "attach")
                if use_fzf "$mode"; then
                    fzf_attach_session
                else
                    cmd_attach_session "$arg1"
                fi
                ;;
            "detach")
                cmd_detach_session "$arg1"
                ;;
            "list")
                if use_fzf "$mode"; then
                    fzf_list_sessions
                else
                    cmd_list_sessions
                fi
                ;;
            "kill")
                if use_fzf "$mode"; then
                    fzf_kill_session
                else
                    cmd_kill_session "$arg1"
                fi
                ;;
            "rename")
                if use_fzf "$mode"; then
                    fzf_rename_session
                else
                    if [ -z "$arg1" ] || [ -z "$arg2" ]; then
                        echo "${YELLOW}Error: Both old and new session names required${NC}"
                        return 1
                    fi
                    cmd_rename_session "$arg1" "$arg2"
                fi
                ;;
        esac
    }

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            # Mode flags
            -i|--interactive)
                mode="interactive"
                shift
                ;;
            -f|--direct)
                mode="direct"
                shift
                ;;
            # Operation flags
            -n|--new)
                check_operation || return 1
                operation="new"
                execute_operation "new" "${2:-}"
                shift
                if [ -n "$2" ]; then shift; fi
                ;;
            -a|--attach)
                check_operation || return 1
                operation="attach"
                execute_operation "attach" "${2:-}"
                shift
                if [ -n "$2" ]; then shift; fi
                ;;
            -d|--detach)
                check_operation || return 1
                operation="detach"
                execute_operation "detach" "${2:-}"
                shift
                if [ -n "$2" ]; then shift; fi
                ;;
            -l|--list)
                check_operation || return 1
                operation="list"
                execute_operation "list"
                shift
                ;;
            -k|--kill)
                check_operation || return 1
                operation="kill"
                execute_operation "kill" "${2:-}"
                shift
                if [ -n "$2" ]; then shift; fi
                ;;
            -r|--rename)
                check_operation || return 1
                operation="rename"
                execute_operation "rename" "$2" "$3"
                shift
                if [ -n "$2" ]; then shift; fi
                if [ -n "$2" ]; then shift; fi
                ;;
            # Other flags
            -v|--version)
                show_version "full"
                return 0
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                return 1
                ;;
        esac
    done
}
