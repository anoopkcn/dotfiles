#!/bin/bash
#git enabled PS1 is in the file ./lazy_theme.bash
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
