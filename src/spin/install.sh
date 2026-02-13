#!/bin/sh
set -e

echo "Activating feature 'spin'"

version=${version:-latest}
plugins=${plugins:-"kube,aka"}

echo "Remote User Home: " $_REMOTE_USER_HOME
export SPIN_DATA_DIR=${_REMOTE_USER_HOME}/.local/share/spin
export TMPDIR=${_REMOTE_USER_HOME}/.tmp
echo "Spin Data Dir: " $SPIN_DATA_DIR

echo "Unsetting OTEL env vars"
for var in $(env | grep '^OTEL_' | cut -d= -f1); do
    unset "$var"
done
export OTEL_TRACES_EXPORTER=none

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

echo $plugins | tr ',' '\n' | xargs -I plugin_name spin plugins install plugin_name --yes

chown -R $_REMOTE_USER:$_REMOTE_USER $SPIN_DATA_DIR