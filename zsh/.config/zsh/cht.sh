#!/usr/bin/env bash
languages=$(echo "sh python python3 rust golang c cpp fortran lua typescript nodejs latex" | tr ' ' '\n')
core_utils_string="man tldr sed awk tr cp ls grep xargs rg ps mv kill lsof less head tail tar cp rm rename jq cat ssh cargo git git-worktree git-status git-commit git-rebase docker docker-compose stow chmod chown make"
core_utils=$(echo $core_utils_string | tr ' ' '\n')
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
#
#
# find
