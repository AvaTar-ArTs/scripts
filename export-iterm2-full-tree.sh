#!/usr/bin/env bash
# Recursively list every file and folder under iterm2 target dirs (unlimited depth).
# Writes to scripts/iterm2_full_trees/fulltree_<name>.txt
set -euo pipefail

ITERN2="${ITERN2:-/Users/steven/iterm2}"
OUT_DIR="${OUT_DIR:-$(dirname "$0")/iterm2_full_trees}"
mkdir -p "$OUT_DIR"

roots=(.claude .cursor .gemini .git .grok .qodo .qwen agent_ops Ai-Merge Ai-Merge-GitHub claude-ecosystem Codex cursor-ecosystem docs gemini orchestrator scripts superpowers-codex-product)

for d in "${roots[@]}"; do
  sub="$ITERN2/$d"
  if [[ ! -d "$sub" ]]; then
    echo "Skip (missing): $sub"
    continue
  fi
  label="${d//\//_}"
  label="${label//./_}"
  out="$OUT_DIR/fulltree_${label}.txt"
  (cd "$ITERN2" && find "./$d" -print 2>/dev/null | sort) > "$out"
  count=$(wc -l < "$out")
  echo "$d: $count entries -> $out"
done

echo "Done. Output dir: $OUT_DIR"
