#!/bin/sh
if [ -f /usr/local/bin/exctags ];
then
    export CTAGS=/usr/local/bin/exctags;
else
    export CTAGS=ctags;
fi

CTAGSFLAGS="-R --tag-relative=yes --exclude=.git --exclude=build"

${CTAGS} ${CTAGSFLAGS} $@ > tags
