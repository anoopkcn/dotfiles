#!/bin/sh
# TMUX SESSION MANAGEMENT TOOL (TM)
# Author: @anoopkcn
# License: MIT
# Requires fd, fzf, tmux

# Version
VERSION="1.0.0"
AUTHOR="@anoopkcn"
LICENSE="MIT"
# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# To set interactive mode(FZF) as default `export TM_USE_FZF=1`
# Default to direct commands unless TM_USE_FZF is set
: "${TM_USE_FZF:=0}"

# Function to handle the interaction mode selection
use_fzf() {
    local force_mode="$1"

    if [ "$force_mode" = "interactive" ]; then
        return 0
    elif [ "$force_mode" = "direct" ]; then
        return 1
    elif [ "$TM_USE_FZF" = "1" ]; then
        return 0
    fi
    return 1
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
    if [ "$session_name" = "-a" ]; then
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
    elif [ "$1" = "-a" ]; then
        if tmux list-sessions >/dev/null 2>&1; then
            core_kill_session "-a"
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

# FZF interface functions
fzf_create_session() {
    local selected
    if [ -n "$1" ]; then
        selected=$1
    else
        selected=$(fd --type d --max-depth 1 . ~/work/develop ~/Dropbox/projects ~/ ~/work ~/Dropbox | fzf --reverse)
    fi

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

fzf_rename_session() {
    local old_name
    old_name=$(tmux list-sessions -F "#{session_name}" | \
        fzf --reverse --header="Select session to rename" \
            --preview 'tmux list-windows -t {}')

    if [ -n "$old_name" ]; then
        echo -n "Enter new name: "
        read -r new_name
        if [ -n "$new_name" ]; then
            core_rename_session "$old_name" "$new_name"
        fi
    fi
}

fzf_kill_session() {
    local selected
    selected=$(tmux list-sessions -F "#{session_name}" | \
        fzf --reverse --header="Select session to kill" \
            --preview 'tmux list-windows -t {}')

    if [ -n "$selected" ]; then
        core_kill_session "$selected"
    fi
}

fzf_attach_session() {
    local selected
    selected=$(tmux list-sessions -F "#{session_name}" | \
        fzf --reverse --header="Select session to attach" \
            --preview 'tmux list-windows -t {}')

    if [ -n "$selected" ]; then
        core_attach_session "$selected"
    fi
}

fzf_list_sessions() {
    tmux list-sessions | fzf --reverse --header="Sessions" --preview 'tmux list-windows -t {1}'
}

show_help() {
    cat << EOF
Tmux Session Management Tool

Usage: tm [-i|-f] <command> [options]

Global Flags:
  -i    Use interactive (FZF) mode
  -f    Use direct command mode (default)
  -v    Show version
  -V    Show detailed version information

Commands:
  new [session-name]     Create a new tmux session
  attach [name]          Attach to an existing session
  detach [session-name]  Detach from current session or specified session
  list                   List all tmux sessions
  kill [session-name|-a] Kill a specific session or all sessions
  rename <old> <new>     Rename a session
  help                   Show this help message

Environment Variables:
  TM_USE_FZF            Set to 1 to always use FZF mode (can be overridden by flags)
EOF
}

show_version() {
    local verbose="$1"
    if [ "$verbose" = "full" ]; then
        cat << EOF
tmuxtools ${VERSION}
Author: ${AUTHOR}
License: ${LICENSE}
Dependencies: tmux, fzf, fd
Repository: https://github.com/anoopkcn/dotfiles/blob/main/tmux/tmuxtools.sh
EOF
    else
        echo "tmuxtools ${VERSION}"
    fi
}

tm() {
    local mode=""  # Initialize empty mode
    local OPTIND=1

    # Parse global flags
    while getopts "ifvV" opt; do
        case $opt in
            i) mode="interactive" ;;
            f) mode="direct" ;;
            v) show_version; return 0 ;;
            V) show_version "full"; return 0 ;;
            ?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    # Check if tmux is installed
    if ! command -v tmux >/dev/null 2>&1; then
        echo "${YELLOW}Error: tmux is not installed${NC}"
        return 1
    fi

    # Show help if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        return 1
    fi

    local command="$1"
    shift

    case "$command" in
        "new")
            if use_fzf "$mode"; then
                fzf_create_session "$@"
            else
                cmd_create_session "$@"
            fi
            ;;
        "attach")
            if use_fzf "$mode"; then
                fzf_attach_session
            else
                cmd_attach_session "$@"
            fi
            ;;
        "detach")
            cmd_detach_session "$@"
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
                cmd_kill_session "$@"
            fi
            ;;
        "rename")
            if use_fzf "$mode"; then
                fzf_rename_session
            else
                cmd_rename_session "$@"
            fi
            ;;
        "version")
            echo "tm version = ${VERSION}"
            ;;
        *)
            show_help
            ;;
    esac
}
