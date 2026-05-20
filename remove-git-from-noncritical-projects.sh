#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Clean .git from archived/old projects (keep only critical ones)

echo "🧹 Cleaning .git directories from old/archived repos..."
echo ""

# KEEP git in these critical repos:
KEEP_REPOS=(
  "album-ai"
  "suno-api"
  "heavenlyhands"
)

echo "✅ Will KEEP .git in:"
for repo in "${KEEP_REPOS[@]}"; do
  echo "   - $repo"
done
echo ""

echo "🗑️  Will REMOVE .git from all other projects..."
echo ""

# Remove .git from non-critical projects
cd ~/projects/
for dir in */; do
  dir_name="${dir%/}"
  
  # Skip if in keep list
  skip=false
  for keep in "${KEEP_REPOS[@]}"; do
    if [[ "$dir_name" == "$keep" ]]; then
      skip=true
      break
    fi
  done
  
  if [ "$skip" = true ]; then
    echo "   ⏭️  Skipping: $dir_name (keeping git)"
  elif [ -d "$dir/.git" ]; then
    rm -rf "$dir/.git"
    echo "   ✅ Removed: $dir_name/.git"
  fi
done

echo ""
echo "✅ Cleanup complete!"
echo ""

# Show remaining git repos
echo "📊 Remaining git repos in ~/projects/:"
find ~/projects/ -name ".git" -type d 2>/dev/null | wc -l
