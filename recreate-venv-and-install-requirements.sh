#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

rm -rf venv
python3 -m venv venv && source venv/bin/activate && python3 -m pip install -r requirements.txt
