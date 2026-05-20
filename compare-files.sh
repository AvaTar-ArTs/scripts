#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Get all .md files in the directory
files=(*.md)

# Loop through each file and compare it with every other file
for i in "${!files[@]}"; do
    for j in "${!files[@]}"; do
        if [ $i -lt $j ]; then
            echo "Comparing ${files[$i]} and ${files[$j]}"
            diff "${files[$i]}" "${files[$j]}"
            echo "-----------------------------------"
        fi
    done
done
