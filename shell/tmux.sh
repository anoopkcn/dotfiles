#!/usr/bin/env bash

function _tmux() {
    local tmux=$(type -fp tmux)
    case "$1" in
    update-environment | update-env | env-update)
        local v
        while read v; do
            if [[ $v == -* ]]; then
                unset ${v/#-/}
            else
                # Add quotes around the argument
                v=${v/=/=\"}
                v=${v/%/\"}
                eval export $v
            fi
        done < <(tmux show-environment)
        ;;
    *)
        $tmux "$@"
        ;;
    esac
}

tmux_env_update() {
    #Updating to latest tmux environment
    export IFS=","
    for line in $(tmux showenv -t $(tmux display -p "#S") | tr "\n" ","); do
        if [[ $line == -* ]]; then
            unset $(echo $line | cut -c2-)
        else
            export $line
        fi
    done
    unset IFS
}

function tm() {
    # abort if we're already inside a TMUX session
    if ([ "$TMUX" == "" ]); then
        # startup a "default" session if non currently exists
        # tmux has-session -t _default || tmux new-session -s _default -d

        # present menu for user to choose which workspace to open
        PS3="Please choose your session: "
        options=($(tmux list-sessions -F "#S" 2>/dev/null) "New Session" "quit")
        echo "Available sessions"
        select opt in "${options[@]}"; do
            case $opt in
            "New Session")
                read -p "Enter new session name: " SESSION_NAME
                tmux new -s "$SESSION_NAME"
                break
                ;;
            "quit")
                break
                ;;
            *)
                tmux attach-session -t $opt
                break
                ;;
            esac
        done
    fi
}

function tls() {
    # location=${HOME}/dotfiles/tmux/tmuxinator
    if [ $# -eq 1 ]; then
        case $1 in
        -a)
            for f in ${HOME}/dotfiles/tmux/tmuxinator/*.yml; do
                filename=$(basename "$f")
                filename="${filename%.*}"
                printf "%s\n" "${filename}"
            done
            ;;
        esac
    else
        t_sessions=($(tmux ls | cut -d : -f 1))
        for i in "${t_sessions[@]}"; do
            printf "\e[96m${i}\e[0m\n"
            (tmux lsw -t ${i} | awk '{print $1,$2}')
        done
    fi
}

function tkill() {
    if [ $# -eq 1 ]; then
        case $1 in
        -a)
            t_sessions=($(tmux ls | cut -d : -f 1))
            for i in "${t_sessions[@]}"; do
                tmux kill-session -t $i
            done
            ;;
        *)
            tmux kill-session -t $1
            ;;
        esac
    else
        echo "Provide a TMUX session to kill"
    fi
}
