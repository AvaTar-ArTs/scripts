#!/usr/bin/env bash
set -euo pipefail

# Global pip AI package migration utility.
# - Backs up current global pip state
# - Uninstalls selected AI packages from global pip
# - Optionally reinstalls removed packages into a target mamba env

TARGET_ENV=""
ASSUME_YES=0

usage() {
  cat <<USAGE
Usage:
  bash final-cleanup.sh [--target-env ENV] [--yes]

Options:
  --target-env ENV   Reinstall removed packages into this mamba env.
  --yes              Skip confirmation prompt.
  -h, --help         Show this help.

Examples:
  bash final-cleanup.sh
  bash final-cleanup.sh --target-env automation-master
  bash final-cleanup.sh --target-env automation-master --yes
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-env)
      TARGET_ENV="${2:-}"
      [[ -n "$TARGET_ENV" ]] || { echo "Missing value for --target-env"; exit 1; }
      shift 2
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

echo "Global pip AI cleanup/migration"
echo "=============================="

if [[ -n "${CONDA_DEFAULT_ENV:-}" || -n "${VIRTUAL_ENV:-}" ]]; then
  echo "Please run from base shell (no active conda/venv)."
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found"
  exit 1
fi

PIP_CMD=(python3 -m pip)

BACKUP_FILE="$HOME/pip-packages-final-backup-$(date +%Y%m%d-%H%M%S).txt"
REMOVED_FILE="$HOME/pip-packages-removed-$(date +%Y%m%d-%H%M%S).txt"
"${PIP_CMD[@]}" freeze > "$BACKUP_FILE"
: > "$REMOVED_FILE"

BEFORE_COUNT=$("${PIP_CMD[@]}" list --format=freeze | wc -l | tr -d ' ')
echo "Backed up global packages to: $BACKUP_FILE"
echo "Starting with $BEFORE_COUNT global packages"

AI_PACKAGES=(
  aider-chat
  aider-install
  anthropic
  openai
  claude
  claude-agent-sdk
  langchain
  langchain-classic
  langchain-community
  langchain-core
  langchain-openai
  langchain-text-splitters
  torch
  torchaudio
  transformers
  sentence-transformers
  openai-whisper
  composio-langchain
)

INSTALLED_TO_REMOVE=()
for package in "${AI_PACKAGES[@]}"; do
  if "${PIP_CMD[@]}" list --format=freeze | grep -qiE "^${package}=="; then
    INSTALLED_TO_REMOVE+=("$package")
  fi
done

if [[ ${#INSTALLED_TO_REMOVE[@]} -eq 0 ]]; then
  echo "No target AI packages found in global pip."
else
  echo "Packages to remove from global pip:"
  printf '  - %s\n' "${INSTALLED_TO_REMOVE[@]}"

  if [[ $ASSUME_YES -ne 1 ]]; then
    read -r -p "Proceed with global uninstall? [y/N]: " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Canceled."; exit 0; }
  fi

  for package in "${INSTALLED_TO_REMOVE[@]}"; do
    echo "$package" >> "$REMOVED_FILE"
    "${PIP_CMD[@]}" uninstall -y "$package" >/dev/null 2>&1 || echo "Could not remove: $package"
  done
fi

AFTER_COUNT=$("${PIP_CMD[@]}" list --format=freeze | wc -l | tr -d ' ')
REMOVED_COUNT=$((BEFORE_COUNT - AFTER_COUNT))

echo
echo "Cleanup results:"
echo "  Before:  $BEFORE_COUNT"
echo "  After:   $AFTER_COUNT"
echo "  Removed: $REMOVED_COUNT"
echo "  Removed list: $REMOVED_FILE"

if [[ -n "$TARGET_ENV" ]]; then
  if ! command -v mamba >/dev/null 2>&1; then
    echo "mamba not found; cannot reinstall into env '$TARGET_ENV'."
    exit 1
  fi

  if [[ ! -s "$REMOVED_FILE" ]]; then
    echo "No removed packages to reinstall."
    exit 0
  fi

  echo
echo "Reinstalling removed packages into mamba env: $TARGET_ENV"
  # shellcheck disable=SC1090
  eval "$(mamba shell hook -s bash 2>/dev/null)"
  mamba activate "$TARGET_ENV"

  while IFS= read -r package; do
    [[ -n "$package" ]] || continue
    python -m pip install "$package" >/dev/null 2>&1 || echo "Failed to install in env: $package"
  done < "$REMOVED_FILE"

  echo "Reinstall attempt complete in env: $TARGET_ENV"
  echo "Validate with: mamba activate $TARGET_ENV && python -m pip list"
else
  echo
  echo "No target env specified; uninstall-only mode completed."
  echo "If desired, run again with: --target-env automation-master"
fi
