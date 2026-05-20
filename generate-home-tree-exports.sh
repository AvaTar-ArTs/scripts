#!/usr/bin/env bash
# Optional: generate fulltree_*.txt for home dir targets (e.g. .harbor) so
# iterm2_tree_summary.sh can build manifest + summary. Paths are relative to HOME.
# Run from ~/scripts; output goes to iterm2_full_trees/ (same as iterm2_full_tree.sh).
set -euo pipefail

HOME="${HOME:-$HOME}"
OUT_DIR="${OUT_DIR:-$(dirname "$0")/iterm2_full_trees}"
# Space-separated list of dirs under HOME (with leading dot or not)
HOME_ROOTS="${HOME_ROOTS:-.harbor}"
mkdir -p "$OUT_DIR"

for d in $HOME_ROOTS; do
  sub="$HOME/$d"
  if [[ ! -d "$sub" ]]; then
    echo "Skip (missing): $sub"
    continue
  fi
  label="${d//\//_}"
  label="${label#.}"
  [[ -z "$label" ]] && label="${d//./_}"
  [[ -z "$label" ]] && label="harbor"
  out="$OUT_DIR/fulltree_${label}.txt"
  (cd "$HOME" && find "./$d" -print 2>/dev/null | sort) > "$out"
  count=$(wc -l < "$out")
  echo "$d: $count entries -> $out"
  first_label="${first_label:-$label}"
done

echo "Done. Run: bash iterm2_tree_summary.sh ${first_label:-harbor}   # or no arg for all"
