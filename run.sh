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

    # bootstrap autotools
    ( cd ${PROJECT_ROOT} && ./autogen.sh ) || die "Generating Staging build-system on ramdisk failed with: $!";
    case "$platform" in linux|osx|bsd|centos)
        cd ${tmp_dname}                                  || die "Entering Staging build directory on ramdisk failed with: $!";
        ${PROJECT_ROOT}/scripts/configure.sh ${platform} || die "Configuring project with platform='${platform}' failed with: $!";
        make distcheck                                   || die "Distribution checking failed with: $!";

        mkdir ${PROJECT_ROOT}/build
        mv ${tmp_dname}/${tarname} ${PROJECT_ROOT}/build/${tarname}
        cd ${PROJECT_ROOT}
        rm -rvf ${tmp_dname}
        ;;
    bear)
        cd ${tmp_dname}                            || die "Entering Staging build directory on ramdisk failed with: $!";
        ${PROJECT_ROOT}/scripts/configure.sh clang || die "Configuring project with platform='${platform}' failed with: $!";
        bear make check -j8;
        ;;
    clang-analyse)
        cd ${tmp_dname}                                  || die "Entering Staging build directory on ramdisk failed with: $!";
        ${PROJECT_ROOT}/scripts/configure.sh ${platform} || die "Configuring project with platform='${platform}' failed with: $!";
        scan-build \
            -analyze-headers \
            -k \
            -v \
            -enable-checker cplusplus \
            -enable-checker deadcode \
            -enable-checker security \
            -enable-checker unix
        ;;
    *)
        exec ${PROJECT_ROOT}/scripts/run.sh linux
    esac

    # restore umask
    umask ${current_umask}


}
configure_project "${1}"
