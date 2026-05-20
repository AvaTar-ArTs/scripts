#!/usr/bin/env bash
# mac-cleanup-pro.sh - Post-update cleanup for macOS (run after updater-pro.sh)
# Cleans Homebrew, Yarn, Python bytecode, and common caches to free disk space.
#
# Scope (including ~/):
#   - Homebrew: cleanup -s, autoremove (no sudo)
#   - Yarn/npm/pip/Bun: cache clear only
#   - Python: .pyc and __pycache__ under ~/Library/Caches, ~/.local, ~/Library/Python,
#             ~/.cache, ~/miniforge3, /usr/local, /opt/homebrew (no recursion into ~/projects)
#   - Extra caches (if present): Mamba/Conda, UV, cargo-cache, pnpm store
#   - Does NOT wipe ~/Library/Caches entirely (use enhanced_cleanup.sh for that)
#
# Tuned for ~/ with miniforge, mamba, uv, and common JS/Python tooling.
# Compare: CLEANUP_SCRIPTS_COMPARISON.md in this directory.

set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Post-update cleanup: Homebrew, Yarn, npm, pip, Bun caches + Python .pyc."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help"
    echo "  -v, --verbose  Show commands and extra detail (what it's doing)"
    echo "  --dry-run      Show what would be done without deleting anything"
    echo ""
    exit 0
}

DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
    case "$arg" in
        -h|--help)    usage ;;
        -v|--verbose) VERBOSE=true ;;
        --dry-run)    DRY_RUN=true ;;
    esac
done

# Colors
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
CLEAR='\033[0m'

# Progress: 7 steps (Homebrew, Yarn, Python, npm, pip, Bun, Extra caches)
readonly TOTAL_STEPS=7
readonly PROGRESS_WIDTH=12
# Batch size for .pyc removal (avoids huge -exec; shows live progress)
readonly PYC_BATCH_SIZE=500

# Print progress bar and step label. Usage: progress_step <current> <total> <emoji> <label>
progress_step() {
    local current=$1
    local total=$2
    local emoji=$3
    local label=$4
    local filled=$(( PROGRESS_WIDTH * current / total ))
    local empty=$(( PROGRESS_WIDTH - filled ))
    local bar=""
    local i
    for (( i = 0; i < filled; i++ )); do bar+="█"; done
    for (( i = 0; i < empty; i++ )); do bar+="░"; done
    echo -e "${BOLD}  [${bar}]  ${current}/${total}  ${CYAN}${emoji} ${label}${CLEAR}"
}

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
}

# Live spinner (background). spinner_start "msg" or spinner_start_cycling "msg1|msg2|msg3".
spinner_pid=""
spinner_start() {
    local msg="$1"
    (
        local chars=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
        while true; do
            for c in "${chars[@]}"; do
                printf "\r  ${CYAN}%s${CLEAR}  %s    " "$c" "$msg"
                sleep 0.1
            done
        done
    ) &
    spinner_pid=$!
}
# Cycle through messages (pipe-separated) so user sees what's happening.
spinner_start_cycling() {
    local msg_pipe="$1"
    (
        local chars=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
        local idx=0
        local num_msgs
        local msg
        local -a msgs=()
        IFS='|' read -ra msgs <<< "$msg_pipe"
        num_msgs=${#msgs[@]}
        [[ $num_msgs -eq 0 ]] && msgs=( "Working..." ) && num_msgs=1
        while true; do
            for c in "${chars[@]}"; do
                msg="${msgs[idx]}"
                printf "\r  \033[36m%s\033[0m  %s    " "$c" "$msg"
                sleep 0.15
            done
            idx=$(( (idx + 1) % num_msgs ))
        done
    ) &
    spinner_pid=$!
}
spinner_stop() {
    if [[ -n "${spinner_pid:-}" ]]; then
        kill "$spinner_pid" 2>/dev/null || true
        wait "$spinner_pid" 2>/dev/null || true
        printf "\r\033[K"
        spinner_pid=""
    fi
}

# Show what we're about to do (always), and optionally the command (when VERBOSE).
print_doing() {
    local doing="$1"
    local cmd="${2:-}"
    echo -e "  ${BOLD}▶${CLEAR} ${CYAN}${doing}${CLEAR}"
    if [[ "$VERBOSE" == true && -n "$cmd" ]]; then
        echo -e "  ${YELLOW}→ ${cmd}${CLEAR}"
    fi
}
# Print step completion with elapsed time.
print_step_done() {
    local elapsed=$1
    local msg="$2"
    echo -e "  ${GREEN}✓${CLEAR} ${msg} ${BLUE}(${elapsed}s)${CLEAR}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Don't run as root (avoid accidental system-wide cleanup)
if [[ $(id -u) -eq 0 ]]; then
    print_status "$YELLOW" "⚠️  Do not run this script as root. Exiting."
    exit 1
fi

echo ""
print_status "$BOLD" "🧹 Mac Cleanup Pro — post-update cleanup"
print_status "$BLUE" "=========================================="
[[ "$DRY_RUN" == true ]] && print_status "$YELLOW" "   (dry run — no files will be removed)"
echo ""

start_time=$(date +%s)
summary=()

progress_step 0 "$TOTAL_STEPS" "🚀" "Starting..."
echo ""

# --- Homebrew ---
progress_step 1 "$TOTAL_STEPS" "📦" "Homebrew cleanup..."
step_start=$(date +%s)
if command_exists brew; then
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Would run: brew cleanup -s && brew autoremove"
        summary+=( "Homebrew (would run)" )
    else
        print_doing "Pruning old formulae and scrubbing cache" "brew cleanup -s"
        spinner_start_cycling "Pruning old formulae...|Scrubbing package cache...|Removing dead symlinks..."
        brew_out=$(brew cleanup -s 2>&1) || true
        spinner_stop
        echo "$brew_out" | grep -iE "pruned|freed|cleaned|removed|files removed|directories removed" | grep -iv "sorbet|backtrace|rerun with" || true
        print_doing "Removing unused dependencies" "brew autoremove"
        spinner_start "Autoremove..."
        brew autoremove 2>&1 | grep -iv "sorbet\|backtrace\|rerun with" || true
        spinner_stop
        step_elapsed=$(($(date +%s) - step_start))
        print_step_done "$step_elapsed" "Homebrew: formulae and cache cleaned"
        summary+=( "Homebrew ✓" )
    fi
else
    print_status "$YELLOW" "   Homebrew not found, skipping"
fi
echo ""

# --- Yarn ---
progress_step 2 "$TOTAL_STEPS" "📦" "Yarn cache..."
step_start=$(date +%s)
if command_exists yarn; then
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Would run: yarn cache clean"
        summary+=( "Yarn (would run)" )
    else
        print_doing "Clearing Yarn global cache" "yarn cache clean"
        spinner_start "Clearing cache..."
        yarn cache clean 2>/dev/null
        spinner_stop
        step_elapsed=$(($(date +%s) - step_start))
        print_step_done "$step_elapsed" "Yarn cache cleared"
        summary+=( "Yarn ✓" )
    fi
else
    print_status "$YELLOW" "   Yarn not found, skipping"
fi
echo ""

# --- Python bytecode (.pyc / __pycache__) in caches and ~/ ---
progress_step 3 "$TOTAL_STEPS" "🐍" "Python bytecode cleanup..."
step_start=$(date +%s)
pyc_roots=(
    "$HOME/Library/Caches"
    "$HOME/.local"
    "$HOME/Library/Python"
    "$HOME/.cache"
    "$HOME/miniforge3"
    "/usr/local"
    "/opt/homebrew"
)
# Build list of existing readable roots (one find over all roots = faster)
pyc_roots_exist=()
for root in "${pyc_roots[@]}"; do
    [[ -d "$root" ]] && [[ -r "$root" ]] && pyc_roots_exist+=( "$root" )
done
pyc_count=0
if [[ ${#pyc_roots_exist[@]} -gt 0 ]]; then
    if [[ "$VERBOSE" == true ]]; then
        print_doing "Scanning roots: ${pyc_roots_exist[*]}"
    fi
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Counting .pyc and *.cpython-*.pyc in cache and lib roots"
        spinner_start_cycling "Scanning ~/Library/Caches...|Scanning ~/.local...|Scanning ~/Library/Python...|Scanning system Python..."
        pyc_count=$(find "${pyc_roots_exist[@]}" -type f \( -name "*.pyc" -o -name "*.cpython-*.pyc" \) 2>/dev/null | wc -l | tr -d ' ')
        spinner_stop
    else
        print_doing "Removing .pyc in batches of ${PYC_BATCH_SIZE} (then empty __pycache__)" "find ... -print0 | batch rm"
        pyc_count=0
        batch=()
        while IFS= read -r -d '' f; do
            batch+=( "$f" )
            if (( ${#batch[@]} >= PYC_BATCH_SIZE )); then
                rm -f "${batch[@]}" 2>/dev/null || true
                pyc_count=$((pyc_count + ${#batch[@]}))
                printf "\r  ${CYAN}⠋${CLEAR}  Removed %d .pyc files...    " "$pyc_count"
                batch=()
            fi
        done < <(find "${pyc_roots_exist[@]}" -type f \( -name "*.pyc" -o -name "*.cpython-*.pyc" \) -print0 2>/dev/null)
        if (( ${#batch[@]} > 0 )); then
            rm -f "${batch[@]}" 2>/dev/null || true
            pyc_count=$((pyc_count + ${#batch[@]}))
        fi
        printf "\r\033[K"
        print_doing "Removing empty __pycache__ dirs"
        spinner_start "Cleaning __pycache__..."
        find "${pyc_roots_exist[@]}" -type d -name "__pycache__" -empty -delete 2>/dev/null || true
        spinner_stop
    fi
fi
step_elapsed=$(($(date +%s) - step_start))
if [[ "$pyc_count" -gt 0 ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        print_status "$YELLOW" "   Would remove $pyc_count .pyc files (and empty __pycache__ dirs)"
        summary+=( "Python $pyc_count files (would remove)" )
    else
        print_step_done "$step_elapsed" "Python: removed $pyc_count .pyc files (and empty __pycache__)"
        summary+=( "Python $pyc_count files ✓" )
    fi
else
    print_step_done "$step_elapsed" "Python: no bytecode to remove"
    summary+=( "Python 0 files" )
fi
echo ""

# --- npm ---
progress_step 4 "$TOTAL_STEPS" "📦" "npm cache..."
step_start=$(date +%s)
if command_exists npm; then
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Would run: npm cache clean --force"
        summary+=( "npm (would run)" )
    else
        print_doing "Clearing npm cache" "npm cache clean --force"
        spinner_start "Clearing cache..."
        npm cache clean --force 2>/dev/null
        spinner_stop
        step_elapsed=$(($(date +%s) - step_start))
        print_step_done "$step_elapsed" "npm cache cleared"
        summary+=( "npm ✓" )
    fi
else
    print_status "$YELLOW" "   npm not found, skipping"
fi
echo ""

# --- pip cache ---
progress_step 5 "$TOTAL_STEPS" "📦" "pip cache..."
step_start=$(date +%s)
if command_exists pip3 || command_exists pip; then
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Would run: pip cache purge"
        summary+=( "pip (would run)" )
    else
        print_doing "Purging pip HTTP/wheel cache" "pip cache purge"
        spinner_start "Purging cache..."
        if command_exists pip3 && pip3 cache purge 2>/dev/null; then
            spinner_stop
            step_elapsed=$(($(date +%s) - step_start))
            print_step_done "$step_elapsed" "pip cache purged"
            summary+=( "pip ✓" )
        elif command_exists pip && pip cache purge 2>/dev/null; then
            spinner_stop
            step_elapsed=$(($(date +%s) - step_start))
            print_step_done "$step_elapsed" "pip cache purged"
            summary+=( "pip ✓" )
        else
            spinner_stop
        fi
    fi
fi
echo ""

# --- Bun cache ---
progress_step 6 "$TOTAL_STEPS" "📦" "Bun cache..."
step_start=$(date +%s)
if command_exists bun; then
    if [[ "$DRY_RUN" == true ]]; then
        print_doing "Would run: bun pm cache rm"
        summary+=( "Bun (would run)" )
    else
        print_doing "Removing Bun package cache" "bun pm cache rm"
        spinner_start "Clearing cache..."
        bun pm cache rm 2>/dev/null
        spinner_stop
        step_elapsed=$(($(date +%s) - step_start))
        print_step_done "$step_elapsed" "Bun cache cleared"
        summary+=( "Bun ✓" )
    fi
else
    print_status "$YELLOW" "   Bun not found, skipping"
fi
echo ""

# --- Extra caches (Mamba/Conda, UV, cargo-cache, pnpm) - only if present ---
progress_step 7 "$TOTAL_STEPS" "🧹" "Extra caches (Mamba/UV/Rust/pnpm)..."
step_start=$(date +%s)
extra_done=()
if [[ "$DRY_RUN" == true ]]; then
    command_exists mamba && print_doing "Would run: mamba clean --all -y" && extra_done+=( "mamba (would run)" )
    command_exists conda && ! command_exists mamba && print_doing "Would run: conda clean --all -y" && extra_done+=( "conda (would run)" )
    command_exists uv && print_doing "Would run: uv cache clean" && extra_done+=( "uv (would run)" )
    command_exists cargo-cache && print_doing "Would run: cargo cache -a" && extra_done+=( "cargo-cache (would run)" )
    command_exists pnpm && print_doing "Would run: pnpm store prune" && extra_done+=( "pnpm (would run)" )
    command_exists deno && print_doing "Would run: deno clean" && extra_done+=( "deno (would run)" )
    [[ ${#extra_done[@]} -eq 0 ]] && print_status "$YELLOW" "   No extra cache tools found"
else
    if command_exists mamba; then
        print_doing "Cleaning Mamba package cache" "mamba clean --all -y"
        spinner_start "Mamba clean..."
        mamba clean --all -y 2>/dev/null || true
        spinner_stop
        extra_done+=( "Mamba ✓" )
    elif command_exists conda; then
        print_doing "Cleaning Conda package cache" "conda clean --all -y"
        spinner_start "Conda clean..."
        conda clean --all -y 2>/dev/null || true
        spinner_stop
        extra_done+=( "Conda ✓" )
    fi
    if command_exists uv; then
        print_doing "Cleaning UV cache" "uv cache clean"
        spinner_start "UV cache..."
        uv cache clean 2>/dev/null || true
        spinner_stop
        extra_done+=( "UV ✓" )
    fi
    if command_exists cargo-cache; then
        print_doing "Cleaning Cargo registry cache" "cargo cache -a"
        spinner_start "Cargo cache..."
        cargo cache -a 2>/dev/null || true
        spinner_stop
        extra_done+=( "Cargo ✓" )
    fi
    if command_exists pnpm; then
        print_doing "Pruning pnpm store" "pnpm store prune"
        spinner_start "pnpm store..."
        pnpm store prune 2>/dev/null || true
        spinner_stop
        extra_done+=( "pnpm ✓" )
    fi
    if command_exists deno; then
        print_doing "Cleaning Deno cache" "deno clean"
        spinner_start "Deno clean..."
        deno clean 2>/dev/null || true
        spinner_stop
        extra_done+=( "Deno ✓" )
    fi
    [[ ${#extra_done[@]} -eq 0 ]] && print_status "$YELLOW" "   No extra cache tools found (mamba/conda, uv, cargo-cache, pnpm, deno)"
fi
step_elapsed=$(($(date +%s) - step_start))
if [[ ${#extra_done[@]} -gt 0 ]]; then
    print_step_done "$step_elapsed" "Extra: ${extra_done[*]}"
    summary+=( "Extra ${extra_done[*]}" )
fi
echo ""

# --- Summary ---
progress_step "$TOTAL_STEPS" "$TOTAL_STEPS" "🎉" "Done"
end_time=$(date +%s)
duration=$((end_time - start_time))
print_status "$BOLD" "=========================================="
if [[ "$DRY_RUN" == true ]]; then
    print_status "$YELLOW" "🔍 Dry run complete. Summary: ${summary[*]:-none}"
else
    print_status "$GREEN" "🎉 Cleanup completed. Summary: ${summary[*]:-none}"
fi
print_status "$BLUE" "   ⏱️  Total duration: ${duration}s"
echo ""
echo -e "  ${BOLD}What we did:${CLEAR}"
echo -e "  ${CYAN}•${CLEAR} Homebrew: old formulae pruned, cache scrubbed, autoremove"
echo -e "  ${CYAN}•${CLEAR} Yarn / npm / pip / Bun: caches cleared"
echo -e "  ${CYAN}•${CLEAR} Python: .pyc and empty __pycache__ (incl. miniforge3) in batch"
echo -e "  ${CYAN}•${CLEAR} Extra (if present): Mamba/Conda, UV, cargo-cache, pnpm store, deno"
echo ""
exit 0
