#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Set the user as the owner of the directories and subdirectories
sudo chown -R steven:staff /Volumes/2T-Xx

# Set permissions to allow access (read, write, and execute) for the user
sudo chmod -R u+rwx /Volumes/2T-Xx

# Navigate to the /Volumes/Xx directory
cd /Volumes/2T-Xx || exit

# Find all files, calculate their checksums, and output to a temporary file
find . -type f -exec md5 {} + | sort > /tmp/file_checksums.txt

# Create the CSV header
echo "Name|FilePath" > duplicates.csv

# Identify duplicates by matching checksums and output in the specified format
awk '{print $1}' /tmp/file_checksums.txt | uniq -d | while read -r checksum; do
    grep "$checksum" /tmp/file_checksums.txt | while read -r line; do
        filepath=$(echo "$line" | awk '{print $2}')
        filename=$(basename "$filepath")
        echo "$filename|$filepath" >> duplicates.csv
    done
done

# Display completion message
echo "Duplicates have been saved to duplicates.csv"
