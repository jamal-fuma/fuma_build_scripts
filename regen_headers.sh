#!/bin/sh

# workout the absolute path to the checkout directory
abspath()
{
    case "${1}" in
        [./]*)
            local ABSPATH="$(cd ${1%/*}; pwd)/${1##*/}"
            echo "${ABSPATH}"
            ;;
        *)
            echo "${PWD}/${1}"
            ;;
    esac
}

SCRIPT=$(abspath ${0})
SCRIPTPATH=`dirname ${SCRIPT}`
ROOTPATH=`dirname ${SCRIPTPATH}`
export PROJECT_ROOT=${ROOTPATH}


( cd ${PROJECT_ROOT}/sources/include; \
    find . -iname '*.h' -o -iname '*.hpp'  \
    |   sort -t/ -k4,7f -g \
    |   sed -e 's/\.\/\(.*\)/ \1 \\/'  \
    |   sed -e '${ s/\\//;}'  \
) ;
