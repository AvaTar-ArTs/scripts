#!/bin/bash
set -euo pipefail

# Create backup directories if they don't exist
BREW_BACKUP_DIR="$HOME/brew_backup"
PYTHON_BACKUP_DIR="$HOME/python_backup"
NEW_VENV_DIR="$HOME/new_python_env"
mkdir -p "$BREW_BACKUP_DIR"
mkdir -p "$PYTHON_BACKUP_DIR"

# Backup Brew packages
echo "Backing up Brew packages..."
brew list > "$BREW_BACKUP_DIR/brew_formulae_list.txt"
brew list --cask > "$BREW_BACKUP_DIR/brew_cask_list.txt"

# Backup Python packages
echo "Backing up Python packages..."
python3 -m pip freeze > "$PYTHON_BACKUP_DIR/python3_packages_list.txt"

echo "Backup completed."

# Cleanup Homebrew
echo "Cleaning up Homebrew..."
brew cleanup
brew autoremove --dry-run
brew autoremove

# Setup new Python environment
echo "Setting up a new Python virtual environment..."
python3 -m venv "$NEW_VENV_DIR"
source "$NEW_VENV_DIR/bin/activate"
pip install -r "$PYTHON_BACKUP_DIR/python3_packages_list.txt"

echo "New virtual environment created and packages installed from backup."
echo "Cleanup and setup completed."
