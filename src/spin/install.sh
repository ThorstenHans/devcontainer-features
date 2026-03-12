#!/bin/sh
set -e

echo "Activating feature 'spin'"

version=${VERSION:-latest}

if [ "$version" != "latest" ]; then
    case "$version" in
        [0-9]*)
            version="v$version"
            ;;
    esac
    cat install-spin.sh | bash -s -- -v $version
else
    cat install-spin.sh | bash
fi

cp spin /usr/local/bin/