#!/bin/bash

# Enable strict error handling
set -eu

# Log all outputs
exec > >(tee "script.log") 2>&1

# Function to run a script
run_script() {
    local script_path="$1"
    echo "Running $script_path"
    
    if python3 "$script_path"; then
        echo "Successfully ran $script_path"
    else
        echo "Failed to run $script_path"
        exit 1
    fi
}

# List of scripts to run (config.py holds SOURCE_DIRECTORY)
scripts=(
    '/Users/steven/clean/audio.py'
    '/Users/steven/clean/docs.py'
    '/Users/steven/clean/img.py'
    '/Users/steven/clean/other.py'
    '/Users/steven/clean/vids.py'
)

# Trap exit and errors
trap 'echo "An error occurred. Exiting..."' ERR

# Run each script in the list
for script in "${scripts[@]}"; do
    run_script "$script"
done
