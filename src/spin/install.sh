#!/bin/bash
set -e

echo "Activating feature 'Fermyon Spin'"

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
VERSION="${VERSION:-"latest"}"

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Check if current architecture is supported
architecture="$(uname -m)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "x86_64" ] && [ "${architecture}" != "arm64" ] && [ "${architecture}" != "aarch64" ]; then
    echo "(!) Fermyon Spin does not support the current architecture $architecture"
    exit 1
fi
echo "!!!!!! ${architecture}"

# Install necessary dependencies
check_packages curl ca-certificates tar glibc-source


# Fetch latest version of Spin if needed
if [ "${VERSION}" = "latest" ]; then
    export VERSION=$(curl -s https://api.github.com/repos/fermyon/spin/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi

if ! spin --version &> /dev/null ; then
    echo "Installing Spin ${VERSION}..."

    # Create a temporary directory for the download
    mkdir -p /tmp/spin-download
    cd /tmp/spin-download

    # install ARM or AMD version of Spin depending on current machine architecture
    if [[ "${architecture}" == "arm64" ]] || [[ "${architecture}" == "aarch64" ]]; then
        arch="aarch64"
    else
        arch="amd64"
    fi

    # construct the filename for downloading Fermyon Spin from GitHub
    spin_filename="spin-v${VERSION}-linux-${arch}.tar.gz"

    # Download Fermyon Spin release from GitHub
    echo "Downloading Fermyon Spin..."
    curl -sSL -o ${spin_filename} "https://github.com/fermyon/spin/releases/download/v${VERSION}/${spin_filename}"
    # Extract the downloaded archive
    tar -xzf "${spin_filename}"
    
    # Move the extracted binary to /usr/local/bin and ensure it is executable
    mv -f spin /usr/local/bin/
    chmod +x /usr/local/bin/spin

    # Remove the temporary download folder again
    rm -rf /tmp/spin-download
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
