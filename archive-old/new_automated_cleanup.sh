#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Automated Disk Cleanup Script (macOS)
# - Safe-ish defaults
# - Progress + estimates
# - Verbose removal only where explicitly intended

# ---------- Helpers ----------
log() { printf '%s\n' "$*"; }
info() { log "ℹ️  $*"; }
step() { log ""; log "🧹 $*"; }
ok() { log "   ✅ $*"; }
warn() { log "   ⚠️  $*"; }

format_bytes() {
  local bytes="${1:-0}"
  if (( bytes >= 1073741824 )); then
    echo "$(( bytes / 1073741824 ))GB"
  elif (( bytes >= 1048576 )); then
    echo "$(( bytes / 1048576 ))MB"
  elif (( bytes >= 1024 )); then
    echo "$(( bytes / 1024 ))KB"
  else
    echo "${bytes}B"
  fi
}

human_du() { # usage: human_du /path
  du -s "$1" 2>/dev/null | awk '{print $1}'
}

sum_du_bytes() { # usage: sum_du_bytes "find args..."  (reads NUL-safe paths not required here)
  # We compute size using du; sum in awk.
  # shellcheck disable=SC2001
  awk '{sum+=$1} END {print sum+0}'
}

count_files() { # usage: count_files "find args..." 
  # shellcheck disable=SC2046
  find "$@" 2>/dev/null | wc -l
}

# ---------- Start ----------
log "🧹 AUTOMATED DISK CLEANUP SCRIPT"
log "================================="
log "📊 Starting cleanup process..."
log ""

# Track home size
initial_size="$(human_du "$HOME")"
log "📏 Initial size: $(format_bytes "$initial_size")"

# ---------- Step 1: Remove specific large log files ----------
step "Step 1: Removing targeted log files..."

log_files=(
  "$HOME/.cursor/projects/Users-steven/worker.log"
  "$HOME/Library/Mobile Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log"
)

removed_any=false
for log_file in "${log_files[@]}"; do
  if [[ -f "$log_file" ]]; then
    size="$(human_du "$log_file")"
    log "   Removing: $(basename "$log_file") ($(format_bytes "$size"))"
    rm -f -- "$log_file"
    removed_any=true
  fi
done

if [[ "$removed_any" == true ]]; then
  ok "Log files cleaned"
else
  info "No targeted log files found"
fi

# ---------- Step 2: Python caches ----------
step "Step 2: Cleaning Python caches (__pycache__ and *.pyc)..."

# Estimate sizes
pycache_dirs="$(find "$HOME" -name '__pycache__' -type d 2>/dev/null | wc -l || true)"
pyc_files="$(find "$HOME" -name '*.pyc' 2>/dev/null | wc -l || true)"

pycache_size="$(
  find "$HOME" -name '__pycache__' -type d -exec du -s {} + 2>/dev/null \
  | awk '{sum+=$1} END{print sum+0}'
)"
pyc_size="$(
  find "$HOME" -name '*.pyc' -exec du -s {} + 2>/dev/null \
  | awk '{sum+=$1} END{print sum+0}'
)"
total_py_size=$((pycache_size + pyc_size))

log "   Found $pycache_dirs __pycache__ directories"
log "   Found $pyc_files .pyc files"
log "   Estimated size to free: $(format_bytes "$total_py_size")"

# Remove caches
find "$HOME" -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null
find "$HOME" -name '*.pyc' -type f -delete 2>/dev/null
ok "Python caches cleaned"

# ---------- Step 3: Duplicate zip files ----------
step "Step 3: Removing zip files named backup.zip and Archive.zip..."

# Counts
backup_count="$(find "$HOME" -name 'backup.zip' -not -path '*/node_modules/*' 2>/dev/null | wc -l || true)"
archive_count="$(find "$HOME" -name 'Archive.zip' -not -path '*/node_modules/*' 2>/dev/null | wc -l || true)"

backup_size="$(
  find "$HOME" -name 'backup.zip' -not -path '*/node_modules/*' -exec du -s {} + 2>/dev/null \
  | awk '{sum+=$1} END{print sum+0}'
)"
archive_size="$(
  find "$HOME" -name 'Archive.zip' -not -path '*/node_modules/*' -exec du -s {} + 2>/dev/null \
  | awk '{sum+=$1} END{print sum+0}'
)"
total_zip_size=$((backup_size + archive_size))

log "   Found $backup_count backup.zip files"
log "   Found $archive_count Archive.zip files"
log "   Estimated size to free: $(format_bytes "$total_zip_size")"

find "$HOME" -name 'backup.zip' -not -path '*/node_modules/*' -delete 2>/dev/null
find "$HOME" -name 'Archive.zip' -not -path '*/node_modules/*' -delete 2>/dev/null
ok "Duplicate zip files removed"

# ---------- Step 4: Temporary files ----------
step "Step 4: Cleaning temporary files..."

tmp_count="$(find "$HOME" -name '*.tmp' 2>/dev/null | wc -l || true)"
temp_count="$(find "$HOME" -name '*.temp' 2>/dev/null | wc -l || true)"
tilde_count="$(find "$HOME" -name '*~' 2>/dev/null | wc -l || true)"

log "   Found $tmp_count .tmp files"
log "   Found $temp_count .temp files"
log "   Found $tilde_count backup files (~)"

find "$HOME" -name '*.tmp' -type f -delete 2>/dev/null
find "$HOME" -name '*.temp' -type f -delete 2>/dev/null
find "$HOME" -name '*~' -type f -delete 2>/dev/null
ok "Temporary files cleaned"

# ---------- Step 5: Application caches ----------
step "Step 5: Cleaning safe user caches (~/Library/Caches/*)..."

# Be cautious: removing everything under Caches is usually safe, but still destructive.
rm -rf -- "$HOME/Library/Caches"/* 2>/dev/null || true
ok "Application caches cleaned"

# ---------- Step 6: npm cache ----------
step "Step 6: Cleaning npm cache..."

if command -v npm >/dev/null 2>&1; then
  npm cache clean --force 2>/dev/null
  ok "npm cache cleaned"
else
  warn "npm not found, skipping"
fi

# ---------- Step 7: pip cache ----------
step "Step 7: Cleaning pip cache..."

if command -v pip >/dev/null 2>&1; then
  # Some pip versions support this; if not, it will no-op.
  pip cache purge 2>/dev/null || true
  ok "pip cache cleaned (or already clean)"
else
  warn "pip not found, skipping"
fi

# ---------- Results ----------
final_size="$(human_du "$HOME")"
saved_size=$((initial_size - final_size))

log ""
log "📊 CLEANUP RESULTS:"
log "==================="
log "Initial size: $(format_bytes "$initial_size")"
log "Final size:   $(format_bytes "$final_size")"
log "Space saved:  $(format_bytes "$saved_size")"
log ""

if (( saved_size > 0 )); then
  log "✅ Cleanup completed successfully!"
  log "💾 Freed up $(format_bytes "$saved_size") of disk space"
else
  info "No significant space was freed"
fi

log ""
log "🎯 RECOMMENDATIONS FOR FURTHER CLEANUP:"
log "======================================="
log "1) Review large directories (Pictures, Movies, etc.)"
log "2) Consider archiving completed projects"
log "3) Check node_modules for unused copies"
log "4) Tools like CleanMyMac can help with Apple-safe caches (optional)"
log ""
log "🔍 To monitor disk usage:"
log "du -sh $HOME/* | sort -hr | head -10"
log ""
log "🏁 Cleanup script finished!"
