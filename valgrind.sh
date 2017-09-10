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

exec valgrind -v --suppressions="${PROJECT_ROOT}/scripts/valgrind.supp" \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --num-callers=20 \
    --tool=memcheck -- "$@"
