#!/bin/sh
set -e

echo "Activating feature 'spin'"

version=${version:-latest}

if [ "$version" != "latest" ]; then
    case "$version" in
        [0-9]*)
            version="v$version"
            ;;
    esac
    curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash -s -- -v $version
else
    curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
fi

cp spin /usr/local/bin/