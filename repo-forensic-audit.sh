#!/usr/bin/env bash

echo "===================================="
echo "GITHUB REPOSITORY FORENSIC AUDIT"
echo "===================================="

OUT="repo_audit"

mkdir -p "$OUT"

echo "Generating tree..."
tree -a -L 6 > "$OUT/tree.txt" 2>/dev/null

echo "Generating file inventory..."
find . -type f | sort > "$OUT/all_files.txt"

echo "Generating extension statistics..."
find . -type f | sed 's|.*\.||' | sort | uniq -c | sort -nr > "$OUT/extensions.txt"

echo "Generating file size report..."
find . -type f -exec du -h {} + | sort -hr > "$OUT/file_sizes.txt"

echo "Generating folder size report..."
du -h --max-depth=4 . | sort -hr > "$OUT/folder_sizes.txt"

echo "Generating Python statistics..."
find . -name "*.py" > "$OUT/python_files.txt"

echo "Counting Python files..."
find . -name "*.py" | wc -l > "$OUT/python_count.txt"

echo "Searching for APIs..."
grep -Ril "api" . > "$OUT/apis.txt" 2>/dev/null

echo "Searching for databases..."
grep -Ril "sqlite\|postgres\|mysql\|mongodb" . > "$OUT/databases.txt" 2>/dev/null

echo "Searching for workflows..."
grep -Ril "workflow\|n8n\|automation" . > "$OUT/workflows.txt" 2>/dev/null

echo "Searching for AI references..."
grep -Ril "openai\|gemini\|claude\|llm\|agent" . > "$OUT/ai_projects.txt" 2>/dev/null

echo "Searching for MCP references..."
grep -Ril "mcp" . > "$OUT/mcp_projects.txt" 2>/dev/null

echo "Generating README inventory..."
find . -iname "README*" > "$OUT/readmes.txt"

echo "Creating summary..."

{
echo "Repository: $(basename $(pwd))"
echo
echo "Python Files:"
find . -name "*.py" | wc -l
echo
echo "Total Files:"
find . -type f | wc -l
echo
echo "Total Directories:"
find . -type d | wc -l
} > "$OUT/SUMMARY.txt"

echo ""
echo "Done."
echo "Zip repo_audit folder and send it."
