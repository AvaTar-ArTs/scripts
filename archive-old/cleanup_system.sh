#!/usr/bin/env bash

# Exit immediately if any command exits with a non-zero status,
# treat unset variables as errors, and capture failures in pipelines
set -euo pipefail

# This script cleans up Homebrew packages, pip, Conda, npm, and Yarn

# Function to log messages
log() {
  echo "[INFO] $1"
}

# Function to handle errors
error() {
  echo "[ERROR] $1"
}

# 1. Homebrew Cleanup
if command -v brew &> /dev/null; then
  log "Updating Homebrew..."
  brew update
  
  log "Upgrading Homebrew packages..."
  brew upgrade
  
  log "Cleaning up Homebrew..."
  brew cleanup
  
  if brew autoremove &> /dev/null; then
    log "Removing unused Homebrew dependencies..."
    brew autoremove
  fi
else
  error "Homebrew not found. Skipping Homebrew cleanup."
fi

# 2. Python pip cleanup
if command -v pip3 &> /dev/null; then
  log "Upgrading pip..."
  pip3 install --upgrade pip
  
  log "Cleaning up pip cache..."
  pip3 cache purge 2>/dev/null || true
else
  log "pip3 not found. Skipping pip cleanup."
fi

# 3. Conda cleanup (if installed)
if command -v conda &> /dev/null; then
  log "Cleaning up Conda..."
  conda clean --all --yes 2>/dev/null || true
else
  log "Conda not found. Skipping Conda cleanup."
fi

# 4. npm cleanup
if command -v npm &> /dev/null; then
  log "Cleaning up npm cache..."
  npm cache clean --force 2>/dev/null || true
else
  log "npm not found. Skipping npm cleanup."
fi

# 5. Yarn cleanup
if command -v yarn &> /dev/null; then
  log "Cleaning up Yarn cache..."
  yarn cache clean 2>/dev/null || true
else
  log "Yarn not found. Skipping Yarn cleanup."
fi

log "System cleanup complete!"
