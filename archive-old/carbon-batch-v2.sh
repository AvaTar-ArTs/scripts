#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/carbon-render-common-v2.sh"

PROMPT_FOR_SOURCE_DIR="${PROMPT_FOR_SOURCE_DIR:-1}"
CARBON_RECURSIVE="${CARBON_RECURSIVE:-0}"
CARBON_LIMIT="${CARBON_LIMIT:-0}"
CARBON_EXTENSIONS="${CARBON_EXTENSIONS:-py sh js ts md json}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [files-or-folders...]

Environment:
  CARBON_OUTPUT_DIR=$CARBON_OUTPUT_DIR
  CARBON_PRESET=$CARBON_PRESET
  CARBON_ENGINES="$CARBON_ENGINES"
  CARBON_RETRIES=$CARBON_RETRIES
  CARBON_LIMIT=$CARBON_LIMIT
  CARBON_RECURSIVE=$CARBON_RECURSIVE
  CARBON_EXTENSIONS="$CARBON_EXTENSIONS"
EOF
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

append_file_if_allowed() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 0
    fi

    if extension_allowed "$file"; then
        printf '%s\n' "$file" >> "$target_file"
    fi
}

collect_folder() {
    local folder="$1"

    if [ "$CARBON_RECURSIVE" = "1" ]; then
        find "$folder" -type f -print0 | while IFS= read -r -d '' file; do
            append_file_if_allowed "$file"
        done
    else
        find "$folder" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
            append_file_if_allowed "$file"
        done
    fi
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

carbon_require_cli
carbon_create_preset
carbon_init_run

target_file=$(mktemp "${TMPDIR:-/tmp}/carbon-targets.XXXXXX")
trap 'rm -f "$target_file"' EXIT

if [ "$#" -eq 0 ]; then
    if [ "$PROMPT_FOR_SOURCE_DIR" = "1" ] && [ -t 0 ]; then
        printf "Code source folder: "
        read -r source_dir
        set -- "$(carbon_normalize_path "$source_dir")"
    else
        usage
        exit 0
    fi
fi

for input in "$@"; do
    input=$(carbon_normalize_path "$input")

    if [ -d "$input" ]; then
        collect_folder "$input"
    else
        append_file_if_allowed "$input"
    fi
done

if [ "$CARBON_LIMIT" -gt 0 ]; then
    limited_file=$(mktemp "${TMPDIR:-/tmp}/carbon-targets-limited.XXXXXX")
    head -n "$CARBON_LIMIT" "$target_file" > "$limited_file"
    mv "$limited_file" "$target_file"
fi

count_ok=0
count_failed=0
count_seen=0

while IFS= read -r file; do
    [ -n "$file" ] || continue
    count_seen=$((count_seen + 1))
    output_name=$(carbon_sanitize_name "$(basename "$file")")

    if carbon_render_file "$file" "$output_name" "$CARBON_LANGUAGE"; then
        count_ok=$((count_ok + 1))
    else
        count_failed=$((count_failed + 1))
    fi
done < "$target_file"

echo "Done. Seen: $count_seen | Rendered: $count_ok | Failed: $count_failed"
echo "Output: $CARBON_OUTPUT_DIR"
echo "Summary: $CARBON_SUMMARY_FILE"
