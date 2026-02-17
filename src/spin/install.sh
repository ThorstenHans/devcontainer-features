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
    curl -fsSL install-spin.sh | bash -s -- -v $version
else
    curl -fsSL install-spin.sh | bash
fi

cp spin /usr/local/bin/