#!/bin/bash

# setup_environment.sh
# Enhanced: Automates Mambaforge environment setup, system updates, 
# MySites directory provisioning, dependency installation, and prompt initialization.

set -e

echo "--- Initializing Environment Setup ---"

# 1. Update/Setup Mambaforge
if ! command -v mamba &> /dev/null; then
    echo "Mamba not found. Please install Mambaforge first."
    exit 1
fi

echo "Updating Mamba..."
mamba update -n base -c conda-forge mamba -y

# 2. Setup Project Environment
echo "Creating/Updating project environment..."
mamba env create -f environment.yml --force || echo "No environment.yml found, skipping env creation."

# 3. Provision MySites Infrastructure
echo "Provisioning MySites directories..."
mkdir -p "$HOME/MySites/thumbnails"

# 4. Install Dependencies
echo "Installing thumbnail generation dependencies..."
pip install playwright
playwright install chromium

# 5. Prompt Initialization
echo "Setting up workspace prompts..."
PROMPT_DIR="$HOME/.local/share/project-prompts"
mkdir -p "$PROMPT_DIR"

cat <<EOF > "$PROMPT_DIR/default_coding_prompt.txt"
You are an expert software engineer. Follow project conventions, prioritize type safety, and maintain idiomatic code structure.
EOF

cat <<EOF > "$PROMPT_DIR/mysites_dashboard_prompt.txt"
When working with MySites dashboards, ensure all paths are relative, prioritize CSS Grid layouts for responsiveness, and use lazy-loading for iframes.
EOF

echo "Environment, MySites infrastructure, and prompts successfully configured."
