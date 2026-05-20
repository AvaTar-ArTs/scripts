#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
exec npx "$@"
