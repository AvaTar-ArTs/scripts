#!/usr/bin/env bash

set -euo pipefail

# Shared Carbon renderer for the v2+ wrappers.

CARBON_OUTPUT_DIR="${CARBON_OUTPUT_DIR:-/Users/steven/Pictures/carbon-images}"
CARBON_PRESET="${CARBON_PRESET:-steven-preset}"
CARBON_PRESET_FILE="${CARBON_PRESET_FILE:-$HOME/.carbon-now.json}"
CARBON_FORMAT="${CARBON_FORMAT:-png}"
CARBON_EXPORT_SIZE="${CARBON_EXPORT_SIZE:-2x}"
CARBON_LANGUAGE="${CARBON_LANGUAGE:-python}"
CARBON_ENGINES="${CARBON_ENGINES:-chromium firefox webkit}"
CARBON_RETRIES="${CARBON_RETRIES:-2}"
CARBON_SKIP_DISPLAY="${CARBON_SKIP_DISPLAY:-1}"
CARBON_QUIET="${CARBON_QUIET:-1}"
CARBON_DISABLE_HEADLESS="${CARBON_DISABLE_HEADLESS:-0}"
CARBON_TIMEOUT_SECONDS="${CARBON_TIMEOUT_SECONDS:-75}"
CARBON_SUMMARY_FILE="${CARBON_SUMMARY_FILE:-$CARBON_OUTPUT_DIR/carbon_run_summary.tsv}"
CARBON_LOG_DIR="${CARBON_LOG_DIR:-$CARBON_OUTPUT_DIR/logs}"

normalize_path() {
    local path="$1"
    printf '%s\n' "${path/#\~/$HOME}"
}

carbon_normalize_path() {
    normalize_path "$1"
}

carbon_setup_path() {
    if [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    export PATH="$HOME/.npm-global/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        set +e
        # shellcheck source=/dev/null
        . "$HOME/.nvm/nvm.sh"
        set -e
    fi

    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
}

carbon_require_cli() {
    carbon_setup_path

    if ! command -v carbon-now >/dev/null 2>&1; then
        echo "carbon-now-cli not found. Install with: npm i -g carbon-now-cli" >&2
        return 1
    fi
}

carbon_create_preset() {
    mkdir -p "$(dirname "$CARBON_PRESET_FILE")"

    python3 - "$CARBON_PRESET_FILE" "$CARBON_PRESET" <<'PY'
import json
import os
import sys

preset_file, preset_name = sys.argv[1:3]
preset = {
    "theme": "one-dark",
    "windowTheme": "none",
    "fontFamily": "Hack",
    "fontSize": "18px",
    "backgroundColor": "#ADB7C1",
    "windowControls": True,
    "widthAdjustment": True,
    "lineNumbers": True,
    "firstLineNumber": 1,
    "exportSize": "2x",
    "watermark": False,
}

data = {}
if os.path.exists(preset_file) and os.path.getsize(preset_file) > 0:
    with open(preset_file, "r", encoding="utf-8") as fh:
        data = json.load(fh)

data[preset_name] = preset
tmp_file = f"{preset_file}.tmp"
with open(tmp_file, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
os.replace(tmp_file, preset_file)
PY
}

carbon_init_run() {
    mkdir -p "$CARBON_OUTPUT_DIR" "$CARBON_LOG_DIR"

    if [ ! -f "$CARBON_SUMMARY_FILE" ]; then
        printf 'timestamp\tstatus\tfile\toutput_name\tengine\tattempt\tduration_seconds\tmessage\n' > "$CARBON_SUMMARY_FILE"
    fi
}

carbon_sanitize_name() {
    local name="$1"
    name="${name%.*}"
    printf '%s\n' "$name" | tr ' /:' '___' | tr -cd '[:alnum:]_.-'
}

carbon_run_with_timeout() {
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$CARBON_TIMEOUT_SECONDS" carbon-now "$@"
    elif command -v timeout >/dev/null 2>&1; then
        timeout "$CARBON_TIMEOUT_SECONDS" carbon-now "$@"
    else
        carbon-now "$@"
    fi
}

carbon_log_summary() {
    local status="$1"
    local file="$2"
    local output_name="$3"
    local engine="$4"
    local attempt="$5"
    local duration="$6"
    local message="$7"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$status" \
        "$file" \
        "$output_name" \
        "$engine" \
        "$attempt" \
        "$duration" \
        "$message" >> "$CARBON_SUMMARY_FILE"
}

carbon_render_file() {
    local file="$1"
    local output_name="${2:-}"
    local language="${3:-$CARBON_LANGUAGE}"

    if [ ! -f "$file" ]; then
        echo "Skip missing file: $file"
        carbon_log_summary "skip" "$file" "$output_name" "-" "-" "0" "missing file"
        return 1
    fi

    if [ -z "$output_name" ]; then
        output_name=$(carbon_sanitize_name "$(basename "$file")")
    fi

    local attempt
    local engine
    local start_time
    local duration
    local attempt_log
    local last_error="unknown error"

    for attempt in $(seq 1 "$CARBON_RETRIES"); do
        for engine in $CARBON_ENGINES; do
            start_time=$(date +%s)
            attempt_log=$(mktemp "${TMPDIR:-/tmp}/carbon-render.XXXXXX.log")

            cmd=(
                "$file"
                --save-to "$CARBON_OUTPUT_DIR"
                --save-as "$output_name"
                --preset "$CARBON_PRESET"
                --language "$language"
                --type "$CARBON_FORMAT"
                --export-size "$CARBON_EXPORT_SIZE"
                --engine "$engine"
            )

            if [ "$CARBON_SKIP_DISPLAY" = "1" ]; then
                cmd+=(--skip-display)
            fi

            if [ "$CARBON_QUIET" = "1" ]; then
                cmd+=(--quiet)
            fi

            if [ "$CARBON_DISABLE_HEADLESS" = "1" ]; then
                cmd+=(--disable-headless)
            fi

            if carbon_run_with_timeout "${cmd[@]}" > "$attempt_log" 2>&1; then
                duration=$(( $(date +%s) - start_time ))
                cp "$attempt_log" "$CARBON_LOG_DIR/${output_name}.${engine}.ok.log"
                rm -f "$attempt_log"
                echo "Rendered: $file -> $output_name.$CARBON_FORMAT (engine=$engine attempt=$attempt)"
                carbon_log_summary "ok" "$file" "$output_name.$CARBON_FORMAT" "$engine" "$attempt" "$duration" "rendered"
                return 0
            fi

            duration=$(( $(date +%s) - start_time ))
            last_error=$(tail -n 8 "$attempt_log" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
            cp "$attempt_log" "$CARBON_LOG_DIR/${output_name}.${engine}.failed-attempt-${attempt}.log"
            rm -f "$attempt_log"
            echo "Retryable failure: $file (engine=$engine attempt=$attempt): $last_error"
            carbon_log_summary "retry" "$file" "$output_name" "$engine" "$attempt" "$duration" "$last_error"
        done
    done

    echo "Failed: $file"
    carbon_log_summary "failed" "$file" "$output_name" "-" "$CARBON_RETRIES" "0" "$last_error"
    return 1
}
