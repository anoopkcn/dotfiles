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
    vim ${MEMO}/${today}
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
            if [ ! -e ${MEMO}/$1 ];then
              create_template ${MEMO}/$1
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
      --list-memos | -l)
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

note(){
  NOTES=${HOME}/Dropbox/Notes
  today="$(date "+%d-%m-%Y")"
  create_template(){
      touch $1
      echo -e "$(echo $(basename $1) | sed 's/_/ /g' | awk '{print toupper($0)}')\
        \nAuthor:$(echo $(basename $2) | sed 's/_/ /g')\
        \nDate Started: ${today}\
        \nDate Ended: \
        \nLast Modified: " >> $1

  }
  if [ $# -eq 0 ]; then
    echo "Run note -h to get help"
  else
  while [ ! $# -eq 0 ]
  do
    case "$1" in
      --version | -v)
        echo "NOTESv0.0.1"
        ;;
      --help | -h)
        echo "NOTESversion 0.0.1"
        echo "Written by Anoop Chandran - strivetobelazy@gmail.com"
        echo "note is a note taking application. "
        echo "USAGE: note [OPTIONS] [ARGUMENT]"
        echo "OPTIONS:
              --version | -v          : Display the version information
              --help | -h             : Display the help menu
              --create-note | -c      : Takes 0 or 1 ARGUMENT(s)
                                        Creates note file with name as ARGUMENT-1
              --write-note | -w       : Takes 2 ARGUMENT(s). 
                                        Appends the string ARGUMENT-2 to ARGUMENT-1 note
              --open-note | -o        : Takes 1 ARGUMENT's 
                                        Opens ARGUMENT-1 note
              --read-note | -r        : Takes 1 ARGUMENT's 
                                        Opens ARGUMENT-1 note in readonly
              --list-notes | -l       : Lists note files in the default/custom note dir
              --change-dir | -cd      : Change to note directory
        "
        ;;
      --create-note | -c)
        shift
        if [ -z "${1}" ];then
          echo "Usage: -c [file_name] [author_name]: file_name can't be empty"
        else
          if [[ $# -eq 2 ]];then
            if [ ! -e ${NOTES}/$1 ];then
              create_template ${NOTES}/$1 $2
           else
              echo "File already exists/ One argument missing"
            fi
          fi
        fi
        ;;
      --write-note |-w)
        shift
        if [ -z "${1}" ] || [ $# -eq 1 ];then
          echo "Usage: -w [file_name] [string] : file_name and string cant be empty"
        else
          string=${2}" ($(date "+%d-%m-%Y %R"))"
          echo ${string} >> ${NOTES}/${1}
        fi
        ;;
      --open-note | -o)
        shift
        if [ -z "${1}" ];then
          echo "Usage: -o [file_name]  : file_name cant be empty"
        else
            vim ${NOTES}/${1}
        fi
        ;;
      --read-note | -r)
        shift
        if [ -z "${1}" ];then
          echo "Usage: -r [file_name]  : file_name cant be empty"
        else
            less ${NOTES}/${1}
        fi
        ;;
      --list-notes | -l)
        ls ${NOTES} #/ | grep "$*"
        ;;
      --change-dir | -cd)
        cd ${NOTES}
        ;;
    esac
    shift
  done

  fi
}
