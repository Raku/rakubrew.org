#!/usr/bin/env sh

set -o errexit
set -o pipefail

TMP_DIR=`mktemp -d -t 'rakubrew-temp-dir'`

curl -s https://rakubrew.org/macos/rakubrew -o $TMP_DIR/rakubrew

chmod +x $TMP_DIR/rakubrew
: ${RAKUBREW_HOME:=$($TMP_DIR/rakubrew home)}

if [ -e $RAKUBREW_HOME ]; then
    echo "$RAKUBREW_HOME already exists!" 1>&2
    echo "You should just upgrade your installation instead of installing over it!" 1>&2
    echo "You can run" 1>&2
    echo "    rakubrew self-upgrade" 1>&2
    echo "to do so." 1>&2

    rm -rf $TMP_DIR
    exit 1
fi

echo "Installing rakubrew to $RAKUBREW_HOME"

mkdir -p $RAKUBREW_HOME/bin
mv $TMP_DIR/rakubrew $RAKUBREW_HOME/bin
rmdir $TMP_DIR
$RAKUBREW_HOME/bin/rakubrew init

