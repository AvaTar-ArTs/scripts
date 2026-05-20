#!/usr/bin/env bash

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

# List of scripts to run
scripts=(
    '/Users/steven/clean/clean-organizer/audio.py'
    '/Users/steven/clean/clean-organizer/config.py'
    '/Users/steven/clean/clean-organizer/docs.py'
    '/Users/steven/clean/clean-organizer/img.py'
    '/Users/steven/clean/clean-organizer/other.py'
    '/Users/steven/clean/clean-organizer/vids.py'
)

# Trap exit and errors
trap 'echo "An error occurred. Exiting..."' ERR

# Run each script in the list
for script in "${scripts[@]}"; do
    run_script "$script"
done
