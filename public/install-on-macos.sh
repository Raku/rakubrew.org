#!/usr/bin/env sh

set -o errexit
set -o pipefail

for cmd in "rakudobrew", "p6env"; do
    if command -v $cmd >/dev/null 2>&1 ; then
        echo "A previous $cmd installation was found. rakubrew can not be used in"
        echo "parallel with other Raku version managers."
        echo "Please remove $cmd before installing rakubrew."
        exit 1
    fi
done

TMP_DIR=$(mktemp -d -t 'rakubrew-temp-dir')

echo "Downloading rakubrew..."

curl -s https://rakubrew.org/macos/rakubrew -o "$TMP_DIR/rakubrew"

chmod +x "$TMP_DIR/rakubrew"
: ${RAKUBREW_HOME:="$($TMP_DIR/rakubrew home)"}

if [ -e "$RAKUBREW_HOME/bin/rakubrew" ]; then
    echo "A previous rakubrew installation was found here: $RAKUBREW_HOME" 1>&2
    echo "You should just upgrade your installation instead of installing over it!" 1>&2
    echo "You can run" 1>&2
    echo "    rakubrew self-upgrade" 1>&2
    echo "to do so." 1>&2

    rm -rf "$TMP_DIR"
    exit 1
fi

echo "Installing rakubrew to $RAKUBREW_HOME ..."
echo ""

mkdir -p "$RAKUBREW_HOME/bin"
mv "$TMP_DIR/rakubrew" "$RAKUBREW_HOME/bin"
rmdir "$TMP_DIR"
"$RAKUBREW_HOME/bin/rakubrew" init
