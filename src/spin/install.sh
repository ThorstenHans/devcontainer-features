#!/bin/sh
set -e

echo "Activating feature 'spin'"

version=${version:-latest}
plugins=${plugins:-"kube,aka"}

echo "Remote User Home: " $_REMOTE_USER_HOME
export SPIN_DATA_DIR=${_REMOTE_USER_HOME}/.local/share/spin
echo "Spin Data Dir: " $SPIN_DATA_DIR
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

echo "Now installing the following Spin plugins:" $plugins

IFS=',' read -r -a plugins_array <<< "$plugins"
for plugin in "${plugins_array[@]}"; do
    spin plugin install "$plugin" --yes
done