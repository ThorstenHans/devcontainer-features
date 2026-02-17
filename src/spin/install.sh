#!/bin/sh
set -e

echo "Activating feature 'spin'"

version=${version:-latest}
plugins=${plugins:-"kube,aka"}

echo "Remote User Home: " $_REMOTE_USER_HOME
export SPIN_DATA_DIR=${_REMOTE_USER_HOME}/.local/share/spin
export TMPDIR=${_REMOTE_USER_HOME}/.tmp
mkdir -p $TMPDIR
echo "Spin Data Dir: " $SPIN_DATA_DIR

echo "Unsetting OTEL env vars"
for var in $(env | grep '^OTEL_' | cut -d= -f1); do
    unset "$var"
done
export OTEL_TRACES_EXPORTER=none

# Check if we're on a supported system and get OS and processor architecture to download the right version
UNAME_ARC=$(uname -m)

case $UNAME_ARC in
"x86_64")
    ARC="amd64"
    ;;
"arm64" | "aarch64")
    ARC="aarch64"
    ;;
*)
    echo "The Processor type: ${UNAME_ARC} is not yet supported by Spin."
    exit 1
    ;;
esac

# If OS uses musl, set distinct OS type to ensure the binary
# with statically linked libraries and dependencies is used
if command -v ldd >/dev/null 2>&1 && [[ "$(ldd /bin/ls | grep -m1 'musl')" ]]; then
    OSTYPE="linux-musl"
fi

case $OSTYPE in
"darwin"*)
    OS="macos"
    STATIC="false"
    ;;
"linux-musl"*)
    OS="linux"
    STATIC="true"
    ;;
"linux"*)
    OS="linux"
    STATIC="false"
    ;;
*)
    echo "The OSTYPE: ${OSTYPE} is not supported by this script."
    echo "Please refer to this article to install Spin: https://spinframework.dev/quickstart"
    exit 1
    ;;
esac

# Check desired version. Default to latest if no desired version was requested
if [[ "$version" == "latest" ]]; then
    version=$(curl -so- https://github.com/spinframework/spin/releases | grep 'href="/spinframework/spin/releases/tag/v[0-9]*.[0-9]*.[0-9]*\"' | sed -E 's/.*\/spinframework\/spin\/releases\/tag\/(v[0-9\.]+)".*/\1/g' | head -1)
fi

# Constructing download FILE and URL
if [[ $STATIC = "true" ]]; then
    FILE="spin-${version}-static-${OS}-${ARC}.tar.gz"
else
    FILE="spin-${version}-${OS}-${ARC}.tar.gz"
fi
URL="https://github.com/spinframework/spin/releases/download/${version}/${FILE}"

# Establish the location of current working environment
current_dir=$(pwd)

# Define Spin directory name
spin_directory_name="/spin"

if [ -d "${current_dir}$spin_directory_name" ]; then
    echo "Error: .$spin_directory_name already exists, please delete ${current_dir}$spin_directory_name and run the installer again."
    exit 1
fi

# Download file, exit if not found - e.g. version does not exist
echo "Step 1: Downloading: ${URL}"
curl -fsOL $URL || (
    echo "Error downloading the file: ${FILE}"
    exit 1
)
echo "Done...\n"

# Decompress the file
echo "Step 2: Decompressing: ${FILE}"
tar xfv $FILE
./spin --version
echo "Done...\n"

# Remove the compressed file
echo "Step 3: Removing the downloaded tarball"
rm $FILE
echo  "Done...\n"

mv spin /usr/local/bin/
spin plugins update

echo "Now installing the following Spin plugins:" $plugins

echo $plugins | tr ',' '\n' | xargs -I plugin_name spin plugins install plugin_name --yes

chown -R $_REMOTE_USER:$_REMOTE_USER $SPIN_DATA_DIR