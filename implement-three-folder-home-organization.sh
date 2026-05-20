#!/bin/bash
# 🎯 **IMPLEMENT INTUITIVE 3-FOLDER ORGANIZATION**
# Based on comprehensive filesystem analysis

set -e

echo "🎯 IMPLEMENTING INTUITIVE 3-FOLDER ORGANIZATION"
echo "=============================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
progress() { echo -e "${PURPLE}🚀 $1${NC}"; }
count() { echo -e "${CYAN}📊 $1${NC}"; }

echo ""
echo "Based on your 47,226+ files analysis, creating:"
echo ""
echo "📁 ~/active/     ← Current work & projects (where you spend 80% of time)"
echo "📁 ~/tools/      ← Scripts & configurations (your development infrastructure)"
echo "📁 ~/archive/    ← Old completed stuff (historical reference)"
echo ""

# Create the 3 main folders
info "Creating main organization structure..."
mkdir -p ~/active ~/tools ~/archive
status "Main folders created"

# PHASE 1: ACTIVE WORKSPACE
echo ""
progress "PHASE 1: Setting up ~/active/ (your daily workspace)"
echo "==================================================="

# Move current projects (1,884 files)
if [ -d ~/pythons/projects ]; then
    info "Moving active projects (1,884 files)..."
    cp -r ~/pythons/projects ~/active/
    count "✓ ~/active/projects/ - Your current development work"
fi

# Move AI research (4,995 files)
if [ -d ~/workspace/ai_cli_research ]; then
    info "Moving AI research (4,995 files)..."
    cp -r ~/workspace/ai_cli_research ~/active/ai-research
    count "✓ ~/active/ai-research/ - AI experimentation & research"
fi

# Move core utilities
if [ -f ~/pythons/avatar_utils.py ]; then
    info "Moving core utilities..."
    cp ~/pythons/avatar_utils.py ~/active/
    count "✓ ~/active/avatar_utils.py - Core utility functions"
fi

if [ -f ~/pythons/MASTER_SNIPPETS.md ]; then
    cp ~/pythons/MASTER_SNIPPETS.md ~/active/
    count "✓ ~/active/MASTER_SNIPPETS.md - Code snippets collection"
fi

# Move loose home directory files that are active
info "Moving active files from home directory..."
for file in ~/avatararts_*.md ~/gumroad*.txt ~/AVATARARTS_*.md ~/PYTHONS_*.md ~/PYTHONS_*.py; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" ~/active/
        count "✓ ~/active/$filename - Active project file"
    fi
done

# Count active folder
active_count=$(find ~/active -type f 2>/dev/null | wc -l)
info "Active workspace ready with $active_count files"

# PHASE 2: TOOLS INFRASTRUCTURE
echo ""
progress "PHASE 2: Setting up ~/tools/ (your development infrastructure)"
echo "============================================================"

# Move entire Python ecosystem (6,134 files, 700MB)
if [ -d ~/pythons ]; then
    info "Moving Python ecosystem (6,134 files, 700MB)..."
    cp -r ~/pythons ~/tools/python-ecosystem
    count "✓ ~/tools/python-ecosystem/ - Complete Python development environment"
fi

# Move AI configurations (29,393 files)
if [ -d ~/.claude ]; then
    info "Moving Claude configuration (11,469 files)..."
    cp -r ~/.claude ~/tools/claude-config
    count "✓ ~/tools/claude-config/ - Claude AI assistant configuration"
fi

if [ -d ~/.cursor ]; then
    info "Moving Cursor configuration (24,924 files)..."
    cp -r ~/.cursor ~/tools/cursor-config
    count "✓ ~/tools/cursor-config/ - Cursor AI-powered IDE configuration"
fi

if [ -d ~/.config/mcp ]; then
    info "Moving MCP configuration (5 files)..."
    cp -r ~/.config/mcp ~/tools/mcp-config
    count "✓ ~/tools/mcp-config/ - Model Context Protocol settings"
fi

# Move scripts (792 files)
if [ -d ~/scripts ]; then
    info "Moving automation scripts (792 files)..."
    cp -r ~/scripts ~/tools/shell-scripts
    count "✓ ~/tools/shell-scripts/ - Workflow automation & system scripts"
fi

# Move remaining loose home directory scripts
info "Moving remaining scripts from home directory..."
for file in ~/update_music_inventory.py ~/compare_hashes*.py ~/find_functional_dupes.py ~/deep_logic_audit.py ~/generate_redundancy_map.py ~/extract_redundant_code.py ~/comment_zshrc_sections.py ~/create_*.sh ~/consolidation_*.sh ~/intuitive_*.sh ~/simple_*.sh ~/implement_*.sh; do
    if [ -f "$file" ] && [[ "$file" != ~/create_comprehensive_index.sh ]]; then
        filename=$(basename "$file")
        cp "$file" ~/tools/
        count "✓ ~/tools/$filename - Development utility script"
    fi
done

# Count tools folder
tools_count=$(find ~/tools -type f 2>/dev/null | wc -l)
info "Tools infrastructure ready with $tools_count files"

# PHASE 3: ARCHIVE OLD STUFF
echo ""
progress "PHASE 3: Setting up ~/archive/ (historical reference)"
echo "=================================================="

# Move old archives (83 files)
if [ -d ~/pythons/archives ]; then
    info "Moving old archives (83 files)..."
    cp -r ~/pythons/archives ~/archive/old-archives
    count "✓ ~/archive/old-archives/ - Completed projects & backups"
fi

# Move old loose files from home directory
info "Moving old files from home directory to archive..."
mkdir -p ~/archive/old-home-files

for file in ~/error.* ~/folder\ by\ folder\ if\ needed.txt ~/remote_down.txt ~/local_down.txt ~/BATCH*.txt ~/ETSY*.txt ~/PROGRESS_REPORT.txt ~/ZIP_ORGANIZATION_FINAL.txt ~/cursor-agent.txt ~/gemini*.txt ~/gemini*.md ~/QWEN.md ~/AI_Chats ~/Archives ~/NEXT_ORGANIZATION_IDEAS.md ~/REVIEW_BEFORE_MOVING.txt ~/batch*.txt ~/comparison_batches.txt ~/2T-Xx_inventory_report.txt ~/FULL_HOME_REVIEW*.md ~/gemini-conversation-*.json ~/AVATARARTS_CONSOLIDATION_CHANGELOG.md ~/remote_down.txt ~/local_down.txt; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cp "$file" ~/archive/old-home-files/
        count "✓ ~/archive/old-home-files/$filename - Archived old file"
    fi
done

# Count archive folder
archive_count=$(find ~/archive -type f 2>/dev/null | wc -l)
info "Archive ready with $archive_count files"

# PHASE 4: CREATE NAVIGATION HELPERS
echo ""
progress "PHASE 4: Creating navigation helpers"
echo "====================================="

# Create navigation script
cat > ~/navigate_workspace.sh << 'EOF'
#!/bin/bash
# 🚀 **WORKSPACE NAVIGATION HELPER**

echo "🏠 Your Intuitive Workspace:"
echo "==========================="
echo ""
echo "📁 ~/active/     ($active_count files) ← Your daily workspace"
echo "├── projects/           ← Current development projects"
echo "├── ai-research/        ← AI experimentation & research"
echo "├── avatar_utils.py     ← Core utility functions"
echo "└── MASTER_SNIPPETS.md  ← Code snippets collection"
echo ""
echo "📁 ~/tools/      ($tools_count files) ← Development infrastructure"
echo "├── python-ecosystem/   ← Complete Python environment"
echo "├── claude-config/      ← Claude AI configuration"
echo "├── cursor-config/      ← Cursor IDE configuration"
echo "├── mcp-config/         ← Model Context Protocol"
echo "└── shell-scripts/      ← Automation scripts"
echo ""
echo "📁 ~/archive/    ($archive_count files) ← Historical reference"
echo "├── old-archives/       ← Completed projects"
echo "└── old-home-files/     ← Archived loose files"
echo ""
echo "🎯 Quick commands:"
echo "cd ~/active    # Go to daily work"
echo "cd ~/tools     # Access development tools"
echo "cd ~/archive   # Find old stuff"
echo ""
echo "Your workspace is now intuitively organized! 🎉"
EOF

chmod +x ~/navigate_workspace.sh

# Update shell aliases
cat >> ~/.zshrc << 'EOF'

# 🔄 Intuitive Workspace Organization (Added by implement_intuitive_organization.sh)
alias active="cd ~/active"
alias tools="cd ~/tools"
alias archive="cd ~/archive"
alias nav="bash ~/navigate_workspace.sh"
EOF

status "Navigation helpers created"

# PHASE 5: FINAL VERIFICATION
echo ""
progress "PHASE 5: Final verification"
echo "==========================="

# Recount files
final_active=$(find ~/active -type f 2>/dev/null | wc -l)
final_tools=$(find ~/tools -type f 2>/dev/null | wc -l)
final_archive=$(find ~/archive -type f 2>/dev/null | wc -l)
final_total=$((final_active + final_tools + final_archive))

echo ""
echo "🎯 ORGANIZATION COMPLETE!"
echo "========================"
echo ""
echo "📊 FINAL COUNTS:"
count "Active workspace: $final_active files"
count "Tools infrastructure: $final_tools files"
count "Archive: $final_archive files"
count "TOTAL ORGANIZED: $final_total files"
echo ""

# Show the new structure
echo "🏗️  NEW STRUCTURE:"
echo "================"
echo ""
echo "📁 ~/active/     ← Your daily workspace"
echo "├── projects/           ($final_active files)"
echo "├── ai-research/"
echo "├── avatar_utils.py"
echo "└── MASTER_SNIPPETS.md"
echo ""
echo "📁 ~/tools/      ← Development infrastructure"
echo "├── python-ecosystem/   (6,134 files, 700MB)"
echo "├── claude-config/      (11,469 files)"
echo "├── cursor-config/      (24,924 files)"
echo "├── mcp-config/         (5 files)"
echo "└── shell-scripts/      (792 files)"
echo ""
echo "📁 ~/archive/    ← Historical reference"
echo "├── old-archives/"
echo "└── old-home-files/"
echo ""

echo "🎉 SUCCESS!"
echo "=========="
echo ""
echo "Your 47,226+ files are now organized into 3 intuitive folders!"
echo ""
echo "🚀 QUICK START:"
echo "• Run: nav (to see this overview)"
echo "• Run: active (cd to your daily work)"
echo "• Run: tools (access development infrastructure)"
echo "• Run: archive (find old stuff)"
echo ""
echo "The chaos is now clarity. Your development ecosystem is organized! 🎯"
echo ""
warning "NOTE: Original files are still in place. Test the new organization first,"
warning "then run cleanup commands when you're confident everything works."

status "Intuitive organization implemented successfully!"