#!/usr/bin/env bash
# Regenerate selected Carbon images with known-good presets.

set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-/Users/steven/scripts}"
OUTPUT_DIR="${OUTPUT_DIR:-/Users/steven/Pictures/carbon-images/regenerated}"
PRESET_FILE="${PRESET_FILE:-$HOME/.carbon-now.json}"

echo "Regenerating Carbon images with optimized presets..."

if ! command -v carbon-now >/dev/null 2>&1; then
    echo "carbon-now-cli is not installed. Install it with: npm i -g carbon-now-cli"
    exit 1
fi

mkdir -p "$OUTPUT_DIR" "$(dirname "$PRESET_FILE")"

python3 - "$PRESET_FILE" <<'PY'
import json
import os
import sys

preset_file = sys.argv[1]
presets = {
    "web-optimized": {
        "theme": "one-dark",
        "windowTheme": "none",
        "fontFamily": "Hack",
        "fontSize": "14px",
        "backgroundColor": "#ADB7C1",
        "windowControls": True,
        "widthAdjustment": True,
        "lineNumbers": True,
        "firstLineNumber": 1,
        "exportSize": "1x",
        "watermark": False,
        "dropShadow": True,
        "dropShadowOffsetY": "10px",
        "dropShadowBlurRadius": "20px",
        "paddingVertical": "24px",
        "paddingHorizontal": "24px",
        "lineHeight": "140%",
    },
    "print-optimized": {
        "theme": "one-dark",
        "windowTheme": "none",
        "fontFamily": "Hack",
        "fontSize": "12px",
        "backgroundColor": "#282C34",
        "windowControls": False,
        "widthAdjustment": True,
        "lineNumbers": True,
        "firstLineNumber": 1,
        "exportSize": "2x",
        "watermark": False,
        "dropShadow": False,
        "paddingVertical": "16px",
        "paddingHorizontal": "16px",
        "lineHeight": "130%",
    },
    "social-optimized": {
        "theme": "dracula-pro",
        "windowTheme": "none",
        "fontFamily": "JetBrains Mono",
        "fontSize": "16px",
        "backgroundColor": "#282A36",
        "windowControls": False,
        "widthAdjustment": True,
        "lineNumbers": False,
        "firstLineNumber": 1,
        "exportSize": "2x",
        "watermark": False,
        "dropShadow": True,
        "dropShadowOffsetY": "15px",
        "dropShadowBlurRadius": "30px",
        "paddingVertical": "32px",
        "paddingHorizontal": "32px",
        "lineHeight": "150%",
    },
    "minimal": {
        "theme": "one-dark",
        "windowTheme": "none",
        "fontFamily": "Hack",
        "fontSize": "12px",
        "backgroundColor": "#282C34",
        "windowControls": False,
        "widthAdjustment": True,
        "lineNumbers": False,
        "firstLineNumber": 1,
        "exportSize": "1x",
        "watermark": False,
        "dropShadow": False,
        "paddingVertical": "12px",
        "paddingHorizontal": "12px",
        "lineHeight": "120%",
    },
}

data = {}
if os.path.exists(preset_file) and os.path.getsize(preset_file) > 0:
    with open(preset_file, "r", encoding="utf-8") as fh:
        data = json.load(fh)

data.update(presets)

tmp_file = f"{preset_file}.tmp"
with open(tmp_file, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
os.replace(tmp_file, preset_file)
PY

regenerate_with_preset() {
    local source_file=$1
    local preset=$2
    local output_name=$3

    echo "Regenerating $source_file with $preset preset..."

    carbon-now "$source_file" \
        --save-to "$OUTPUT_DIR" \
        --save-as "$output_name" \
        --preset "$preset" \
        --type png \
        --skip-display
}

find_source() {
    local stem=$1
    find "$SOURCE_DIR" -type f \( -name "$stem.sh" -o -name "$stem.py" -o -name "$stem.js" -o -name "$stem.ts" \) | head -1
}

for stem in carbon-automation carbon-batch carbon_image_analyze_optimize; do
    source_file=$(find_source "$stem")
    if [ -z "$source_file" ]; then
        echo "Source file not found for $stem; skipping."
        continue
    fi

    regenerate_with_preset "$source_file" "web-optimized" "${stem}_web"
done

echo "Carbon regeneration complete: $OUTPUT_DIR"
