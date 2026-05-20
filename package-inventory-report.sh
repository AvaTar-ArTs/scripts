#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# package_info.sh

OUTPUT_FILE="package_installs.txt"

{
  echo "=========================="
  echo "Homebrew Packages"
  echo "=========================="
  if command -v brew >/dev/null; then
    echo "-- Installed Formulae --"
    brew list
    echo ""
    echo "-- Outdated Formulae --"
    brew outdated
  else
    echo "Homebrew not installed."
  fi

  echo ""
  echo "=========================="
  echo "pip (Python Packages)"
  echo "=========================="
  if command -v pip3 >/dev/null; then
    echo "-- pip3 List (Columns) --"
    pip3 list --format=columns
  elif command -v pip >/dev/null; then
    echo "-- pip List (Columns) --"
    pip list --format=columns
  else
    echo "pip not installed."
  fi

  echo ""
  echo "=========================="
  echo "Python Details"
  echo "=========================="
  if command -v python3 >/dev/null; then
    echo "-- Python Version --"
    python3 -V
    echo ""
    echo "-- pip freeze Output (Installed Packages) --"
    python3 -m pip freeze
  elif command -v python >/dev/null; then
    echo "-- Python Version --"
    python -V
    echo ""
    echo "-- pip freeze Output (Installed Packages) --"
    python -m pip freeze
  else
    echo "Python not installed."
  fi

  echo ""
  echo "=========================="
  echo "npm (Global Packages)"
  echo "=========================="
  if command -v npm >/dev/null; then
    npm list -g --depth=0
  else
    echo "npm not installed."
  fi

  echo ""
  echo "=========================="
  echo "Conda / Miniconda3 Packages"
  echo "=========================="
  if command -v conda >/dev/null; then
    echo "-- Conda Info --"
    conda info
    echo ""
    echo "-- Conda List --"
    conda list
  else
    echo "Conda (Miniconda3) not installed."
  fi
} > "${OUTPUT_FILE}"

echo "Package installer information saved to ${OUTPUT_FILE}"
