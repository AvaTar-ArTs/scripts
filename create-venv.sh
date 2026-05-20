#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


if [ -z "$1" ]; then
    echo "Usage: create_venv.sh <env_name>"
    exit 1
fi

ENV_NAME=$1
python3 -m venv ~/.virtualenvs/$ENV_NAME
source ~/.virtualenvs/$ENV_NAME/bin/activate

echo "Created and activated virtual environment: $ENV_NAME"
