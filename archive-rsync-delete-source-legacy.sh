#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the source directory
echo "Enter the source directory path:"
read source_dir

# Prompt the user for the destination directory
echo "Enter the destination directory path:"
read dest_dir

# Archive the source directory
tar -cvzf archive.tar.gz $source_dir

# Transfer the archive to the destination directory
rsync -avz --progress archive.tar.gz $dest_dir

# Verify the transfer
echo "Verifying transfer... please wait"
if cmp -s $source_dir $dest_dir; then
    echo "Transfer successful!"
    # Delete the source directory
    echo "Deleting source directory"
    sudo rm -rf $source_dir
else
    echo "Transfer failed. Please try again."
fi

# Delete the archive
sudo rm -rf archive.tar.gz
