#!/bin/bash
# Script to inject 'set -euo pipefail' into identified scripts
# Using a simpler awk approach for better cross-platform compatibility

FILES=(
"/Users/steven/scripts/advanced-system-maintenance-v3.sh"
"/Users/steven/scripts/advanced-system-maintenance-v4.sh"
"/Users/steven/scripts/advanced-system-maintenance-v5-backup.sh"
"/Users/steven/scripts/advanced-system-maintenance-v5-guided.sh"
"/Users/steven/scripts/advanced-system-maintenance-v5-preview.sh"
"/Users/steven/scripts/analyze_scripts copy.sh"
"/Users/steven/scripts/backup-nocturnemelodies-collection.sh"
"/Users/steven/scripts/clean/back-clean.sh"
"/Users/steven/scripts/clean/sortD.sh"
"/Users/steven/scripts/consolidate-masterxeo-simple.sh"
"/Users/steven/scripts/conversation-fuzzy-finder.sh"
"/Users/steven/scripts/execute-special-cases.sh"
"/Users/steven/scripts/generate-check-grok-setup-full.sh"
"/Users/steven/scripts/generate-marketmaster-complete-guide.sh"
"/Users/steven/scripts/generate-marketmaster-final-guide.sh"
"/Users/steven/scripts/open-marketmaster-navigation.sh"
"/Users/steven/scripts/preview_intuitive_organization 2.sh"
"/Users/steven/scripts/preview-comprehensive-inventory-report.sh"
"/Users/steven/scripts/print-final-filesystem-analysis-summary.sh"
"/Users/steven/scripts/restore-autotagger-environment-reference.sh"
"/Users/steven/scripts/run-mcp-diagnostics.sh"
"/Users/steven/scripts/run-ultra-simple-demo-script.sh"
"/Users/steven/scripts/setup-development-environment.sh"
"/Users/steven/scripts/split_iterm2_log.sh"
"/Users/steven/scripts/system-maintenance.sh"
"/Users/steven/scripts/wav_to_mp3.sh"
)

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Processing $file..."
        # Use awk to print the first line, then the new line, then the rest
        awk 'NR==1 {print; print "set -euo pipefail"; next} 1' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    else
        echo "File not found: $file"
    fi
done

echo "Injection complete."
