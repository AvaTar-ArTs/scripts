#!/usr/bin/env bash
set -euo pipefail

export CARBON_RECURSIVE="${CARBON_RECURSIVE:-1}"
export CARBON_LIMIT="${CARBON_LIMIT:-10}"
export CARBON_MAX_LINES="${CARBON_MAX_LINES:-600}"
export CARBON_INCLUDE_HIDDEN="${CARBON_INCLUDE_HIDDEN:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/carbon-automation-v2.sh" "$@"
