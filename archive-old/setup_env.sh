#!/usr/bin/env bash
set -e

echo ">>> Installing Mambaforge (Intel x86_64)..."

INSTALLER="Mambaforge-MacOSX-x86_64.sh"
URL="https://github.com/conda-forge/miniforge/releases/latest/download/$INSTALLER"

curl -L -o "$INSTALLER" "$URL"

# Check that file is valid (not a 9-byte error page)
if [ ! -s "$INSTALLER" ] || [ $(stat -f%z "$INSTALLER") -lt 10000 ]; then
    echo "Download failed or file too small. Aborting."
    exit 1
fi

bash "$INSTALLER" -b -p "$HOME/env/mambaforge"
rm "$INSTALLER"

# Init Conda
source "$HOME/env/mambaforge/etc/profile.d/conda.sh"
conda init

echo ">>> Mambaforge installed in ~/env/mambaforge"
