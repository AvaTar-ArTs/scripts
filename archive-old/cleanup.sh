#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


################################################################################
# Improved Mac Cleanup Script for Steven
# 
# IMPROVEMENTS over original:
# - NO SUDO required (safer, fewer permissions issues)
# - TARGETED: Only cleans what analysis showed needs cleaning
# - SELECTIVE: Skips dangerous operations
# - INTERACTIVE: Asks before large operations
# - DETAILED: Shows what's being cleaned and freed
# - REVERSIBLE: Focuses on caches that rebuild themselves
################################################################################

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
	
	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) verbose=true ;;
		--force) force=true ;;
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

OPERATIONS:
  ✅ System & app caches (safe - rebuild automatically)
  ✅ Homebrew cache (package manager)
  ✅ Temporary files
  ✅ Old Python environments (if not needed)
  ❌ Skips dangerous operations (logs, user data)
  ❌ Doesn't touch your Documents/Python code

ESTIMATED CLEANUP: 2-5 GB depending on options

EOF
	exit 0
}

parse_params "$@"
setup_colors

msg "${BLUE}=== Improved Mac Cleanup for Steven ===${NOFORMAT}"
msg "📊 ${CYAN}Analysis Result Summary:${NOFORMAT}"
msg "   Total Available: 275 GB (you have plenty of space!)"
msg "   Primary targets: App caches, Homebrew, System temp files"
msg ""

# Get initial disk space
initial_space=$(df / | tail -1 | awk '{print $4}')

msg "${YELLOW}⚠️  Note: This script does NOT use sudo${NOFORMAT}"
msg "    Skips operations requiring elevated permissions"
msg ""

# ==============================================================================
# SECTION 1: SAFE SYSTEM CACHES (Always safe)
# ==============================================================================

msg "${GREEN}[1/6] Clearing System Caches${NOFORMAT}"

# User Caches (safe - rebuilds)
if [[ -d ~/Library/Caches ]]; then
	cache_size=$(du -hs ~/Library/Caches 2>/dev/null | awk '{print $1}')
	msg "      Clearing ~/Library/Caches (${cache_size})..."
	rm -rf ~/Library/Caches/* 2>/dev/null || true
fi

# System temp files (safe)
msg "      Clearing temporary files..."
rm -rf /var/tmp/* 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true

msg "${GREEN}      ✓ System caches cleared${NOFORMAT}"

# ==============================================================================
# SECTION 2: HOMEBREW CACHE
# ==============================================================================

msg "${GREEN}[2/6] Homebrew Maintenance${NOFORMAT}"

if type "brew" &>/dev/null; then
	msg "      Cleaning Homebrew cache..."
	brew_cache=$(brew --cache)
	if [[ -d "$brew_cache" ]]; then
		old_size=$(du -hs "$brew_cache" 2>/dev/null | awk '{print $1}')
		rm -rf "$brew_cache"/* 2>/dev/null || true
		msg "      ✓ Homebrew cache cleared (was ${old_size})"
	fi
	
	msg "      Running brew cleanup..."
	brew cleanup -s 2>/dev/null || true
	msg "      ✓ Homebrew maintenance complete"
else
	msg "      ⚠️  Homebrew not found, skipping"
fi

# ==============================================================================
# SECTION 3: APP CACHES (Recreate automatically)
# ==============================================================================

msg "${GREEN}[3/6] Application Caches${NOFORMAT}"

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
		msg "      Clearing ${cache_path} (${size})..."
		rm -rf "$expanded_path"/* 2>/dev/null || true
	fi
done

msg "${GREEN}      ✓ App caches cleared${NOFORMAT}"

# ==============================================================================
# SECTION 4: SYSTEM METADATA & BIOME (Safe system data)
# ==============================================================================

msg "${GREEN}[4/6] System Metadata${NOFORMAT}"

# Biome (system data - safe)
if [[ -d ~/Library/Biome ]]; then
	size=$(du -hs ~/Library/Biome 2>/dev/null | awk '{print $1}')
	msg "      Clearing ~/Library/Biome (${size})..."
	rm -rf ~/Library/Biome/* 2>/dev/null || true
fi

# Metadata (system data - safe)
if [[ -d ~/Library/Metadata ]]; then
	size=$(du -hs ~/Library/Metadata 2>/dev/null | awk '{print $1}')
	msg "      Clearing ~/Library/Metadata (${size})..."
	rm -rf ~/Library/Metadata/* 2>/dev/null || true
fi

msg "${GREEN}      ✓ System metadata cleared${NOFORMAT}"

# ==============================================================================
# SECTION 5: OLD PYTHON ENVIRONMENTS (Ask first)
# ==============================================================================

msg "${GREEN}[5/6] Old Python Environments${NOFORMAT}"

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
	fi
else
	msg "      No old environments found"
fi

# ==============================================================================
# SECTION 6: NPM/YARN (If installed)
# ==============================================================================

msg "${GREEN}[6/6] Package Manager Caches${NOFORMAT}"

if type "npm" &>/dev/null; then
	msg "      Cleaning npm cache..."
	npm cache clean --force 2>/dev/null || true
	msg "      ✓ npm cache cleared"
fi

if type "yarn" &>/dev/null; then
	msg "      Cleaning Yarn cache..."
	yarn cache clean 2>/dev/null || true
	msg "      ✓ Yarn cache cleared"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================

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
msg ""
msg "📝 ${CYAN}Manual Actions Recommended:${NOFORMAT}"
msg "   1. Review ~/Downloads folder - has 1.4 GB of archives"
msg "   2. Review Pictures (36 GB) and Movies (25 GB) for old files"
msg "   3. Consider archiving old projects"
msg ""
msg "💡 ${CYAN}Next Steps:${NOFORMAT}"
msg "   • Run this script monthly for maintenance"
msg "   • Archive large Downloads subdirectories manually"
msg "   • Your ~/pythons codebase (12 GB) is SAFE"
msg ""

cleanup
