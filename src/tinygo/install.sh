#!/bin/sh
set -e

echo "Activating feature 'tinygo'"

version=${version:-0.39.0}
arch=$(dpkg --print-architecture)
tinygo_name=tinygo_${version}_${arch}.deb

wget https://github.com/tinygo-org/tinygo/releases/download/v$version/$tinygo_name
sudo dpkg -i $tinygo_name