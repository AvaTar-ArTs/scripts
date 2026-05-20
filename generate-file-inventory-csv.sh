#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Define the source directories
SOURCE_DIRS=(
    "/Users/Steven/Documents"
    "/Users/Steven/Pictures"
    "/Users/Steven/Movies"
    "/Users/Steven/Music"
    "/Users/Steven/Downloads"
    "/Users/Steven/Desktop"
    "/Users/Steven/Library" # User-specific library
    "/Applications"
    "/Library"
    "/usr/local"
)

CSV_PATH="/Users/steven/Documents/script/backups"

# Function to generate a CSV for organizing files
generate_csv() {
    directories=("$@")
    echo "File Path" > "$CSV_PATH"

    # Regex patterns for exclusions
    excluded_patterns=(
        '^\..*'  # Hidden files and directories
        '.*\/venv\/.*'  # venv directories
        '.*\/\.venv\/.*'  # .venv directories
        '.*\/my_global_venv\/.*'  # venv directories
        '.*\/simplegallery\/.*'
        '.*\/avatararts\/.*'
        '.*\/github\/.*'
        '.*\/Documents\/gitHub\/.*'  # Specific gitHub directory
        '.*\/\.my_global_venv\/.*'  # .venv directories
        '.*\/node\/.*'  # Any directory named node
        '.*\/Movies\/capcut\/.*'
        '.*\/miniconda3\/.*'
        '.*\/Movies\/movavi\/.*'
        '.*\/env\/.*'  # env directories
        '.*\/\.env\/.*'  # .env directories
        '.*\/Library\/.*'  # Library directories
        '.*\/\.config\/.*'  # .config directories
        '.*\/\.spicetify\/.*'  # .spicetify directories
        '.*\/\.gem\/.*'  # .gem directories
        '.*\/\.zprofile\/.*'  # .zprofile directories
        '^.*\/\..*'  # Any file or directory starting with a dot
    )

    for DIR in "${directories[@]}"; do
        if [ -d "$DIR" ]; then
            find "$DIR" -type f | while read FILE; do
                exclude=false
                for pattern in "${excluded_patterns[@]}"; do
                    if [[ $FILE =~ $pattern ]]; then
                        exclude=true
                        break
                    fi
                done
                if [ "$exclude" = false ]; then
                    echo "$FILE" >> "$CSV_PATH"
                fi
            done
        fi
    done

    echo "CSV file created at $CSV_PATH"
}

# Generate CSV file with file list
generate_csv "${SOURCE_DIRS[@]}"
