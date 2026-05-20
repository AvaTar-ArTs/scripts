#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_SCRIPT="$SCRIPT_DIR/carbon-automation-v3.sh"

if [ ! -x "$NEXT_SCRIPT" ]; then
    NEXT_SCRIPT="$SCRIPT_DIR/archive-old/carbon-automation-v3.sh"
fi

export CARBON_RECURSIVE="${CARBON_RECURSIVE:-1}"
export CARBON_LIMIT="${CARBON_LIMIT:-10}"
export CARBON_MAX_LINES="${CARBON_MAX_LINES:-600}"
export CARBON_INCLUDE_HIDDEN="${CARBON_INCLUDE_HIDDEN:-0}"
export CARBON_OPTIMIZE_IMAGES="${CARBON_OPTIMIZE_IMAGES:-0}"

if "$NEXT_SCRIPT" "$@"; then
    if [ "$CARBON_OPTIMIZE_IMAGES" = "1" ]; then
        if [ -x "$SCRIPT_DIR/carbon_image_analyze_optimize.sh" ]; then
            "$SCRIPT_DIR/carbon_image_analyze_optimize.sh" "${CARBON_OUTPUT_DIR:-/Users/steven/Pictures/carbon-images}"
        elif [ -x "$SCRIPT_DIR/archive-old/carbon_image_analyze_optimize.sh" ]; then
            "$SCRIPT_DIR/archive-old/carbon_image_analyze_optimize.sh" "${CARBON_OUTPUT_DIR:-/Users/steven/Pictures/carbon-images}"
        fi
    fi
fi
