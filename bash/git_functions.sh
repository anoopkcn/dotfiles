#!/bin/bash
# return 0 if git repo
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
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
function gitexport(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

# REPO functions
#----------------
function glog(){
	is_in_git_repo || return
	if [ $# -eq 0 ]; then
	    git log --oneline --decorate --all --graph
	elif [ $1 = "-b" ]; then
	    git log --oneline
	else
	    git log --oneline --decorate --max-count=$1 --all --graph
	fi
}
gb(){
  is_in_git_repo || return
  git branch -a
}
gr(){
  is_in_git_repo || return
  git remote -v
}

# gco - checkout git branch/tag
gc() {
  is_in_git_repo || return
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}' | awk '{print $2}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}' | awk '{print $2}') || return
  target=("Quit" "New Branch" $((echo "$tags"; echo "$branches") | sed '/^$/d')) 
  select opt in "${target[@]}"
  do
    case $opt in
      "New Branch")
        read -p "Enter new branch name: " BRANCH_NAME
        git checkout -b "$BRANCH_NAME"
        break
        ;;
      "Quit")
        break;;
      *)
        git checkout $(echo "$opt")
        break
        ;;
    esac
  done
}