#!/usr/bin/env bash
set -euo pipefail

# Detect conda or suggest Miniforge
if ! command -v conda >/dev/null 2>&1; then
  echo "Conda not found. Installing Miniforge (conda-forge first) for macOS Intel..."
  curl -L -o Miniforge3-MacOSX-x86_64.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
  bash Miniforge3-MacOSX-x86_64.sh -b -p $HOME/miniforge3
  eval "$($HOME/miniforge3/bin/conda shell.bash hook)"
  conda init "$(basename $SHELL)"
  echo "Restart your shell or run: source ~/.bashrc or ~/.zshrc"
  echo "Then re-run this script."
  exit 0
else
  echo "Conda found."
fi

# Ensure conda-forge is highest priority and strict
conda config --add channels conda-forge || true
conda config --set channel_priority strict

# Create/update environment
conda env create -f environment.yml || conda env update -f environment.yml --prune

echo "Done. Activate with: conda activate opusclip"
echo "Then run: make run"
