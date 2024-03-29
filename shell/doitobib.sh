#!/usr/bin/env bash

# Version 0.1.0
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

# Version 0.2.0
function doitobib() {
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
