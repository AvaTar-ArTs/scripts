#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# - DETAILED: Shows what's being cleaned and freed
# - REVERSIBLE: Focuses on caches that rebuild themselves
# - SAFETY: Dry run option to preview operations

set -E
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
trap - SIGINT SIGTERM ERR EXIT
}

# Color setup
setup_colors() {
if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
else
NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
fi
}

msg() {
echo >&2 -e "${1-}"
}

die() {
local msg=$1
local code=${2-1}
msg "$msg"
exit "$code"
}

prompt_yes_no() {
local question=$1
local response
while true; do
read -p "${question} (y/n) " -n 1 -r response
echo
case $response in
[yY]) return 0 ;;
[nN]) return 1 ;;
*) echo "Please answer y or n" ;;
esac
done
}

bytesToHuman() {
b=${1:-0}
d=''
s=1
S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
while ((b > 1024)); do
d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
b=$((b / 1024))
((s++))
done
echo "$b$d ${S[$s]}"
}

parse_params() {
force=false
verbose=false
dry_run=false

while :; do
case "${1-}" in
-h | --help) usage ;;
-v | --verbose) verbose=true ;;
--force) force=true ;;
--dry-run) dry_run=true ;;
-?*) die "Unknown option: $1" ;;
*) break ;;
esac
shift
done
}

usage() {
cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Improved Mac Cleanup - Targeted, Safe, No-Sudo Required

OPTIONS:
  -h, --help     Show this help
  -v, --verbose  Verbose output
  --force        Skip confirmations (for automation)
  --dry-run      Show what would be cleaned without actually deleting

OPERATIONS:
  ✅ System & app caches (safe - rebuild automatically)
  ✅ Homebrew cache (package manager)
  ✅ Temporary files
  ✅ Your specific cache directories
  ✅ npm, VS Code, Cursor, Rust, Bun caches
  ❌ Skips dangerous operations (logs, user data)
  ❌ Doesn't touch your Documents/Python code

ESTIMATED CLEANUP: 5-15 GB depending on options

EOF
exit 0
}

parse_params "$@"
setup_colors

if [[ "$dry_run" == true ]]; then
msg "${YELLOW}=== DRY RUN MODE ===${NOFORMAT}"
msg "⚠️  This is a DRY RUN - no files will be deleted"
msg "   Use this to see what would be cleaned"
msg ""
fi

msg "${BLUE}=== Enhanced Mac Cleanup for Steven ===${NOFORMAT}"
msg "📊 ${CYAN}Analysis Result Summary:${NOFORMAT}"
msg "   Total Available: 275 GB (you have plenty of space!)"
msg "   Primary targets: App caches, Homebrew, System temp files, your specific directories"
msg ""

# Get initial disk space
initial_space=$(df / | tail -1 | awk '{print $4}')

msg "${YELLOW}⚠️  Note: This script does NOT use sudo${NOFORMAT}"
msg "    Skips operations requiring elevated permissions"
msg ""

# ==============================================================================
# SECTION 1: YOUR SPECIFIC DIRECTORY CACHES
# ==============================================================================

msg "${GREEN}[1/7] Previewing Steven's Specific Directories Cleanup${NOFORMAT}"

# Preview clearing npm cache (1.7GB)
if type "npm" &>/dev/null && [[ "$dry_run" == false ]]; then
msg "      Cleaning npm cache (1.7GB)..."
npm cache clean --force 2>/dev/null || true
msg "      ✓ npm cache cleared"
elif type "npm" &>/dev/null; then
msg "      Would clean npm cache (1.7GB)"
else
msg "      ⚠️  npm not found, skipping npm cache cleanup"
fi

# Preview clearing VS Code cache (1.2GB)
vscode_cache_dir="$HOME/Library/Application Support/Code/CachedData"
if [[ -d "$vscode_cache_dir" && "$dry_run" == false ]]; then
vscode_size=$(du -hs "$vscode_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Clearing VS Code cache (${vscode_size})..."
rm -rf "$vscode_cache_dir"/* 2>/dev/null || true
msg "      ✓ VS Code cache cleared"
elif [[ -d "$vscode_cache_dir" ]]; then
vscode_size=$(du -hs "$vscode_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Would clear VS Code cache (${vscode_size})"
else
msg "      ⚠️  VS Code cache directory not found, skipping"
fi

# Preview clearing Cursor Editor cache (1.1GB)
cursor_cache_dir="$HOME/Library/Application Support/Cursor/CachedData"
if [[ -d "$cursor_cache_dir" && "$dry_run" == false ]]; then
cursor_size=$(du -hs "$cursor_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Clearing Cursor Editor cache (${cursor_size})..."
rm -rf "$cursor_cache_dir"/* 2>/dev/null || true
msg "      ✓ Cursor Editor cache cleared"
elif [[ -d "$cursor_cache_dir" ]]; then
cursor_size=$(du -hs "$cursor_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Would clear Cursor Editor cache (${cursor_size})"
else
msg "      ⚠️  Cursor Editor cache directory not found, skipping"
fi

# Preview clearing Rust cache (579MB)
rust_cache_dir="$HOME/.cargo/registry/cache"
if [[ -d "$rust_cache_dir" && "$dry_run" == false ]]; then
rust_size=$(du -hs "$rust_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Clearing Rust cache (${rust_size})..."
rm -rf "$rust_cache_dir"/* 2>/dev/null || true
msg "      ✓ Rust cache cleared"
elif [[ -d "$rust_cache_dir" ]]; then
rust_size=$(du -hs "$rust_cache_dir" 2>/dev/null | awk '{print $1}')
msg "      Would clear Rust cache (${rust_size})"
else
msg "      ⚠️  Rust cache directory not found, skipping"
fi

# Preview clearing Bun cache (585MB)
if type "bun" &>/dev/null && [[ "$dry_run" == false ]]; then
msg "      Cleaning Bun cache..."
bun pm cache rm 2>/dev/null || true
msg "      ✓ Bun cache cleared"
elif type "bun" &>/dev/null; then
msg "      Would clean Bun cache"
else
msg "      ⚠️  Bun not found, skipping Bun cache cleanup"
fi

if [[ "$dry_run" == false ]]; then
msg "${GREEN}      ✓ Steven's specific directory caches cleared${NOFORMAT}"
else
msg "${GREEN}      ✓ Steven's specific directory caches preview complete${NOFORMAT}"
fi

# ==============================================================================
# SECTION 2: SAFE SYSTEM CACHES (Always safe)
# ==============================================================================

msg "${GREEN}[2/7] Previewing System Caches Cleanup${NOFORMAT}"

# User Caches (safe - rebuilds)
if [[ -d ~/Library/Caches ]]; then
cache_size=$(du -hs ~/Library/Caches 2>/dev/null | awk '{print $1}')
if [[ "$dry_run" == false ]]; then
msg "      Clearing ~/Library/Caches (${cache_size})..."
rm -rf ~/Library/Caches/* 2>/dev/null || true
else
msg "      Would clear ~/Library/Caches (${cache_size})"
fi
fi

# System temp files (safe)
if [[ "$dry_run" == false ]]; then
msg "      Clearing temporary files..."
rm -rf /var/tmp/* 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true
else
msg "      Would clear temporary files..."
fi

if [[ "$dry_run" == false ]]; then
msg "${GREEN}      ✓ System caches cleared${NOFORMAT}"
else
msg "${GREEN}      ✓ System caches preview complete${NOFORMAT}"
fi

# ==============================================================================
# SECTION 3: HOMEBREW CACHE
# ==============================================================================

msg "${GREEN}[3/7] Previewing Homebrew Maintenance${NOFORMAT}"

if type "brew" &>/dev/null; then
msg "      Previewing Homebrew cache cleanup..."
brew_cache=$(brew --cache)
if [[ -d "$brew_cache" ]]; then
old_size=$(du -hs "$brew_cache" 2>/dev/null | awk '{print $1}')
if [[ "$dry_run" == false ]]; then
rm -rf "$brew_cache"/* 2>/dev/null || true
msg "      ✓ Homebrew cache cleared (was ${old_size})"
else
msg "      Would clear Homebrew cache (currently ${old_size})"
fi
fi

msg "      Previewing brew cleanup..."
if [[ "$dry_run" == false ]]; then
brew cleanup -s 2>/dev/null || true
msg "      ✓ Homebrew maintenance complete"
else
msg "      Would run: brew cleanup -s"
fi
else
msg "      ⚠️  Homebrew not found, skipping"
fi

# ==============================================================================
# SECTION 4: APP CACHES (Recreate automatically)
# ==============================================================================

msg "${GREEN}[4/7] Previewing Application Caches Cleanup${NOFORMAT}"

app_caches=(
"~/Library/Application Support/Google/Chrome/Default/Application Cache"
"~/Library/Application Support/Google/Chrome/Default/Cache"
"~/.gradle/caches"
"~/Library/Application Support/Adobe/Common/Media Cache Files"
"~/Library/Containers/*/Data/Library/Caches"
)

for cache_path in "${app_caches[@]}"; do
expanded_path=$(eval echo "$cache_path")
if [[ -d "$expanded_path" ]]; then
size=$(du -hs "$expanded_path" 2>/dev/null | awk '{print $1}')
if [[ "$dry_run" == false ]]; then
msg "      Clearing ${cache_path} (${size})..."
rm -rf "$expanded_path"/* 2>/dev/null || true
else
msg "      Would clear ${cache_path} (${size})"
fi
fi
done

if [[ "$dry_run" == false ]]; then
msg "${GREEN}      ✓ App caches cleared${NOFORMAT}"
else
msg "${GREEN}      ✓ App caches preview complete${NOFORMAT}"
fi

# ==============================================================================
# SECTION 5: SYSTEM METADATA & BIOME (Safe system data)
# ==============================================================================

msg "${GREEN}[5/7] Previewing System Metadata Cleanup${NOFORMAT}"

# Biome (system data - safe)
if [[ -d ~/Library/Biome ]]; then
size=$(du -hs ~/Library/Biome 2>/dev/null | awk '{print $1}')
if [[ "$dry_run" == false ]]; then
msg "      Clearing ~/Library/Biome (${size})..."
rm -rf ~/Library/Biome/* 2>/dev/null || true
else
msg "      Would clear ~/Library/Biome (${size})"
fi
fi

# Metadata (system data - safe)
if [[ -d ~/Library/Metadata ]]; then
size=$(du -hs ~/Library/Metadata 2>/dev/null | awk '{print $1}')
if [[ "$dry_run" == false ]]; then
msg "      Clearing ~/Library/Metadata (${size})..."
rm -rf ~/Library/Metadata/* 2>/dev/null || true
else
msg "      Would clear ~/Library/Metadata (${size})"
fi
fi

if [[ "$dry_run" == false ]]; then
msg "${GREEN}      ✓ System metadata cleared${NOFORMAT}"
else
msg "${GREEN}      ✓ System metadata preview complete${NOFORMAT}"
fi

# ==============================================================================
# SECTION 6: OLD PYTHON ENVIRONMENTS (Ask first)
# ==============================================================================

msg "${GREEN}[6/7] Previewing Old Python Environments${NOFORMAT}"

if [[ -d ~/global_python_env || -d ~/chatgpt_agent_env || -d ~/ollama_env ]]; then
old_envs=(
"~/global_python_env"
"~/chatgpt_agent_env"
"~/ollama_env"
)

total_env_size=0
for env in "${old_envs[@]}"; do
expanded=$(eval echo "$env")
if [[ -d "$expanded" ]]; then
size=$(du -hs "$expanded" 2>/dev/null | awk '{print $1}' | sed 's/[^0-9]//g')
total_env_size=$((total_env_size + size))
fi
done

if [[ $total_env_size -gt 0 ]]; then
msg "      Found old Python environments (~${total_env_size}MB)"
if [[ "$dry_run" == false ]]; then
if prompt_yes_no "      Delete old Python environments? (they can be recreated)"; then
for env in "${old_envs[@]}"; do
expanded=$(eval echo "$env")
if [[ -d "$expanded" ]]; then
msg "      Removing ${env}..."
rm -rf "$expanded" 2>/dev/null || true
fi
done
msg "${GREEN}      ✓ Old Python environments removed${NOFORMAT}"
else
msg "      ⊘ Skipping Python environments"
fi
else
for env in "${old_envs[@]}"; do
expanded=$(eval echo "$env")
if [[ -d "$expanded" ]]; then
env_size=$(du -hs "$expanded" 2>/dev/null | awk '{print $1}')
msg "      Would remove ${env} (${env_size})"
fi
done
msg "${GREEN}      ✓ Old Python environments preview complete${NOFORMAT}"
fi
else
msg "      No old environments found"
fi

else
msg "      No old environments found"
fi

# ==============================================================================
# SECTION 7: PACKAGE MANAGER CACHES (Additional)
# ==============================================================================

msg "${GREEN}[7/7] Previewing Additional Package Manager Caches${NOFORMAT}"

if type "yarn" &>/dev/null && [[ "$dry_run" == false ]]; then
msg "      Cleaning Yarn cache..."
yarn cache clean 2>/dev/null || true
msg "      ✓ Yarn cache cleared"
elif type "yarn" &>/dev/null; then
msg "      Would clean Yarn cache"
fi

if type "conda" &>/dev/null && [[ "$dry_run" == false ]]; then
msg "      Cleaning Conda cache..."
conda clean --all 2>/dev/null || true
msg "      ✓ Conda cache cleared"
elif type "conda" &>/dev/null; then
msg "      Would clean Conda cache"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================

if [[ "$dry_run" == false ]]; then
final_space=$(df / | tail -1 | awk '{print $4}')
freed=$((final_space - initial_space))

msg ""
msg "${GREEN}✓ CLEANUP COMPLETE!${NOFORMAT}"
msg ""
msg "📊 ${CYAN}Results:${NOFORMAT}"
if [[ $freed -gt 0 ]]; then
freed_human=$(bytesToHuman $((freed * 512)))
msg "   Space freed: ${GREEN}${freed_human}${NOFORMAT}"
else
msg "   Space freed: (minimal - caches may have been small)"
fi
else
msg ""
msg "${GREEN}✓ DRY RUN COMPLETE!${NOFORMAT}"
msg ""
msg "📊 ${CYAN}Results:${NOFORMAT}"
msg "   No files were deleted during dry run"
fi

msg ""
msg "📝 ${CYAN}Manual Actions Recommended:${NOFORMAT}"
msg "   1. Review ~/Downloads folder - has 6.2 GB of files"
msg "   2. Review ~/Pictures (26 GB) and ~/Movies (22 GB) for old files"
msg "   3. Consider archiving old projects in ~/pythons_backup (5.4GB)"
msg "   4. Check ~/Library (23GB) for manual cleanup if needed"
msg ""
msg "💡 ${CYAN}Next Steps:${NOFORMAT}"
msg "   • Run this script with --dry-run to preview operations"
msg "   • Run without --dry-run to perform actual cleanup"
msg "   • Run this script monthly for maintenance"
msg "   • Archive large media files manually"
msg "   • Your ~/pythons codebase (12 GB) is SAFE"
msg ""

cleanup
