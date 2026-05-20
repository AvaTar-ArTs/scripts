#!/usr/bin/env bash
set -euo pipefail

export CARBON_RECURSIVE="${CARBON_RECURSIVE:-1}"
export CARBON_LIMIT="${CARBON_LIMIT:-10}"
export CARBON_ENGINES="${CARBON_ENGINES:-chromium firefox webkit}"
export CARBON_RETRIES="${CARBON_RETRIES:-2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/carbon-batch-v2.sh" "$@"
