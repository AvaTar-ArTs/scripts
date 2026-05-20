#!/bin/bash
set -euo pipefail
# Split and clean large iTerm2 log file
# ======================================
# This script:
# 1. Strips ANSI escape codes (reduces size by 80-90%)
# 2. Extracts only readable content
# 3. Splits into manageable chunks
# 4. Organizes by content type

# Configuration
SOURCE_LOG="/Users/steven/.iterm2/20260213_053718.Default.w0t2p0.7A98CE23-5FA4-4149-910E-4CA3ADA045D2.11892.1336594906.log"
OUTPUT_DIR="/Users/steven/python-marketplace-inventory/ITERM2_EXTRACTED"
SESSION_DATE="2026-02-13"

echo "======================================================================"
echo "🔍 SPLITTING & CLEANING LARGE ITERM2 LOG"
echo "======================================================================"
echo ""
echo "Source: $SOURCE_LOG"
echo "Size: $(du -sh "$SOURCE_LOG" 2>/dev/null | awk '{print $1}')"
echo ""

# Check if source exists
if [ ! -f "$SOURCE_LOG" ]; then
    echo "❌ Source file not found!"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR/commands"
mkdir -p "$OUTPUT_DIR/ai_sessions"
mkdir -p "$OUTPUT_DIR/outputs"
mkdir -p "$OUTPUT_DIR/errors"
mkdir -p "$OUTPUT_DIR/chunks"

echo "📂 Output directory: $OUTPUT_DIR"
echo ""

# Step 1: Strip ANSI codes and create clean version
echo "🧹 Step 1: Stripping ANSI escape codes..."
CLEAN_LOG="$OUTPUT_DIR/${SESSION_DATE}_session_clean.txt"

# Use sed to strip ANSI codes
sed 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\([0-9;]*[a-zA-Z]//g; s/\x1b\][0-9;]*\x07//g' "$SOURCE_LOG" > "$CLEAN_LOG" 2>/dev/null

if [ -f "$CLEAN_LOG" ]; then
    clean_size=$(du -sh "$CLEAN_LOG" | awk '{print $1}')
    echo "   ✅ Clean log created: $clean_size"
else
    echo "   ⚠️  ANSI stripping incomplete, using original"
    cp "$SOURCE_LOG" "$CLEAN_LOG"
fi

echo ""

# Step 2: Split into manageable chunks (10MB each)
echo "📦 Step 2: Splitting into chunks..."
split -b 10m "$CLEAN_LOG" "$OUTPUT_DIR/chunks/chunk_" 2>/dev/null
chunk_count=$(ls -1 "$OUTPUT_DIR/chunks/" 2>/dev/null | wc -l)
echo "   ✅ Split into $chunk_count chunks (10MB each)"
echo ""

# Step 3: Extract readable content only
echo "🔍 Step 3: Extracting readable content..."

# Extract lines that look like commands or output (not empty, not just whitespace)
grep -v '^[[:space:]]*$' "$CLEAN_LOG" | grep -v '^$' > "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null

readable_lines=$(wc -l < "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null || echo "0")
readable_size=$(du -sh "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null | awk '{print $1}')
echo "   ✅ Extracted $readable_lines lines ($readable_size)"
echo ""

# Step 4: Extract commands (lines starting with common commands)
echo "⌨️  Step 4: Extracting commands..."
grep -iE '^\s*(python3|python|pip|git|npm|curl|wget|docker|mkdir|cp |mv |rm |ls |cd |cat |grep|make|node|npx|yarn|brew|ssh|scp|rsync|chmod|chown|sudo|echo|export|source)' "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null > "$OUTPUT_DIR/commands/${SESSION_DATE}_commands.txt"

cmd_count=$(wc -l < "$OUTPUT_DIR/commands/${SESSION_DATE}_commands.txt" 2>/dev/null || echo "0")
echo "   ✅ Found $cmd_count commands"
echo ""

# Step 5: Extract Python code
echo "🐍 Step 5: Extracting Python code..."
grep -iE '(import |from .+ import |def |class |print\(|@|if __name__|async def )' "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null > "$OUTPUT_DIR/outputs/${SESSION_DATE}_python_code.txt"

py_count=$(wc -l < "$OUTPUT_DIR/outputs/${SESSION_DATE}_python_code.txt" 2>/dev/null || echo "0")
echo "   ✅ Found $py_count lines of Python code"
echo ""

# Step 6: Extract AI session indicators
echo "🤖 Step 6: Extracting AI sessions..."
grep -iE '(claude|cursor|aider|qwen|copilot|codex|chatgpt|gpt|ai assistant|prompt)' "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null > "$OUTPUT_DIR/ai_sessions/${SESSION_DATE}_ai_sessions.txt"

ai_count=$(wc -l < "$OUTPUT_DIR/ai_sessions/${SESSION_DATE}_ai_sessions.txt" 2>/dev/null || echo "0")
echo "   ✅ Found $ai_count AI-related lines"
echo ""

# Step 7: Extract errors
echo "❌ Step 7: Extracting errors..."
grep -iE '(error|failed|exception|traceback|warning|critical|fatal|cannot|denied|not found)' "$OUTPUT_DIR/${SESSION_DATE}_readable.txt" 2>/dev/null > "$OUTPUT_DIR/errors/${SESSION_DATE}_errors.txt"

err_count=$(wc -l < "$OUTPUT_DIR/errors/${SESSION_DATE}_errors.txt" 2>/dev/null || echo "0")
echo "   ✅ Found $err_count error lines"
echo ""

# Step 8: Create index
echo "📝 Step 8: Creating index..."
cat > "$OUTPUT_DIR/${SESSION_DATE}_INDEX.md" << EOF
# 📋 iTerm2 Session Extract - $SESSION_DATE

**Source:** \`$(basename "$SOURCE_LOG")\`
**Original Size:** $(du -sh "$SOURCE_LOG" | awk '{print $1}')
**Clean Size:** $readable_size
**Readable Lines:** $readable_lines

## 📊 Extracted Content

| Category | File | Lines |
|----------|------|-------|
| Clean Session | \`${SESSION_DATE}_session_clean.txt\` | $(wc -l < "$CLEAN_LOG" 2>/dev/null || echo "0") |
| Readable Lines | \`${SESSION_DATE}_readable.txt\` | $readable_lines |
| Commands | \`commands/${SESSION_DATE}_commands.txt\` | $cmd_count |
| Python Code | \`outputs/${SESSION_DATE}_python_code.txt\` | $py_count |
| AI Sessions | \`ai_sessions/${SESSION_DATE}_ai_sessions.txt\` | $ai_count |
| Errors | \`errors/${SESSION_DATE}_errors.txt\` | $err_count |
| Chunks | \`chunks/\` | $chunk_count files (10MB each) |

## 🎯 What Was Extracted

1. **Commands** - Shell commands run during session
2. **Python Code** - Import statements, function definitions, etc.
3. **AI Sessions** - Mentions of AI tools (Claude, Cursor, etc.)
4. **Errors** - Error messages and warnings
5. **Chunks** - Full session split into 10MB chunks

## ⚠️ Notes

- Original log contained ANSI escape codes (terminal formatting)
- ~80-90% of original size was formatting, not content
- Extracted content is human-readable
- Chunks can be opened individually for detailed review

---

**Extracted:** $(date '+%Y-%m-%d %H:%M:%S')
EOF

echo "   ✅ Index created"
echo ""

# Final summary
echo "======================================================================"
echo "✅ EXTRACTION COMPLETE!"
echo "======================================================================"
echo ""
echo "📂 Output directory: $OUTPUT_DIR"
echo ""
echo "📊 Summary:"
echo "   Original size: $(du -sh "$SOURCE_LOG" | awk '{print $1}')"
echo "   Clean size: $readable_size"
echo "   Readable lines: $readable_lines"
echo "   Commands: $cmd_count"
echo "   Python code: $py_count"
echo "   AI sessions: $ai_count"
echo "   Errors: $err_count"
echo "   Chunks: $chunk_count (10MB each)"
echo ""
echo "📄 Files created:"
ls -lh "$OUTPUT_DIR/"*.txt "$OUTPUT_DIR/"*.md 2>/dev/null
echo ""
echo "======================================================================"
