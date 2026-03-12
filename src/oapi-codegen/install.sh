#!/bin/sh
set -e

VERSION=${VERSION:-"latest"}

if echo "$VERSION" | grep -q '^[0-9]'; then
    VERSION="v$VERSION"
fi

REPO_URL="github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen"

if [ "$VERSION" != "latest" ]; then
    VER_NUM=$(echo "$VERSION" | sed 's/^v//')
    LOWEST=$(printf "2.2.0\n%s" "$VER_NUM" | sort -V | head -n1)
    
    if [ "$LOWEST" = "$VER_NUM" ]; then
        echo "Detected legacy version ($VERSION). Using deepmap repository."
        REPO_URL="github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen"
    fi
fi

echo "Installing ${REPO_URL}@${VERSION}..."
go install "${REPO_URL}@${VERSION}"