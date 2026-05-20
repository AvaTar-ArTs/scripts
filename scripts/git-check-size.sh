#!/usr/bin/env bash

# File size limit in bytes (e.g., 50MB = 52428800)
LIMIT=52428800

# Get a list of staged files
files=$(git diff --cached --name-only --diff-filter=ACM)

for file in $files; do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file")
        if [ "$size" -gt "$LIMIT" ]; then
            echo "Error: File $file is too large ($(du -sh "$file" | cut -f1))."
            echo "Please use Git LFS or reduce the file size before committing."
            exit 1
        fi
    fi
done
