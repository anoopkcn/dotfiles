#!/usr/bin/env bash
languages=$(echo "sh python python3 rust golang c cpp fortran lua typescript nodejs latex" | tr ' ' '\n')
core_utils=$(echo "xargs find mv sed awk rsync scp ssh tr tar curl watch" | tr ' ' '\n')
selected=$(printf "${languages}\n${core_utils}" | fzf)

read -p "${selected} query ? " query;

# check if selected is a language
if [[ $languages == *$selected* ]]; then
    parse_query=$(echo $query | tr ' ' '+')
    curl cht.sh/${selected}/${parse_query} & while [ : ]; do sleep 1; done
else
    curl cht.sh/${selected}~${query} & while [ : ]; do sleep 1; done
fi
#
