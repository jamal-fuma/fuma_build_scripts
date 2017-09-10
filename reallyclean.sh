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

top_srcdir=${PROJECT_ROOT}

rm -rf ${top_srcdir}/config.h.in~ \
    ${top_srcdir}/config.h.in \
    ${top_srcdir}/Makefile.in \
    ${top_srcdir}/configure \
    ${top_srcdir}/aclocal.m4 \
    ${top_srcdir}/build-aux/compile \
    ${top_srcdir}/build-aux/config.guess \
    ${top_srcdir}/build-aux/config.h.in \
    ${top_srcdir}/build-aux/config.h.in~ \
    ${top_srcdir}/build-aux/config.sub \
    ${top_srcdir}/build-aux/test-driver \
    ${top_srcdir}/build-aux/depcomp \
    ${top_srcdir}/build-aux/install-sh \
    ${top_srcdir}/build-aux/ltmain.sh \
    ${top_srcdir}/build-aux/missing \
    ${top_srcdir}/m4/ltsugar.m4 \
    ${top_srcdir}/m4/libtool.m4 \
    ${top_srcdir}/m4/ltversion.m4 \
    ${top_srcdir}/m4/lt~obsolete.m4 \
    ${top_srcdir}/m4/ltoptions.m4 \
    ${top_srcdir}/autom4te.cache \
    ${top_srcdir}/Makefile.in \ \
    ${top_srcdir}/tests/Makefile.in \
    ${top_srcdir}/tests/include/Makefile.in \
    ${top_srcdir}/tests/lib/Makefile.in \
    ${top_srcdir}/tests/src/Makefile.in \
    ${top_srcdir}/sources/Makefile.in \
    ${top_srcdir}/sources/include/Makefile.in \
    ${top_srcdir}/sources/lib/Makefile.in \
    ${top_srcdir}/sources/src/Makefile.in
