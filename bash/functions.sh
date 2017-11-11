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

doi2bib(){
     if [[ $# == 1 ]]; then
      echo >> bib.bib;
      curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" >> bib.bib;
      echo >> bib.bib;
     else
      echo "DOI = $1"
      curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" | grep $2 
     fi
}

