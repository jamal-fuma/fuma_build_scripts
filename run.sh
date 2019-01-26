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

die()
{
   printf "Error: %s\n" "${1:-'unspecified failure'}"
   exit `false`
}

print_cwd()
{
   printf "CWD: %s\n" `pwd`
}

configure_project()
{
    platform=${1:-"linux"}
    tarname="$(cat ${PROJECT_ROOT}/project/NAME)-$(cat ${PROJECT_ROOT}/project/VERSION).tar.gz"

    # safely create tmpdir see https://www.netmeister.org/blog/mktemp.html
    current_umask=$(umask)
    umask 077
    tmp_dname=$(mktemp -d)


    # make a toplevel directory which is ignored by git
    rm -rvf ${PROJECT_ROOT}/build   || die "Removing Staging build directory failed with: $!";
    ln -sv ${tmp_dname} ${PROJECT_ROOT}/build     || die "Linking Staging build directory failed with: $!";
    ( cd ${PROJECT_ROOT} && ./autogen.sh ) || die "Generating Staging build-system on ramdisk failed with: $!";

    cd ${PROJECT_ROOT}/build        || die "Entering Staging build directory on ramdisk failed with: $!";
    print_cwd;
    ${PROJECT_ROOT}/scripts/configure.sh ${platform} || die "Configuring project failed with: $!";
    if [ "$1" = "clang" ]; then
        bear make check -j8;
    elif [ "$1" = "clang-analyse" ]; then
        scan-build \
            -analyze-headers \
            -k \
            -v \
            -enable-checker cplusplus \
            -enable-checker deadcode \
            -enable-checker security \
            -enable-checker unix \
            make check -j8
    else
        make ctags cscope
        make check -j8
        make distcheck
        make clean
        make distclean
        ${PROJECT_ROOT}/scripts/reallyclean.sh
        mv ${tmp_dname}/${tarname} ${PROJECT_ROOT}/${tarname}
        rm ${PROJECT_ROOT}/build
        mkdir ${PROJECT_ROOT}/build
        mv ${tmp_dname}/${tarname} ${PROJECT_ROOT}/build/${tarname}
        rm -rvf ${tmp_dname}
    fi

    # restore umask
    umask ${current_umask}

}

# Optionally do work in a ramdisk
if [ -e /Volumes/RAM\ Disk ]; then
    # delete anything that shouldn't be there
    if [ "$1" = "RAMDISK" ] ; then
        rm -rvf /Volumes/RAM\ Disk/* || die "Removing trash from ramdisk failed with: $!";

        # Overwrite the input argument as we only take this branch on osx
        configure_project "osx"
        exit $!
    fi
fi

configure_project "${1}"
