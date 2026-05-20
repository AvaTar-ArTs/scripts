#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Run Black
echo "Running Black..."
black ~/pythons

# Run Flake8
echo "Running Flake8..."
flake8 ~/pythons

# Run isort
echo "Running isort..."
isort ~/pythons

# Run Pylint
echo "Running Pylint..."
pylint ~/pythons

# Run Radon for complexity analysis
echo "Running Radon..."
radon cc ~/pythons

# Run Mypy for type checking
echo "Running Mypy..."
mypy ~/pythons

echo "All checks completed!"
