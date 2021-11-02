#!/bin/bash

# system information
unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) MACHINE=Linux ;;
Darwin*) MACHINE=Mac ;;
CYGWIN*) MACHINE=Cygwin ;;
MINGW*) MACHINE=MinGw ;;
*) MACHINE="UNKNOWN:${unameOut}" ;;
esac

function system() {
    echo "Hello, $USER"
    echo
    echo "Today's date is $(date), this is week $(date +"%V")."
    echo
    echo "These users are currently connected:"
    w | cut -d " " -f 1 - | grep -v USER | sort -u
    echo
    echo "This is $(uname -s) running on a $(uname -m) processor."
    echo
    echo "Uptime information::"
    uptime
}

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

# doitobib(){
#      if [[ $# == 1 ]]; then
#       echo >> bib.bib;
#       curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" >> bib.bib;
#       echo >> bib.bib;
#      else
#       echo -n "DOI = $1,  "
#       curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" | grep $2 | sed "s/^[ \t]*//"
#      fi
# }

function killport() {
    lsof -ti:$1 | xargs kill -9
}

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

## Command Line Interface Papers Manager (CLIP-Manager)
doitobib() {
    BIB_FILE=""
    BIB_INFO=""
    BIB_API="http://api.crossref.org/works/"
    BIB_TRANS="/transform/application/x-bibtex"
    while test $# -gt 0; do
        case "$1" in
        -h | --help)
            echo "Processing info using a DOI"
            return
            ;;
        -d | --doi)
            shift
            if test $# -gt 0; then
                DOI=$1
            else
                echo "No DOI Specified"
                exit 1
            fi
            shift
            ;;
        -i | --info)
            shift
            if test $# -gt 0; then
                BIB_INFO=$1
            fi
            shift
            ;;
        -f | --file)
            shift
            if test $# -gt 0; then
                BIB_FILE=$1
            fi
            shift
            ;;
        *)
            break
            ;;
        esac
    done
    # TODO make it less verbose
    # Use the information gatherd above
    if [[ -z $BIB_FILE ]]; then
        if [[ ! -z $BIB_INFO ]]; then
            curl -s "${BIB_API}${DOI}${BIB_TRANS}" | grep ${BIB_INFO} | sed "s/^[ \t]*//"
        else
            curl -s "${BIB_API}${DOI}${BIB_TRANS}"
        fi
    elif [[ ! -z $BIB_FILE ]]; then
        echo >>${BIB_FILE}
        curl -s "${BIB_API}${DOI}${BIB_TRANS}" >>${BIB_FILE}
        echo >>${BIB_FILE}
    fi
}

## GIT functions ##
# return 0 if git repo
is_in_git_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

# Git DIR functions
#-------------------
gitzip() {
  git archive -o $(basename $PWD).zip HEAD
}
gittgz() {
  git archive -o $(basename $PWD).tgz HEAD
}
# take this repo and copy it to somewhere else minus the .git stuff.
gitexport() {
  mkdir -p "$1"
  git archive master | tar -x -C "$1"
}

# REPO functions
#----------------
gitlog() {
  is_in_git_repo || return
  if [ $# -eq 0 ]; then
    git log --oneline --decorate --all --graph
  elif [ $1 = "-b" ]; then
    git log --oneline
  else
    git log --oneline --decorate --max-count=$1 --all --graph
  fi
}
gitb() {
  is_in_git_repo || return
  git branch -a
}
gitr() {
  is_in_git_repo || return
  git remote -v
}

#chech how ahead or behind the upstream
# gitab() {
#   is_in_git_repo || return
#   curr_branch=$(git rev-parse --abbrev-ref HEAD);
#   curr_remote=$(git config branch.$curr_branch.remote);
#   curr_merge_branch=$(git config branch.$curr_branch.merge | cut -d / -f 3);
#   git rev-list --left-right --count $curr_branch...$curr_remote/$curr_merge_branch | tr -s '\t' '|';
# }

# git lazy statys
gitls() {
  is_in_git_repo || return
  bold="\e[1m"
  regular="\e[21m"
  normal="\e[39m"
  cyan="\e[36m"
  yellow="\e[33m"
  green="\e[32m"
  gray_light="\e[37m"
  gray_dark="\e[90m"
  # Get the current git branch name (if available)
  #local ref
  ref=$(command git symbolic-ref HEAD 2>/dev/null) ||
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return 0
  # IFS='\n';
  git_status=$(git status -s 2>/dev/null | cut -c1-2) # NOTE: ${git_status:0:2} cant be used since multi lined
  if [[ -z "$git_status" ]]; then
    printf "${gray_light}${ref#refs/heads/}${normal} ${green}✓${normal}"
  else
    git_staged=$(echo ${git_status} | grep -c "^[M|A|D|R|C]")
    [[ $git_staged = 0 ]] && git_staged="" || git_staged=" ${yellow}${git_staged}${yellow}ᴹ${normal}"
    git_modified=$(echo ${git_status} | grep -c "^[M|A|D|R|C|[:space:]][M|A|R|C]")
    [[ $git_modified = 0 ]] && git_modified="" || git_modified=" ${green}${git_modified}${green}ᴹ${normal}"
    git_deleted=$(echo ${git_status} | grep -c "^[[:space:]]D")
    [[ $git_deleted = 0 ]] && git_deleted="" || git_deleted=" ${red}${git_deleted}${red}ᴰ${normal}"
    git_untracked=$(echo ${git_status} | grep -c "??")
    [[ $git_untracked = 0 ]] && git_untracked="" || git_untracked=" ${cyan}${git_untracked}${cyan}ˀ${normal}"
    printf "${gray_light}${ref#refs/heads/}${normal}${git_staged}${git_modified}${git_deleted}${git_untracked}"
  fi
}


## TMUX functions ##

#!/usr/bin/env bash
# tmux related functions
# for updating envirnment variable

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

tls() {
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

tkill() {
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
