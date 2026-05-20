#!/bin/bash
set -euo pipefail
# 🔍 **PREVIEW: INTUITIVE 3-FOLDER ORGANIZATION**
# Shows exactly what will be moved where set -e echo "🔍 INTUITIVE ORGANIZATION PREVIEW"
echo "================================="
echo "" # Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
preview() { echo -e "${PURPLE}🔍 $1${NC}"; }
move() { echo -e "${CYAN}➡️ $1${NC}"; }
count() { echo -e "${CYAN}📊 $1${NC}"; } echo "Based on your 47,226+ files analysis, this will create:"
echo ""
echo "📁 ~/active/ ← Current work & projects (daily workspace)"
echo "📁 ~/tools/ ← Scripts & configurations (infrastructure)"
echo "📁 ~/archive/ ← Old completed stuff (historical reference)"
echo "" # Function to safely count files
safe_count() { local path="$1" if [ -d "$path" ] 2>/dev/null; then find "$path" -type f 2>/dev/null | wc -l else echo "0" fi
} # Function to get directory size
dir_size() { local path="$1" if [ -d "$path" ] 2>/dev/null; then du -sh "$path" 2>/dev/null | cut -f1 else echo "N/A" fi
} # Check for existing folders
echo ""
warning "EXISTING FOLDER CHECK:"
if [ -d ~/active ]; then warning "~/active/ already exists - will merge"
else status "~/active/ will be created"
fi if [ -d ~/tools ]; then warning "~/tools/ already exists - will merge"
else status "~/tools/ will be created"
fi if [ -d ~/archive ]; then warning "~/archive/ already exists - will merge"
else status "~/archive/ will be created"
fi echo ""
preview "PHASE 1: ~/ACTIVE/ PREVIEW (Your Daily Workspace)"
echo "===================================================" active_total=0 # Current projects
if [ -d ~/pythons/projects ]; then proj_count=$(safe_count ~/pythons/projects) proj_size=$(dir_size ~/pythons/projects) move "~/pythons/projects/ ($proj_count files, $proj_size) → ~/active/projects/" active_total=$((active_total + proj_count))
fi # AI research
if [ -d ~/workspace/ai_cli_research ]; then ai_count=$(safe_count ~/workspace/ai_cli_research) ai_size=$(dir_size ~/workspace/ai_cli_research) move "~/workspace/ai_cli_research/ ($ai_count files, $ai_size) → ~/active/ai-research/" active_total=$((active_total + ai_count))
fi # Core utilities
if [ -f ~/pythons/avatar_utils.py ]; then move "~/pythons/avatar_utils.py → ~/active/avatar_utils.py" active_total=$((active_total + 1))
fi if [ -f ~/pythons/MASTER_SNIPPETS.md ]; then move "~/pythons/MASTER_SNIPPETS.md → ~/active/MASTER_SNIPPETS.md" active_total=$((active_total + 1))
fi # Active home files
home_active_count=0
for pattern in "avatararts_*.md" "gumroad*.txt" "AVATARARTS_*.md" "PYTHONS_*.md" "PYTHONS_*.py"; do for file in ~/$pattern; do if [ -f "$file" ] && [[ "$file" != ~/$pattern ]]; then filename=$(basename "$file") move "~/$filename → ~/active/$filename" home_active_count=$((home_active_count + 1)) fi done
done if [ $home_active_count -gt 0 ]; then move "$home_active_count active project files from home directory → ~/active/" active_total=$((active_total + home_active_count))
fi count "TOTAL: ~/active/ will contain $active_total files" echo ""
preview "PHASE 2: ~/TOOLS/ PREVIEW (Development Infrastructure)"
echo "======================================================" tools_total=0 # Python ecosystem
if [ -d ~/pythons ]; then py_count=$(safe_count ~/pythons) py_size=$(dir_size ~/pythons) move "~/pythons/ ($py_count files, $py_size) → ~/tools/python-ecosystem/" tools_total=$((tools_total + py_count))
fi # AI configurations
if [ -d ~/.claude ]; then claude_count=$(safe_count ~/.claude) claude_size=$(dir_size ~/.claude) move "~/.claude/ ($claude_count files, $claude_size) → ~/tools/claude-config/" tools_total=$((tools_total + claude_count))
fi if [ -d ~/.cursor ]; then cursor_count=$(safe_count ~/.cursor) cursor_size=$(dir_size ~/.cursor) move "~/.cursor/ ($cursor_count files, $cursor_size) → ~/tools/cursor-config/" tools_total=$((tools_total + cursor_count))
fi if [ -d ~/.config/mcp ]; then mcp_count=$(safe_count ~/.config/mcp) move "~/.config/mcp/ ($mcp_count files) → ~/tools/mcp-config/" tools_total=$((tools_total + mcp_count))
fi # Scripts
if [ -d ~/scripts ]; then scripts_count=$(safe_count ~/scripts) scripts_size=$(dir_size ~/scripts) move "~/scripts/ ($scripts_count files, $scripts_size) → ~/tools/shell-scripts/" tools_total=$((tools_count + scripts_count))
fi # Tool scripts from home
home_tools_count=0
for pattern in "update_music_inventory.py" "compare_hashes*.py" "find_functional_dupes.py" "deep_logic_audit.py" "generate_redundancy_map.py" "extract_redundant_code.py" "comment_zshrc_sections.py" "create_*.sh" "consolidation_*.sh" "intuitive_*.sh" "simple_*.sh" "implement_*.sh"; do for file in ~/$pattern; do if [ -f "$file" ] && [[ "$file" != ~/create_comprehensive_index.sh ]] && [[ "$file" != ~/$pattern ]]; then filename=$(basename "$file") move "~/$filename → ~/tools/$filename" home_tools_count=$((home_tools_count + 1)) fi done
done if [ $home_tools_count -gt 0 ]; then move "$home_tools_count development utility scripts from home → ~/tools/" tools_total=$((tools_total + home_tools_count))
fi count "TOTAL: ~/tools/ will contain $tools_total files" echo ""
preview "PHASE 3: ~/ARCHIVE/ PREVIEW (Historical Reference)"
echo "==================================================" archive_total=0 # Old archives
if [ -d ~/pythons/archives ]; then arch_count=$(safe_count ~/pythons/archives) arch_size=$(dir_size ~/pythons/archives) move "~/pythons/archives/ ($arch_count files, $arch_size) → ~/archive/old-archives/" archive_total=$((archive_total + arch_count))
fi # Old home files
home_archive_count=0
for pattern in "error.*" "folder by folder if needed.txt" "remote_down.txt" "local_down.txt" "BATCH*.txt" "ETSY*.txt" "PROGRESS_REPORT.txt" "ZIP_ORGANIZATION_FINAL.txt" "cursor-agent.txt" "gemini*.txt" "gemini*.md" "REFERENCE.md" "AI_Chats" "Archives" "NEXT_ORGANIZATION_IDEAS.md" "REVIEW_BEFORE_MOVING.txt" "batch*.txt" "comparison_batches.txt" "2T-Xx_inventory_report.txt" "FULL_HOME_REVIEW*.md" "gemini-conversation-*.json" "AVATARARTS_CONSOLIDATION_CHANGELOG.md"; do for file in ~/$pattern; do if [ -f "$file" ] && [[ "$file" != ~/$pattern ]]; then filename=$(basename "$file") move "~/$filename → ~/archive/old-home-files/" home_archive_count=$((home_archive_count + 1)) fi done
done if [ $home_archive_count -gt 0 ]; then move "$home_archive_count old files from home directory → ~/archive/old-home-files/" archive_total=$((archive_total + home_archive_count))
fi count "TOTAL: ~/archive/ will contain $archive_total files" echo ""
preview "FINAL STRUCTURE SUMMARY"
echo "========================" grand_total=$((active_total + tools_total + archive_total)) echo ""
echo "🏗️ YOUR NEW ORGANIZED STRUCTURE:"
echo "==============================="
echo ""
echo "📁 ~/active/ ($active_total files) ← Daily workspace"
echo "├── projects/ ← Current development work"
echo "├── ai-research/ ← AI experimentation"
echo "├── avatar_utils.py ← Core utilities"
echo "├── MASTER_SNIPPETS.md ← Code snippets"
echo "└── [active project files]"
echo ""
echo "📁 ~/tools/ ($tools_total files) ← Development infrastructure"
echo "├── python-ecosystem/ ← Complete Python environment (6,134 files)"
echo "├── claude-config/ ← Claude AI configuration (11,469 files)"
echo "├── cursor-config/ ← Cursor IDE configuration (24,924 files)"
echo "├── mcp-config/ ← Model Context Protocol (5 files)"
echo "├── shell-scripts/ ← Automation scripts (792 files)"
echo "└── [utility scripts]"
echo ""
echo "📁 ~/archive/ ($archive_total files) ← Historical reference"
echo "├── old-archives/ ← Completed projects"
echo "└── old-home-files/ ← Archived loose files"
echo "" echo "🎯 IMPACT ANALYSIS:"
count "Files to organize: $grand_total"
count "Folders created: 3 main + subfolders"
count "Original locations preserved: YES (using cp, not mv)"
echo "" echo "🛡️ SAFETY MEASURES:"
status "Uses 'cp' (copy) not 'mv' (move) - originals stay intact"
status "Comprehensive preview before any changes"
status "Can rollback by deleting new folders if needed"
status "Shell aliases and navigation helpers included"
echo "" echo "🚀 EXECUTION PLAN:"
echo "=================="
echo "1. Run: ~/implement_intuitive_organization.sh"
echo "2. Test: cd ~/active && ls (verify current work is there)"
echo "3. Test: cd ~/tools && ls (verify infrastructure is there)"
echo "4. Test: nav (see the navigation overview)"
echo "5. Optional: Remove original folders after verification"
echo "" echo "🎯 READY?"
echo "========"
echo ""
echo "This will transform your scattered 47K+ files into:"
echo "• Intuitive daily workflow (~/active/)"
echo "• Centralized development tools (~/tools/)"
echo "• Organized historical reference (~/archive/)"
echo ""
warning "No files will be deleted - everything gets copied to new organized locations."
echo ""
status "Preview complete! Run implementation when ready. 🚀"
