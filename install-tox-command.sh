#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


pip install pipenv
pipenv install --dev --skip-lock
