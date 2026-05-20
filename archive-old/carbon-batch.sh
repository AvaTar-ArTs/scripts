#!/usr/bin/env bash
set -euo pipefail

# ---- Normalize PATH for Automator/Platypus ----
# Intel Homebrew
if [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
# Apple Silicon Homebrew
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# Common global npm locations
export PATH="$HOME/.npm-global/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# nvm (if present)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    set +e
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    set -e
fi
# Yarn global (optional)
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# ----------------------------------------------

if ! command -v carbon-now >/dev/null 2>&1; then
    echo "❌ carbon-now-cli not found in PATH."
    echo "   Install with: brew install node && npm i -g carbon-now-cli"
    exit 1
fi

PRESET="${PRESET:-steven-preset}"
OUTDIR="${OUTDIR:-/Users/steven/Pictures/carbon-images}"
FORMAT="${FORMAT:-png}"
EXPORT="${EXPORT:-2x}"
LANG="${LANG:-python}"
PROMPT_FOR_SOURCE_DIR="${PROMPT_FOR_SOURCE_DIR:-1}"
CARBON_SKIP_DISPLAY="${CARBON_SKIP_DISPLAY:-1}"
CARBON_DISPLAY_ARGS=()
if [ "$CARBON_SKIP_DISPLAY" = "1" ]; then
    CARBON_DISPLAY_ARGS=(--skip-display)
fi

mkdir -p "$OUTDIR"

collect_inputs() {
    local source_dir="${1:-}"

    if [ -z "$source_dir" ]; then
        return 0
    fi

    source_dir="${source_dir/#\~/$HOME}"
    if [ ! -d "$source_dir" ]; then
        echo "⚠️  Source folder not found: $source_dir"
        return 1
    fi

    shopt -s nullglob
    inputs=( "$source_dir"/* )
    shopt -u nullglob
}

if [ "$#" -eq 0 ]; then
    if [ "$PROMPT_FOR_SOURCE_DIR" = "1" ] && [ -t 0 ]; then
        printf "Code source folder: "
        read -r source_dir
        inputs=()
        collect_inputs "$source_dir" || exit 1
        if [ "${#inputs[@]}" -eq 0 ]; then
            echo "No files found in source folder: $source_dir"
            exit 0
        fi
        set -- "${inputs[@]}"
    else
        echo "Drop files or folders onto the app / Quick Action, or pass paths as arguments."
        exit 0
    fi
fi

count_ok=0
count_skip=0
render_targets=()
for f in "$@"; do
    if [ -d "$f" ]; then
        shopt -s nullglob
        dir_files=( "$f"/* )
        shopt -u nullglob
        if [ "${#dir_files[@]}" -eq 0 ]; then
            echo "⚠️  Skip (empty folder): $f"
            ((count_skip++)) || true
            continue
        fi
        render_targets+=( "${dir_files[@]}" )
        continue
    fi

    render_targets+=( "$f" )
done

for f in "${render_targets[@]}"; do
    if [ ! -f "$f" ]; then
        echo "⚠️  Skip (not found): $f"
        ((count_skip++)) || true
        continue
    fi

    echo "▶︎ Rendering: $f"
    if carbon-now "$f" \
        --preset "$PRESET" \
        --language "$LANG" \
        --type "$FORMAT" \
        --export-size "$EXPORT" \
        --save-to "$OUTDIR" \
        "${CARBON_DISPLAY_ARGS[@]}" \
        --title "$(basename "$f")"; then
        ((count_ok++)) || true
    else
        echo "⚠️  Failed: $f"
        ((count_skip++)) || true
    fi
done

echo "✅ Done. Rendered: $count_ok | Skipped: $count_skip"
echo "📁 Output: $OUTDIR"
