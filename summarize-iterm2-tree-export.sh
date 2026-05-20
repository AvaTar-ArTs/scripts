#!/usr/bin/env bash
# From fulltree_*.txt, generate manifest_*.tsv (path, type, size, ext) and summary_*.md
# so we know what's in each target. Run after iterm2_full_tree.sh.
# Optional: iterm2_tree_summary_helper.py (same dir) speeds up large trees by building manifest in one process.
set -euo pipefail

ITERN2="${ITERN2:-/Users/steven/iterm2}"
OUT_DIR="${OUT_DIR:-$(dirname "$0")/iterm2_full_trees}"
TOP_N="${TOP_N:-25}"
MAX_PATH_COLS="${MAX_PATH_COLS:-50}"
rm -f "$OUT_DIR"/.ext_*.tmp

# Optional: only process one target (e.g. agent_ops)
FILTER="${1:-}"

# Human-readable size (works on macOS without numfmt)
hr_size() {
  local n=$1
  if [[ $n -ge 1073741824 ]]; then echo "$(( n / 1073741824 )) GiB"; return; fi
  if [[ $n -ge 1048576 ]]; then echo "$(( n / 1048576 )) MiB"; return; fi
  if [[ $n -ge 1024 ]]; then echo "$(( n / 1024 )) KiB"; return; fi
  echo "${n} B"
}

# Root for path resolution: iterm2 targets use ITERN2; home targets (e.g. harbor) use HOME
HOME_ROOT="${HOME:-$HOME}"

for full in "$OUT_DIR"/fulltree_*.txt; do
  [[ -f "$full" ]] || continue
  base=$(basename "$full" .txt)
  label=${base#fulltree_}
  if [[ -n "$FILTER" && "$label" != *"$FILTER"* ]]; then continue; fi
  manifest="$OUT_DIR/manifest_${label}.tsv"
  summary="$OUT_DIR/summary_${label}.md"

  # Home-tree targets (e.g. fulltree_harbor.txt from home_tree.sh) use HOME as root
  if [[ "$label" == "harbor" ]]; then
    root="$HOME_ROOT"
  else
    root="$ITERN2"
  fi

  echo "Summarizing $label..."

  ext_sorted="$OUT_DIR/.ext_${label}.tmp"
  totals_tmp="$OUT_DIR/.totals_${label}.tmp"
  run_fallback=0

  helper="$(dirname "$0")/iterm2_tree_summary_helper.py"
  if [[ -f "$helper" ]]; then
    if python3 "$helper" "$root" "$full" "$manifest" "$totals_tmp" "$ext_sorted" 2>/dev/null; then
      read -r total_dirs total_files total_bytes < "$totals_tmp"
      rm -f "$totals_tmp"
    else
      rm -f "$totals_tmp" "$ext_sorted"
      run_fallback=1
    fi
  else
    run_fallback=1
  fi

  if [[ "${run_fallback:-0}" -eq 1 ]]; then
    echo -e "path\ttype\tsize_bytes\text" > "$manifest"
    total_dirs=0
    total_files=0
    total_bytes=0
    unset ext_count
    declare -A ext_count
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      abs="$root/$p"
      if [[ -d "$abs" ]]; then
        echo -e "${p}\tdir\t0\t" >> "$manifest"
        ((total_dirs++)) || true
      else
        size=0
        [[ -f "$abs" ]] && size=$(stat -f %z "$abs" 2>/dev/null || echo 0)
        ext="${p##*.}"
        [[ "$ext" == "$p" ]] && ext=""
        echo -e "${p}\tfile\t${size}\t${ext}" >> "$manifest"
        ((total_files++)) || true
        total_bytes=$((total_bytes + size))
        if [[ -n "$ext" ]]; then ext_count[$ext]=$((${ext_count[$ext]:-0} + 1)); fi
      fi
    done < "$full"
    for ext in "${!ext_count[@]}"; do echo "${ext_count[$ext]} $ext"; done | sort -rn > "$ext_sorted" 2>/dev/null || true
  fi

  # Summary markdown
  {
    echo "# Summary: $label"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Directories | $total_dirs |"
    echo "| Files | $total_files |"
    echo "| Total size | $(hr_size "$total_bytes") |"
    echo ""
    echo "## By extension (top 20)"
    echo ""
    echo "| ext | count |"
    echo "|-----|-------|"
    head -20 "$ext_sorted" | while read -r cnt ext; do echo "| .$ext | $cnt |"; done
    echo ""
    echo "## Largest files (top $TOP_N)"
    echo ""
    echo "| size | path |"
    echo "|------|------|"
    awk -F'\t' '$2=="file" && $3>0 {print $3"\t"$1}' "$manifest" | sort -nr | head -n "$TOP_N" | while IFS= read -r line; do
      s=$(echo "$line" | cut -f1)
      path=$(echo "$line" | cut -f2-)
      if [[ ${#path} -gt $MAX_PATH_COLS ]]; then path="...${path: -$((MAX_PATH_COLS-3))}"; fi
      echo "| $(hr_size "$s") | \`$path\` |"
    done
    echo ""
    echo "---"
    echo "Full list: \`fulltree_${label}.txt\` · Manifest: \`manifest_${label}.tsv\`"
  } > "$summary"

  rm -f "$ext_sorted"
done

# Index: one place to see what's in the output dir
index="$OUT_DIR/INDEX.md"
{
  echo "# iterm2 full trees – index"
  echo ""
  echo "Generated from \`iterm2_full_tree.sh\` (full paths) and \`iterm2_tree_summary.sh\` (manifests + summaries)."
  echo "For other \`~/\` dirs (e.g. .harbor, scripts, .cursor/agents), see \`~/scripts/HOME_DIR_AUDIT.md\`."
  echo ""
  echo "| Target | Summary | Full tree | Manifest |"
  echo "|--------|---------|-----------|----------|"
  for s in "$OUT_DIR"/summary_*.md; do
    [[ -f "$s" ]] || continue
    label=$(basename "$s" .md | sed 's/^summary_//')
    echo "| $label | [summary_${label}.md](summary_${label}.md) | fulltree_${label}.txt | manifest_${label}.tsv |"
  done
  echo ""
  # shellcheck disable=SC2028
  echo "**Quick view:** open a \`summary_*.md\` to see counts by extension and largest files. Use \`manifest_*.tsv\` to filter by type/extension (e.g. \`awk -F'\\t' '\$4==\"py\"' manifest_agent_ops.tsv\`)."
} > "$index"

echo "Done. Manifests and summaries in $OUT_DIR"
echo "Index: $index"
echo "View: cat $OUT_DIR/summary_agent_ops.md"
