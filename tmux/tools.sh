#!/bin/sh
# TMUX SESSION MANAGEMENT TOOL (tmuxctl)
# Author: @anoopkcn
# License: MIT
# Requires fzf, tmux

VERSION="1.2.4"
LICENSE="MIT"

TS_SEARCH_DIRS=(
    "$HOME"
    "$HOME/work"
    "$HOME/work/develop"
    "$HOME/Dropbox"
    "$HOME/Dropbox/projects"
)

# Color definitions
if [ -t 1 ]; then
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    RED=$(tput setaf 1)
    BOLD=$(tput bold)
    NC=$(tput sgr0)
else
    GREEN=""
    YELLOW=""
    BLUE=""
    RED=""
    BOLD=""
    NC=""
fi

# UTILITY FUNCTIONS
show_help() {
    cat << EOF
${BOLD}Tmux Session Management Tool (tmuxctl) ${VERSION}${NC}

${BOLD}USAGE:${NC}
    tmuxctl [options] <command> [arguments]

${BOLD}OPTIONS:${NC}
    -i, --interactive           Use interactive mode with fuzzy finder
    -h, --help                  Show this help message
    -v, --version               Show version information

${BOLD}COMMANDS:${NC}
    new, n [name|dir]           Create a new session
    attach, a [name]            Attach to an existing session
    detach, d [name]            Detach from current or specified session
    kill, k [name]              Kill specified session
    list, l                     List all sessions
    rename, r <old> <new>       Rename a session

${BOLD}EXAMPLES:${NC}
    tmuxctl new mysession       Create new session named 'mysession'
    tmuxctl new                 Create session with pwd name
    tmuxctl attach mysession    Attach to session 'mysession'
    tmuxctl kill mysession      Kill session 'mysession'
    tmuxctl rename old new      Rename session 'old' to 'new'

    # Interactive
    tmuxctl -i new              Create session by selecting directory
    tmuxctl -i attach           Select session to attach
    tmuxctl -i kill             Select session(s) to kill
    tmuxctl -i rename           Select session to rename

${BOLD}NOTES:${NC}
    - Interactive mode (-i) requires fzf to be installed
    - For more visit: https://github.com/anoopkcn/dotfiles
EOF
}

error_msg() {
    echo "${YELLOW}Error: $1${NC}" >&2
    return 1
}

session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

validate_session_name() {
    [[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]] || error_msg "Invalid session name. Use alphanumeric characters, underscore or hyphen"
}

check_active_sessions() {
    if ! tmux list-sessions >/dev/null 2>&1; then
        echo "${GREEN}No active tmux sessions${NC}"
        return 1
    fi
    return 0
}
session_selector() {
    tmux list-sessions -F "#{session_name}"
}

directory_selector() {
    find . "${TS_SEARCH_DIRS[@]}" -mindepth 1 -maxdepth 1 -type d
}

window_selector() {
    local session="$1"
    tmux list-windows -t "$session" -F "#{window_index}: #{window_name}"
}

fzf_session_selector() {
    session_selector |  fzf --exit-0 --preview "${FZF_PREVIEW_FORMAT}" "$@"
}

fzf_directory_selector() {
    directory_selector | \
        fzf --exit-0 --preview "ls --color=always {}" \
        --border-label="( ${BOLD}${GREEN}SELECT DIRECTORY${NC} )" "$@"
}

read -r -d '' FZF_PREVIEW_FORMAT << EOF
echo "Session: ${BLUE}\$(echo {1} | tr -d "'")${NC}"
tmux list-windows -t {1} -F "Window #{window_index}: #{?window_active,${GREEN}#{window_name}${NC},#{window_name}}" | while read -r window; do
    echo "├── \$window"
    window_num=\$(echo "\$window" | cut -d: -f1 | cut -d" " -f2)
    tmux list-panes -t {1}:\$window_num -F "│   ├── Pane #{pane_index}: #{?pane_active,#{pane_current_command}*,#{pane_current_command}} [#{pane_width}x#{pane_height}]"
done
EOF

# BASE FUNCTIONS
create_session() {
    local session_name="$1"
    local directory

    if [ -d "$session_name" ]; then
        directory="$session_name"
        session_name=$(basename "$directory" | tr '.' '-')
    else
        directory="${2:-$(pwd)}"
    fi

    if [ ! -d "$directory" ]; then
        error_msg "Directory does not exist: $directory"
        return 1
    fi

    local new_session_name

    if [ -z "$session_name" ]; then
        new_session_name=$(basename "$directory" | tr '.' '-')
        if session_exists "$new_session_name"; then
            local i=1
            while session_exists "$new_session_name-$i"; do
                i=$((i + 1))
            done
            new_session_name="$new_session_name-$i"
        fi
        echo "${GREEN}Using default session name: $new_session_name${NC}"
    else
        new_session_name="$session_name"
        validate_session_name "$new_session_name"
    fi

    if [ -n "$TMUX" ]; then
        tmux new-session -d -s "$new_session_name" -c "$directory"
        tmux switch-client -t "$new_session_name"
    else
        tmux new-session -A -s "$new_session_name" -c "$directory"
    fi
}

attach_session() {
    local session_name="$1"
    [ -z "$session_name" ] && error_msg "Session name required" && return 1

    if session_exists "$session_name"; then
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "$session_name"
            echo "${BLUE}Switched to session: $session_name${NC}"
        else
            tmux attach-session -t "$session_name"
        fi
    else
        error_msg "Session '$session_name' does not exist"
        return 1
    fi
}

detach_session() {
    local session_name="$1"
    if [ -z "$session_name" ]; then
        tmux detach-client
        echo "${BLUE}Detached from current session${NC}"
    else
        if session_exists "$session_name"; then
            tmux detach-client -s "$session_name"
            echo "${BLUE}Detached all clients from session: $session_name${NC}"
        else
            error_msg "Session '$session_name' does not exist"
            return 1
        fi
    fi
}

kill_session() {
    local session_name="$1"

    if [ -z "$session_name" ]; then
        if tmux list-sessions >/dev/null 2>&1; then
            tmux kill-session
            echo "${BLUE}Killed active session${NC}"
        else
            error_msg "No active tmux sessions to kill"
        fi
    else
        if session_exists "$session_name"; then
            tmux kill-session -t "$session_name"
            echo "${BLUE}Killed session: $session_name${NC}"
        else
            error_msg "Session '$session_name' does not exist"
            return 1
        fi
    fi
}

rename_session() {
    local old_name="$1"
    local new_name="$2"

    [ -z "$old_name" ] && error_msg "Old session name required" && return 1
    [ -z "$new_name" ] && error_msg "New session name required" && return 1

    if session_exists "$old_name"; then
        validate_session_name "$new_name"
        tmux rename-session -t "$old_name" "$new_name"
        echo "${BLUE}Renamed session '$old_name' to '$new_name'${NC}"
    else
        error_msg "Session '$old_name' does not exist"
        return 1
    fi
}

list_sessions() {
    if tmux list-sessions 2>/dev/null; then
        :
    else
        echo "${GREEN}No active tmux sessions${NC}"
    fi
}

# FZF variants
fzf_create_session() {
    local selected
    if [ $# -gt 0 ] && [ -d "$1" ]; then
        selected="$1"
    else
        selected=$(fzf_directory_selector "$@")
    fi

    [ -z "$selected" ] && return 0

    create_session "$selected"
}

fzf_attach_session() {
    check_active_sessions || return 1
    local output
    output=$(fzf_session_selector --print-query --border-label="( ${BOLD}${GREEN}ATTACH${NC} )"  "$@" )
    local query=$(echo "$output" | sed -n '1p')
    local selected=$(echo "$output" | sed -n '2p')

    if [ -n "$selected" ]; then
        attach_session "$selected"
    elif [ -n "$query" ]; then
        create_session "$query"
    fi
}

fzf_kill_session() {
    check_active_sessions || return 1
    local current_session selected_sessions

    current_session=$(tmux display-message -p '#S')
    selected_sessions=$(fzf_session_selector --multi \
        --border-label="( ${BOLD}${RED}KILL${NC} )" \
        --header="Use TAB to select multiple" "$@")

    # Exit if no sessions were selected
    [ -z "$selected_sessions" ] && return 0

    local -a regular_sessions=()
    local kill_current=false

    while IFS= read -r session; do
        if [ "$session" = "$current_session" ]; then
            kill_current=true
        else
            regular_sessions+=("$session")
        fi
    done <<< "$selected_sessions"

    # Kill regular sessions first
    for session in "${regular_sessions[@]}"; do
        kill_session "$session"
    done

    # Kill current session last if selected
    if [ "$kill_current" = true ]; then
        echo "${YELLOW}Killing current session...${NC}"
        kill_session "$current_session"
    fi
}

fzf_rename_session() {
    check_active_sessions || return 1
    local old_name
    old_name=$(fzf_session_selector --border-label="( ${BOLD}${GREEN}RENAME${NC} )" "$@")

    if [ -n "$old_name" ]; then
        echo -n "Enter new name: "
        read -r new_name
        if [ -n "$new_name" ]; then
            rename_session "$old_name" "$new_name"
        fi
    fi
}

fzf_list_sessions() {
    check_active_sessions || return 1
    fzf_session_selector --border-label="( ${BOLD}${GREEN}LIST${NC} )" "$@"
}

# MAIN COMMAND FUNCTION
tmuxctl() {
    if [ $# -eq 0 ]; then
        show_help
        return 1
    fi

    if ! command -v tmux >/dev/null 2>&1; then
        error_msg "tmux is not installed"
        return 1
    fi

    case "$1" in
        # Interactive mode
        -i|--interactive)
            shift
            if [ $# -eq 0 ]; then
                echo "${YELLOW}No command specified for interactive mode${NC}" >&2
                show_help
                return 1
            fi
            case "$1" in
                new|n) shift; fzf_create_session "$@" ;;
                attach|a) shift; fzf_attach_session "$@" ;;
                kill|k) shift; fzf_kill_session "$@" ;;
                list|l) shift; fzf_list_sessions "$@" ;;
                rename|r) shift; fzf_rename_session "$@" ;;
                detach|d) detach_session "${2:-}" ;;
                *) error_msg "Unknown command: $1" ;;
            esac
            ;;
        # Direct mode
        new|n) create_session "${2:-}" ;;
        attach|a) attach_session "${2:-}" ;;
        kill|k) kill_session "${2:-}" ;;
        list|l) list_sessions ;;
        rename|r) rename_session "$2" "$3" ;;
        detach|d) detach_session "${2:-}" ;;
        -h|--help) show_help ;;
        -v|--version) show_version "full" ;;
        *) error_msg "Unknown command: $1" ;;
    esac
}
