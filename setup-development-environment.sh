#!/bin/bash
set -euo pipefail
echo "Setting up development environment..."

# Update brew
brew update && brew upgrade

# Install core tools
brew bundle --file=- <<EOF
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"

# Dev tools
brew "git"
brew "gh"
brew "python"
brew "node"
brew "docker"
brew "colima"

# Terminal enhancements
brew "tmux"
brew "zsh"
brew "fzf"
brew "bat"
brew "exa"
brew "fd"
brew "ripgrep"
brew "jq"
brew "yq"

# AI/ML tools
brew "ollama"
cask "miniconda"
EOF

echo "Installation complete!"
