#!/bin/sh
set -e

echo "Activating feature 'apl'"

version=${VERSION:-0.1.0}

UNAME_ARC=$(uname -m)
UNAME_OS=$(uname -s)

case $UNAME_ARC in
"x86_64")
  arc="amd64"
  ;;
"arm64" | "aarch64")
  arc="arm64"
  ;;
*)
  echo "Error: Unsupported architecture $UNAME_ARC"
  exit 1
  ;;
esac

case $UNAME_OS in
"Darwin"*)
  os="darwin"
  ;;
"Linux"*)
  os="linux"
  ;;
*)
  echo "Error: Unsupported OS $UNAME_OS"
  exit 1
  ;;
esac

apl_name="aplcli_${os}_${arc}.tar.gz"

mkdir -p /tmp/apl-install
cd /tmp/apl-install

echo "Downloading aplcli ${version}"
wget "https://github.com/akamai-developers/cloud-native-platform-engineering/releases/download/v$version/$apl_name"
tar -xzf "$apl_name" -C /usr/local/bin

# Cleanup
rm -rf /tmp/apl-install

