#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Deep Index Examples - Common use cases for directory indexing

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Deep Directory Indexer - Example Usage${NC}\n"

# Example 1: Basic project analysis
echo -e "${GREEN}Example 1: Analyze a code project${NC}"
echo "./deepindex.py ~/myproject \\"
echo "  --exclude 'node_modules,venv,.git,__pycache__,dist,build' \\"
echo "  --content-analysis \\"
echo "  --format json,markdown \\"
echo "  --output project_analysis"
echo ""

# Example 2: Find large files
echo -e "${GREEN}Example 2: Find largest files in Documents${NC}"
echo "./deepindex.py ~/Documents \\"
echo "  --format json \\"
echo "  --output docs_index"
echo "cat docs_index.json | python3 -c 'import json, sys; data = json.load(sys.stdin); print(\"\\n\".join([f\"{f[\"size_human\"]:>10} - {f[\"path\"]}\" for f in data[\"statistics\"][\"largest_files\"][:20]]))'"
echo ""

# Example 3: Security audit
echo -e "${GREEN}Example 3: Security audit with checksums${NC}"
echo "./deepindex.py /sensitive/data \\"
echo "  --include-hidden \\"
echo "  --checksums \\"
echo "  --follow-symlinks \\"
echo "  --format json,csv \\"
echo "  --output security_audit_$(date +%Y%m%d)"
echo ""

# Example 4: File type analysis
echo -e "${GREEN}Example 4: Analyze file types and extensions${NC}"
echo "./deepindex.py ~/Pictures \\"
echo "  --format markdown \\"
echo "  --output pictures_analysis"
echo "# View the markdown report for file type distribution"
echo ""

# Example 5: Deep content analysis
echo -e "${GREEN}Example 5: Code metrics (with content analysis)${NC}"
echo "./deepindex.py ~/code/myapp \\"
echo "  --content-analysis \\"
echo "  --exclude '.git,node_modules' \\"
echo "  --format csv \\"
echo "  --output code_metrics"
echo "# Import CSV into spreadsheet for analysis"
echo ""

# Example 6: Comparison workflow
echo -e "${GREEN}Example 6: Before/After comparison${NC}"
echo "# Index before changes"
echo "./deepindex.py ~/project --format json --output before_index"
echo ""
echo "# ... make changes ..."
echo ""
echo "# Index after changes"
echo "./deepindex.py ~/project --format json --output after_index"
echo ""
echo "# Compare (using jq or custom script)"
echo "diff <(cat before_index.json | jq -S '.statistics') <(cat after_index.json | jq -S '.statistics')"
echo ""

# Example 7: Automated backup reports
echo -e "${GREEN}Example 7: Weekly backup analysis script${NC}"
cat << 'SCRIPT'
#!/bin/bash
# weekly_backup_report.sh

BACKUP_DIRS=(
  "$HOME/Documents"
  "$HOME/Pictures"
  "$HOME/Projects"
)

REPORT_DIR="$HOME/backup_reports/$(date +%Y%m%d)"
mkdir -p "$REPORT_DIR"

for dir in "${BACKUP_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    dirname=$(basename "$dir")
    ./deepindex.py "$dir" \
      --output "$REPORT_DIR/${dirname}_index" \
      --format json,markdown \
      --exclude ".DS_Store,.Trash"
  fi
done

echo "Reports saved to: $REPORT_DIR"
SCRIPT
echo ""

# Example 8: Find duplicate files by size
echo -e "${GREEN}Example 8: Find potential duplicates${NC}"
echo "./deepindex.py /data --format csv --output data_files"
echo "# Then use awk/sort to find files with same size:"
echo "cat data_files.csv | awk -F',' 'NR>1 {print \$4,\$1}' | sort -n | uniq -d -w10"
echo ""

# Example 9: Monitor directory changes
echo -e "${GREEN}Example 9: Directory monitoring${NC}"
cat << 'SCRIPT'
#!/bin/bash
# monitor_dir.sh - Track directory changes over time

DIR_TO_MONITOR="$1"
SNAPSHOT_DIR="$HOME/.dir_snapshots/$(basename "$DIR_TO_MONITOR")"

mkdir -p "$SNAPSHOT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

./deepindex.py "$DIR_TO_MONITOR" \
  --format json \
  --output "$SNAPSHOT_DIR/snapshot_$TIMESTAMP"

echo "Snapshot saved: $SNAPSHOT_DIR/snapshot_$TIMESTAMP.json"

# Show file count trend
echo -e "\nFile count trend:"
for snapshot in "$SNAPSHOT_DIR"/*.json; do
  count=$(cat "$snapshot" | python3 -c 'import json, sys; print(json.load(sys.stdin)["statistics"]["total_files"])')
  echo "$(basename $snapshot): $count files"
done
SCRIPT
echo ""

# Example 10: Export to database
echo -e "${GREEN}Example 10: Import into SQLite${NC}"
cat << 'SCRIPT'
#!/usr/bin/env python3
import sqlite3
import json
import sys

def import_index_to_sqlite(json_file, db_file):
    with open(json_file) as f:
        data = json.load(f)

    conn = sqlite3.connect(db_file)
    cur = conn.cursor()

    cur.execute('''
        CREATE TABLE IF NOT EXISTS files (
            path TEXT PRIMARY KEY,
            name TEXT,
            extension TEXT,
            size INTEGER,
            depth INTEGER,
            created TEXT,
            modified TEXT,
            mime_type TEXT
        )
    ''')

    def insert_files(node):
        if node.get('type') != 'directory':
            cur.execute('''
                INSERT OR REPLACE INTO files VALUES (?,?,?,?,?,?,?,?)
            ''', (
                node['path'], node['name'], node.get('extension', ''),
                node['size'], node['depth'], node['created'],
                node['modified'], node.get('mime_type', '')
            ))
        else:
            for child in node.get('children', []):
                insert_files(child)

    insert_files(data['tree'])
    conn.commit()
    conn.close()
    print(f"Imported to {db_file}")

if __name__ == '__main__':
    import_index_to_sqlite(sys.argv[1], sys.argv[2])
SCRIPT
echo ""
echo "# Usage: python3 import_script.py index.json files.db"
echo ""

echo -e "${BLUE}For more information, see: deepindex_README.md${NC}"
