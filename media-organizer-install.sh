#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Installation script for Media File Organizer Scripts

echo "=== Media File Organizer Installation ==="
echo

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Check if pip is available
if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    echo "❌ pip is not installed. Please install pip first."
    exit 1
fi

# Use pip3 if available, otherwise use pip
if command -v pip3 &> /dev/null; then
    PIP_CMD="pip3"
else
    PIP_CMD="pip"
fi

echo "✓ pip found: $PIP_CMD"

# Install requirements
echo
echo "Installing Python dependencies..."
$PIP_CMD install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✓ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Make scripts executable
echo
echo "Making scripts executable..."
chmod +x run_all.py
chmod +x test_setup.py
chmod +x vids/vids.py
chmod +x audio/audio_combined.py
chmod +x img/img_combined.py
chmod +x docs/docs_combined.py

echo "✓ Scripts made executable"

# Run test
echo
echo "Running setup test..."
python3 test_setup.py

if [ $? -eq 0 ]; then
    echo
    echo "🎉 Installation completed successfully!"
    echo
    echo "Usage:"
    echo "  python3 run_all.py --list          # List available scripts"
    echo "  python3 run_all.py --script videos # Run video organizer"
    echo "  python3 run_all.py                 # Run all scripts"
    echo
    echo "For more information, see README.md"
else
    echo
    echo "❌ Setup test failed. Please check the errors above."
    exit 1
fi
