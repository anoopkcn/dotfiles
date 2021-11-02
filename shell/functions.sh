#!/usr/bin/env bash

# print available colors and their numbers
function colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (($i % 5 == 0)); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

# Extract archives - use: extract <file>
function extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 -C $2 ;;
        *.tar.gz) tar xzf $1 -C $2 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) rar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 -C $2 ;;
        *.tbz2) tar xjf $1 -C $2 ;;
        *.tgz) tar xzf $1 -C $2 ;;
        *.zip) unzip $1 -d $2 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function killport() {
    lsof -ti:$1 | xargs kill -9
}

## GIT functions ##
function is_in_git_repo() {
    git rev-parse HEAD >/dev/null 2>&1
}

function gitzip() {
    git archive -o $(basename $PWD).zip HEAD
}
function gittgz() {
    git archive -o $(basename $PWD).tgz HEAD
}
function gitexport() {
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

function gitlog() {
    is_in_git_repo || return
    if [ $# -eq 0 ]; then
        git log --oneline --decorate --all --graph
    elif [ $1 = "-b" ]; then
        git log --oneline
    else
        git log --oneline --decorate --max-count=$1 --all --graph
    fi
}
