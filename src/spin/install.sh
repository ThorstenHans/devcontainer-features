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

# split comma-separated plugins and install each
printf '%s' "$plugins" | tr ',' '\n' | while IFS= read -r plugin; do
    plugin=$(printf '%s' "$plugin" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "$plugin" ]; then
        echo "Installing plugin: $plugin"
        spin plugins install "$plugin" --yes
    fi
done