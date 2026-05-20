#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the source directory
read -p "Enter source directory containing .mp4 files: " source_dir

# Check if the source directory exists
if [[ ! -d "$source_dir" ]]; then
  echo "The directory '$source_dir' does not exist."
  exit 1
fi

# Function to activate conda environment
activate_conda_env() {
  # Check if conda is installed by loading the conda.sh script
  if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    echo "Conda not found. Please ensure Miniconda is installed."
    exit 1
  fi

  # Activate the media_tools environment
  conda activate media_tools
  if [[ $? -ne 0 ]]; then
    echo "Environment 'media_tools' activation failed."
    exit 1
  fi
}

# Activate the conda environment
activate_conda_env

# Find all .mp4 files in the specified directory
find "$source_dir" -type f -name "*.mp4" | while read -r file; do
  # Extract directory and base name of the file
  dir=$(dirname "$file")
  base=$(basename "$file" .mp4)

  # Output mp3 file path
  output="${dir}/${base}.mp3"

  # Check if the output mp3 already exists, and skip conversion if it does
  if [[ -f "$output" ]]; then
    echo "Skipping conversion for '$file'; output '$output' already exists."
    continue
  fi

  # Convert to mp3 using ffmpeg
  ffmpeg -i "$file" -q:a 0 "$output"
  echo "Converted '$file' to '$output'."
done

# Deactivate the conda environment; gracefully handle potential failure
conda deactivate 2>/dev/null || echo "Conda was not activated, or there was an issue with deactivation."
