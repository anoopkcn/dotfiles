#!/bin/bash
#system information
function system(){
    echo "Hello, $USER"
    echo
    echo "Today's date is `date`, this is week `date +"%V"`."
    echo
    echo "These users are currently connected:"
    w | cut -d " " -f 1 - | grep -v USER | sort -u
    echo
    echo "This is `uname -s` running on a `uname -m` processor."
    echo
    echo "Uptime information::"
    uptime
}

# print available colors and their numbers
function colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (( $i % 5 == 0 )); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

light(){
    export VIMBG=light
    echo -n -e "\033]50;SetProfile=light\a"
}
dark(){
    export VIMBG=dark
    echo -n -e "\033]50;SetProfile=dark\a"
}

# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@"
}

function hist() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# find shorthand
function f() {
    find . -name "$1"
}

# take this repo and copy it to somewhere else minus the .git stuff.
function gitexport(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

# get gzipped size
function gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# All the dig info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
}

# Extract archives - use: extract <file>
# Credits to http://dotfiles.org/~pseup/.bashrc
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 -C $2 ;;
            *.tar.gz) tar xzf $1 -C $2 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) rar x $1;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 -C $2;;
            *.tbz2) tar xjf $1 -C $2;;
            *.tgz) tar xzf $1 -C $2;;
            *.zip) unzip $1 -d $2;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function glog(){
if [ $# -eq 0 ]; then
    echo "No arguments supplied"
else
  git log --oneline --decorate --max-count=$1 --graph
fi
}

# === Remote settings =====#
function dsync(){
if [[ $# -eq 0 || "$#" -eq 2 ||"$#" -gt 3 ]]; then
    echo "Specify a server [server | server <source> <destination>]"
elif [[ "$#" -eq 1 ]]; then
    curr_path=`pwd`
    if [ "$curr_path" != "$HOME" ]; then
    path=`echo $curr_path | cut -d '/' -f 4-`
    rsync -arzv --prune-empty-dirs --exclude-from="$HOME/Dropbox/Dotfiles/bash/rsync_exclude.txt" -e ssh $1:~/${path}/. ${curr_path}/.
    else
      echo "Warning:Global sync on Home folder is not allowed"
    fi
else
    rsync -arzv -e ssh $1:$2 $3
fi
}

function usync(){
if [[ $# -eq 0 || "$#" -eq 2 ||"$#" -gt 3 ]]; then
    echo "Specify a server [server | server <source> <destination>]"
elif [[ "$#" -eq 1 ]]; then
    curr_path=`pwd`
    if [ "$curr_path" != "$HOME" ]; then
    path=`echo $curr_path | cut -d '/' -f 4-`
    rsync -arzv --prune-empty-dirs  ${curr_path}/. -e ssh $1:~/${path}/.
    else
      echo "Warning:Global sync on Home folder is not allowed"
    fi
else
    rsync -arzv $2 -e ssh $1:$3
fi
}

#git specific
gitzip() {
  git archive -o $(basename $PWD).zip HEAD
}

gittgz() {
  git archive -o $(basename $PWD).tgz HEAD
}

doi2bib(){
    echo >> bib.bib;
    curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" >> bib.bib;
    echo >> bib.bib;
}
pyc(){
    echo $(python -c $1)
}

memo(){
  MEMO=${HOME}/Dropbox/Notes/MEMO
  today="$(date "+%d-%m-%Y")"
  file=${MEMO}/${today}
  create_template(){
      touch $1
      echo -e "MEMO : $1 \n\
        \n05\n06\n07 \
        \n08\n09\n10\n11 \
        \n12\n13 \
        \n14\n15\n16\n17 \
        \n18\n19\n20\n21 \
        \n22\n23\n24\n01\n02\n03\n04\n" >> $1

  }
  if [ $# -eq 0 ]; then
    $EDITOR ${MEMO}/${today}
  else
  while [ ! $# -eq 0 ]
  do
    case "$1" in
      --version | -v)
        echo "memo v0.0.1"
        ;;
      --help | -h)
        echo "memo version 0.0.1"
        echo "Written by Anoop Chandran - strivetobelazy@gmail.com"
        echo "memo is a note taking application. Tribute to Benjamin Franklin(1706-1790)"
        echo "USAGE: memo [OPTIONS] [ARGUMENT]"
        echo "OPTIONS:
              --version | -v          : Display the version information
              --help | -h             : Display the help menu
              --create-memo | -c      : Takes 0 or 1 ARGUMENT(s)
                                        0: Creates memo file with name as current-day date
                                        1: Creates memo file with name as ARGUMENT-1
              --write-memo | -w       : Takes 1 or 2 ARGUMENT(s). 
                                        1: Appends the string ARGUMENT-1 after current-hour 
                                        2: Appends the string ARGUMENT-2 after ARGUMENT-1 hour
              --read-memo | -r        : Takes 0 or 1 ARGUMENT's 
                                        0: Opens current-day memo
                                        1: Opens ARGUMENT-1 memo
              --list-memos | -l       : Lists MEMO files in the default/custom note dir
              --list-todo | -t        : Lists todo's in memos in the default/custom MEMO dir
              --todo-all-list | -ta   : Same as -t but includes also the done todo's
              --todo-done-list | -td  : Same as -t but only shows the done todo's
              --change-dir | -cd      : Change to memo directory
        "
        ;;
      --create-memo | -c)
        shift
        if [ -z "${1}" ];then
          if [ ! -e $today ];then
            create_template $today
            else
              echo "File already exists"
            fi
        else
          if [[ $# -eq 1 ]];then
            if [ ! -e $1 ];then
              create_template $1
            else
              echo "File already exists"
            fi
          fi
        fi
        ;;
      --write-memo |-w)
        shift
        if [ -z "${1}" ];then
          echo "Usage: -w < [file_name] string >, string cant be empty"
        else
          if [[ $# -eq 1 ]];then
            tvar1=$(date "+%r"|awk -F: '{print $1}')
            tvar2=$(($tvar1+1))
            string=${1}" ($(date "+%r"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "\t"var3; p=0} 1' \
              $file
          else
            tvar1=$1
            tvar2=$(($1+1))
            string=${2}" ($(date "+%r"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "\t"var3; p=0} 1' \
              $file

          fi
        fi
        ;;
      --read-memo | -r)
          shift
          if [[ $# -eq 0 ]];then
            vim $file
          else
            vim ${MEMO}/${1}
          fi
          ;;
      --list-notes | -l)
        ls ${MEMO} #/ | grep "$*"
        ;;
      --todo-list | -t)
        grep -v ":DONE" ${MEMO}/* | grep TODO
        ;;
      --todo-all-list | -ta)
        grep "TODO" ${MEMO}/*
        ;;
      --todo-done-list | -td)
        grep ":DONE" ${MEMO}/*
        ;;
      --change-dir | -cd)
        cd ${MEMO}
        ;;
    esac
    shift
  done

  fi
}
