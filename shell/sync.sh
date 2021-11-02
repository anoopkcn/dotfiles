#!/usr/bin/env bash

function dsync() {
    if [[ $# -eq 0 || "$#" -eq 2 || "$#" -gt 3 ]]; then
        echo "Specify a server [server | server <source> <destination>]"
    elif [[ "$#" -eq 1 ]]; then
        curr_path=$(pwd)
        if [ "$curr_path" != "$HOME" ]; then
            path=$(echo $curr_path | cut -d '/' -f 4-)
            rsync -arzvc --prune-empty-dirs --exclude-from="$HOME/dotfiles/shell/rsync_exclude.txt" -e ssh $1:~/${path}/. ${curr_path}/.
        else
            echo "Warning:Global sync on Home folder is not allowed"
        fi
    else
        rsync -airzv --exclude-from="$HOME/dotfiles/shell/rsync_exclude.txt" -e ssh $1:$2 $3
    fi
}

function usync() {
    if [[ $# -eq 0 || "$#" -eq 2 || "$#" -gt 3 ]]; then
        echo "Specify a server [server | server <source> <destination>]"
    elif [[ "$#" -eq 1 ]]; then
        curr_path=$(pwd)
        if [ "$curr_path" != "$HOME" ]; then
            path=$(echo $curr_path | cut -d '/' -f 4-)
            rsync -arzvc --exclude-from="$HOME/dotfiles/shell/rsync_exclude.txt" --prune-empty-dirs ${curr_path}/. -e ssh $1:~/${path}/.
        else
            echo "Warning:Global sync on Home folder is not allowed"
        fi
    else
        curr_path=$(pwd)             # make this more universal:TODO
        curr_folder=${curr_path##*/} # current folder
        last_name=$(echo $3 | awk -F"/" '{print $(NF)}')
        last_name=${last_name//./} # empty if '.' is the last_name
        if [ -z "$last_name" ]; then
            last_name=$(echo $3 | awk -F"/" '{print $(NF-1)}')
        fi
        if [ "$curr_folder" != "$last_name" ]; then
            echo "Target file/folder is DIFFERENT(or an alias) then PWD. You want to continue?\nPress Enter or type [yes|y] to continue."
            read accept
            if [[ "$accept" == "yes" || "$accept" == "y" || "$accept" == "" ]]; then
                rsync -airzvc --exclude-from="$HOME/dotfiles/shell/rsync_exclude.txt" $2 -e ssh $1:$3
            else
                return
            fi
        else
            rsync -airzvc --exclude-from="$HOME/dotfiles/shell/rsync_exclude.txt" $2 -e ssh $1:$3
        fi
        # echo "$curr_folder \t ${last_name}"
    fi
}
