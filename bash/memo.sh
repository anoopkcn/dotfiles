#!/bin/bash

memo(){
  MEMO=${HOME}/Dropbox/Notes/MEMO
  today="$(date "+%d-%m-%Y")"
  file=${MEMO}/${today}
  create_template(){
      touch $1
      echo -e "MEMO : $today \n\
        \n05    PROSECUTE THE PRESENT STUDY\n06\n07\n08 \
        \n09    WORK\n10\n11\n12 \
        \n13    READ OR OVERLOOK MY ACCOUNTS \
        \n14    WORK\n15\n16\n17\n18 \
        \n19    CLEANING TO NEUTRAL,DIVERSION\n20\n21\n22 \
        \n23    SLEEP\n24\n01\n02\n03\n04\n" >> $1

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
              --open-memo | -o        : Takes 0 or 1 ARGUMENT's 
                                        0: Opens current-day memo
                                        1: Opens ARGUMENT-1 memo
              --read-memo | -r        : Takes 0 or 1 ARGUMENT's 
                                        0: Opens current-day memo in readonly
                                        1: Opens ARGUMENT-1 memo in readonly
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
          if [ ! -e $file ];then
            create_template $file
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
            tvar1=$(date "+%R"|awk -F: '{print $1}')
            tvar2=$(bc -l <<< ${tvar1}+1)
            string=${1}" ($(date "+%R"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "      "var3; p=0} 1' \
              $file
          else
            tvar1=$1
            tvar2=$(bc -l <<< $1+1)
            string=${2}" ($(date "+%R"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "      "var3; p=0} 1' \
              $file

          fi
        fi
        ;;
      --todo-memo |-t)
        shift
        if [ -z "${1}" ];then
          echo "Usage: -t < [file_name] string >, string cant be empty"
        else
          if [[ $# -eq 1 ]];then
            tvar1=$(date "+%R"|awk -F: '{print $1}')
            tvar2=$(bc -l <<< $tvar1+1)
            string=${1}" ($(date "+%R"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "      TODO:"var3; p=0} 1' \
              $file
          else
            tvar1=$1
            tvar2=$(bc -l <<< $1+1)
            string=${2}" ($(date "+%R"))"
            gawk -i inplace -v var1="$tvar1" -v var2="$tvar2" -v var3="$string" \
              '$1==var1{p=1} p && $1==var2{print "      TODO:"var3; p=0} 1' \
              $file

          fi
        fi
        ;;
      --open-memo | -o)
          shift
          if [[ $# -eq 0 ]];then
            vim $file
          else
            vim ${MEMO}/${1}
          fi
          ;;
      --read-memo | -r)
          shift
          if [[ $# -eq 0 ]];then
            less $file
          else
            less ${MEMO}/${1}
          fi
          ;;
      --list-notes | -l)
        ls ${MEMO} #/ | grep "$*"
        ;;
      --todo-list | -tl)
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
