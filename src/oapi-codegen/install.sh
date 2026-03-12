#!/bin/sh
set -e

version=${VERSION:-"latest"}

if echo "$version" | grep -q '^[0-9]'; then
    version="v$version"
fi

REPO_URL="github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen"

if [ "$version" != "latest" ]; then
    VER_NUM=$(echo "$version" | sed 's/^v//')
    LOWEST=$(printf "2.2.0\n%s" "$VER_NUM" | sort -V | head -n1)
    
    if [ "$LOWEST" = "$VER_NUM" ]; then
        echo "Detected legacy version ($version). Using deepmap repository."
        REPO_URL="github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen"
    fi
fi

echo "Installing ${REPO_URL}@${version}..."
go install "${REPO_URL}@${version}"