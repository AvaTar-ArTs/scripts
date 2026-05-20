#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/carbon-render-common-v2.sh"

INPUT_DIR="${INPUT_DIR:-/Users/steven/pythons}"
CARBON_EXTENSIONS="${CARBON_EXTENSIONS:-py}"
CARBON_LIMIT="${CARBON_LIMIT:-0}"
CARBON_RECURSIVE="${CARBON_RECURSIVE:-0}"
CARBON_MIN_LINES="${CARBON_MIN_LINES:-1}"
CARBON_MAX_LINES="${CARBON_MAX_LINES:-800}"
CARBON_INCLUDE_HIDDEN="${CARBON_INCLUDE_HIDDEN:-0}"
OVERWRITE="${OVERWRITE:-0}"
PROMPT_FOR_INPUT_DIR="${PROMPT_FOR_INPUT_DIR:-1}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -i, --input DIR       Source folder (default: $INPUT_DIR)
  -o, --output DIR      Output folder (default: $CARBON_OUTPUT_DIR)
  -t, --types LIST      Extensions, space or comma separated (default: $CARBON_EXTENSIONS)
  --limit N             Render only first N eligible files
  --recursive           Recurse into source folder
  --force               Regenerate existing output names
  --no-prompt           Disable source-folder prompt
  -h, --help            Show this help
EOF
}

require_option_value() {
    local option="$1"
    local value="${2:-}"

    if [[ -z "$value" || "$value" == -* ]]; then
        echo "$option requires a value" >&2
        exit 1
    fi
}

extension_allowed() {
    local file="$1"
    local ext="${file##*.}"
    local allowed

    for allowed in $CARBON_EXTENSIONS; do
        if [ "$ext" = "${allowed#.}" ]; then
            return 0
        fi
    done

    return 1
}

file_line_count() {
    awk 'NF { count++ } END { print count + 0 }' "$1"
}

should_render_file() {
    local file="$1"
    local lines

    if [ "$CARBON_INCLUDE_HIDDEN" != "1" ] && [[ "$file" == */.*/* ]]; then
        echo "hidden path"
        return 1
    fi

    case "$file" in
        */node_modules/*|*/vendor/*|*/dist/*|*/build/*|*/__pycache__/*|*/.git/*)
            echo "generated or dependency path"
            return 1
            ;;
    esac

    if ! extension_allowed "$file"; then
        echo "extension not selected"
        return 1
    fi

    lines=$(file_line_count "$file")
    if [ "$lines" -lt "$CARBON_MIN_LINES" ]; then
        echo "too small ($lines lines)"
        return 1
    fi

    if [ "$lines" -gt "$CARBON_MAX_LINES" ]; then
        echo "too large ($lines lines)"
        return 1
    fi

    echo "eligible ($lines lines)"
    return 0
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -i|--input)
            require_option_value "$1" "${2:-}"
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output)
            require_option_value "$1" "${2:-}"
            CARBON_OUTPUT_DIR="$2"
            shift 2
            ;;
        -t|--types)
            require_option_value "$1" "${2:-}"
            CARBON_EXTENSIONS="${2//,/ }"
            shift 2
            ;;
        --limit)
            require_option_value "$1" "${2:-}"
            CARBON_LIMIT="$2"
            shift 2
            ;;
        --recursive)
            CARBON_RECURSIVE=1
            shift
            ;;
        --force)
            OVERWRITE=1
            shift
            ;;
        --no-prompt)
            PROMPT_FOR_INPUT_DIR=0
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [ "$PROMPT_FOR_INPUT_DIR" = "1" ] && [ -t 0 ]; then
    printf "Code source folder [%s]: " "$INPUT_DIR"
    read -r entered_dir
    if [ -n "$entered_dir" ]; then
        INPUT_DIR="$entered_dir"
    fi
fi

INPUT_DIR=$(carbon_normalize_path "$INPUT_DIR")
CARBON_OUTPUT_DIR=$(carbon_normalize_path "$CARBON_OUTPUT_DIR")
CARBON_SUMMARY_FILE="${CARBON_SUMMARY_FILE:-$CARBON_OUTPUT_DIR/carbon_run_summary.tsv}"
CARBON_LOG_DIR="${CARBON_LOG_DIR:-$CARBON_OUTPUT_DIR/logs}"

if [ ! -d "$INPUT_DIR" ]; then
    echo "Input directory not found: $INPUT_DIR" >&2
    exit 1
fi

carbon_require_cli
carbon_create_preset
carbon_init_run

target_file=$(mktemp "${TMPDIR:-/tmp}/carbon-automation-targets.XXXXXX")
trap 'rm -f "$target_file"' EXIT

if [ "$CARBON_RECURSIVE" = "1" ]; then
    find "$INPUT_DIR" -type f -print0 > "$target_file.raw"
else
    find "$INPUT_DIR" -maxdepth 1 -type f -print0 > "$target_file.raw"
fi

count_seen=0
count_attempted=0
count_rendered=0
count_failed=0
count_skipped=0

while IFS= read -r -d '' file; do
    count_seen=$((count_seen + 1))

    reason=$(should_render_file "$file") || {
        echo "Skip: $file ($reason)"
        count_skipped=$((count_skipped + 1))
        continue
    }

    if [ "$CARBON_LIMIT" -gt 0 ] && [ "$count_attempted" -ge "$CARBON_LIMIT" ]; then
        break
    fi

    output_name=$(carbon_sanitize_name "$(basename "$file")")
    if [ "$OVERWRITE" != "1" ] && [ -f "$CARBON_OUTPUT_DIR/$output_name.$CARBON_FORMAT" ]; then
        echo "Skip existing: $CARBON_OUTPUT_DIR/$output_name.$CARBON_FORMAT"
        count_skipped=$((count_skipped + 1))
        continue
    fi

    count_attempted=$((count_attempted + 1))
    echo "Render: $file ($reason)"
    if carbon_render_file "$file" "$output_name" "$CARBON_LANGUAGE"; then
        count_rendered=$((count_rendered + 1))
    else
        count_failed=$((count_failed + 1))
    fi
done < "$target_file.raw"

rm -f "$target_file.raw"

echo "Done. Seen: $count_seen | Attempted: $count_attempted | Rendered: $count_rendered | Failed: $count_failed | Skipped: $count_skipped"
echo "Output: $CARBON_OUTPUT_DIR"
echo "Summary: $CARBON_SUMMARY_FILE"
