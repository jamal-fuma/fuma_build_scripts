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

find ${PROJECT_ROOT}/sources ${PROJECT_ROOT}/tests \( -name '*.[hcHC]pp' -print \) \
    | xargs clang-format \
    -style=file --assume-filename=.clang-format \
    -i

