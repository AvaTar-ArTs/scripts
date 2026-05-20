#!/bin/bash
# 🔍 **CONSOLIDATION PREVIEW**
# Shows exactly what will be moved where without making changes

set -e

echo "🔍 Ecosystem Consolidation Preview"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
preview() { echo -e "${CYAN}🔍 $1${NC}"; }
move() { echo -e "${PURPLE}➡️  $1${NC}"; }

# Initialize counters
total_files_to_move=0
total_dirs_to_create=0
potential_conflicts=0

echo "Analyzing current ecosystem..."
echo "=============================="

# Function to safely count files
safe_count() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        find "$path" -type f 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

safe_dir_count() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        find "$path" -type d 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

# Analyze current structure
echo ""
info "CURRENT ECOSYSTEM ANALYSIS"
echo "------------------------"

# Python ecosystem
pythons_files=$(safe_count "$HOME/pythons")
pythons_dirs=$(safe_dir_count "$HOME/pythons")
echo "🐍 $HOME/pythons/: $pythons_files files in $pythons_dirs directories"

# AI research
ai_research_files=$(safe_count "$HOME/workspace/ai_cli_research")
echo "🤖 $HOME/workspace/ai_cli_research/: $ai_research_files files"

# MCP infrastructure
mcp_servers_files=$(safe_count "$HOME/.config/mcp")
echo "🔗 $HOME/.config/mcp/: $mcp_servers_files files"

# Claude configurations
claude_files=$(safe_count "$HOME/.claude")
echo "🧠 $HOME/.claude/: $claude_files files"

# Cursor configurations
cursor_files=$(safe_count "$HOME/.cursor")
echo "🖥️  $HOME/.cursor/: $cursor_files files"

# Scripts
scripts_files=$(safe_count "$HOME/scripts")
echo "📜 $HOME/scripts/: $scripts_files files"

# Home directory clutter
home_files=$(ls -1 "$HOME" | grep -E '\.(py|md|txt|json|sh)$' | wc -l)
echo "🏠 Home directory scripts: $home_files files"

echo ""
preview "PROPOSED NEW STRUCTURE"
echo "======================"

cat << 'EOF'
🏠 ~/dev/                          # MAIN DEV HUB
├── 📁 core/                       # Core utilities & shared code
├── 🤖 ai/                         # ALL AI tools & agents
│   ├── claude/                    # Claude configurations
│   ├── cursor/                    # Cursor configurations
│   ├── shared/                    # Cross-platform AI utilities
│   └── examples/                  # AI integration examples
├── ⚙️  automation/                 # Process automation scripts
├── 📊 data/                       # Data processing & analysis
├── 🌐 web/                        # Web development tools
└── 🛠️  tools/                     # Development utilities

🎯 ~/products/                     # MARKETABLE PRODUCTS
├── 🤖 ai-agents/                  # AI agent toolkits
├── 🔗 mcp-suite/                  # MCP infrastructure
├── ⚙️  automation-bundles/        # Process automation
└── 💼 consulting-assets/          # Service delivery tools

🔬 ~/workspace/                    # ACTIVE PROJECTS
├── 📚 research/                   # AI CLI research
├── 🧪 prototypes/                 # New ideas
└── 👥 client-work/                # Paid projects

📦 ~/archive/                      # ORGANIZED STORAGE
├── 💾 backups/                    # System backups
├── 📤 exports/                    # Data exports
├── ✅ completed/                  # Finished projects
└── 🕰️  legacy/                    # Old code (preserved)
EOF

echo ""
preview "DETAILED MIGRATION PLAN"
echo "========================"

# Phase 1: Foundation Setup
echo ""
info "PHASE 1: Foundation Setup"
echo "Will create directories:"
move "~/dev/{core,ai,automation,data,web,tools}"
move "~/products/{ai-agents,mcp-suite,automation-bundles,consulting-assets}"
move "~/workspace/{research,prototypes,client-work}"
move "~/archive/{backups,exports,completed,legacy}"
total_dirs_to_create=$((total_dirs_to_create + 12))

echo "Will create Python packages (__init__.py files)"
echo "Will set up navigation system"

# Phase 2: Core Utilities Migration
echo ""
info "PHASE 2: Core Utilities Migration"
if [ -f ~/pythons/avatar_utils.py ]; then
    move "~/pythons/avatar_utils.py → ~/dev/core/avatar_utils.py"
    total_files_to_move=$((total_files_to_move + 1))
else
    warning "~/pythons/avatar_utils.py not found"
fi

if [ -f ~/pythons/MASTER_SNIPPETS.md ]; then
    move "~/pythons/MASTER_SNIPPETS.md → ~/dev/core/MASTER_SNIPPETS.md"
    total_files_to_move=$((total_files_to_move + 1))
else
    warning "~/pythons/MASTER_SNIPPETS.md not found"
fi

# Phase 3: AI Tools Consolidation
echo ""
info "PHASE 3: AI Tools Consolidation"
if [ -d ~/.claude ]; then
    claude_count=$(safe_count ~/.claude)
    move "~/.claude/ ($claude_count files) → ~/dev/ai/claude/"
    total_files_to_move=$((total_files_to_move + claude_count))
else
    warning "~/.claude/ directory not found"
fi

if [ -d ~/.cursor ]; then
    cursor_count=$(safe_count ~/.cursor)
    move "~/.cursor/ ($cursor_count files) → ~/dev/ai/cursor/"
    total_files_to_move=$((total_files_to_move + cursor_count))
else
    warning "~/.cursor/ directory not found"
fi

# Phase 4: Python Ecosystem Migration
echo ""
info "PHASE 4: Python Ecosystem Migration"

# Define migration mappings based on actual directory structure
migration_sources=(
    "$HOME/pythons/apis:$HOME/dev/tools/apis"
    "$HOME/pythons/data_processing:$HOME/dev/data"
    "$HOME/pythons/file_operations:$HOME/dev/tools/filesystem"
    "$HOME/pythons/media_processing:$HOME/dev/tools/media"
    "$HOME/pythons/tools:$HOME/dev/tools"
    "$HOME/pythons/llm:$HOME/dev/ai/llm"
    "$HOME/pythons/config:$HOME/dev/core/config"
    "$HOME/pythons/clean:$HOME/dev/tools/cleanup"
    "$HOME/pythons/testing:$HOME/dev/tools/testing"
    "$HOME/pythons/analysis:$HOME/dev/tools/code-analysis"
    "$HOME/pythons/archives:$HOME/archive/completed/archives"
    "$HOME/pythons/content:$HOME/dev/tools/content"
    "$HOME/pythons/data:$HOME/dev/data"
    "$HOME/pythons/documentation:$HOME/dev/tools/docs"
    "$HOME/pythons/other:$HOME/dev/tools/misc"
    "$HOME/pythons/projects:$HOME/workspace/prototypes"
    "$HOME/pythons/seo_marketing:$HOME/products/consulting-assets/seo"
    "$HOME/pythons/websites:$HOME/dev/web"
)

for mapping in "${migration_sources[@]}"; do
    IFS=':' read -r source dest <<< "$mapping"
    if [ -d "$source" ]; then
        file_count=$(safe_count "$source")
        if [ "$file_count" -gt 0 ]; then
            move "$source ($file_count files) → $dest/"
            total_files_to_move=$((total_files_to_move + file_count))
            total_dirs_to_create=$((total_dirs_to_create + 1))
        fi
    else
        warning "$source not found - will skip"
    fi
done

# Handle remaining loose files in ~/pythons/
loose_files=$(find ~/pythons -maxdepth 1 -type f -name "*.py" 2>/dev/null | wc -l)
if [ "$loose_files" -gt 0 ]; then
    info "Loose Python files in ~/pythons/: $loose_files files"
    move "~/pythons/*.py → ~/dev/tools/misc/ (loose files)"
    total_files_to_move=$((total_files_to_move + loose_files))
    total_dirs_to_create=$((total_dirs_to_create + 1))
fi

# Phase 5: MCP Infrastructure
echo ""
info "PHASE 5: MCP Infrastructure"
if [ -d ~/.config/mcp ]; then
    mcp_count=$(safe_count ~/.config/mcp)
    move "~/.config/mcp/ ($mcp_count files) → ~/products/mcp-suite/server/"
    total_files_to_move=$((total_files_to_move + mcp_count))
    total_dirs_to_create=$((total_dirs_to_create + 1))
else
    warning "~/.config/mcp/ not found"
fi

# Phase 6: Research Consolidation
echo ""
info "PHASE 6: Research Consolidation"
if [ -d ~/workspace/ai_cli_research ]; then
    research_count=$(safe_count ~/workspace/ai_cli_research)
    move "~/workspace/ai_cli_research/ ($research_count files) → ~/workspace/research/"
    total_files_to_move=$((total_files_to_move + research_count))
else
    warning "~/workspace/ai_cli_research/ not found"
fi

# Phase 7: Archive Old Structure
echo ""
info "PHASE 7: Archive & Cleanup"
echo "Will archive old directories to ~/archive/legacy/"
echo "Will remove redundant directories after verification"

# Check for potential conflicts
echo ""
warning "POTENTIAL CONFLICTS & ISSUES"
echo "============================="

# Check for existing target directories
if [ -d "$HOME/dev" ]; then
    warning "$HOME/dev/ already exists - will merge carefully"
    potential_conflicts=$((potential_conflicts + 1))
fi

if [ -d "$HOME/products" ]; then
    warning "$HOME/products/ already exists - will merge carefully"
    potential_conflicts=$((potential_conflicts + 1))
fi

# Check for large files that might need special handling
large_files=$(find "$HOME/pythons" "$HOME/workspace/ai_cli_research" "$HOME/.claude" "$HOME/.cursor" -type f -size +100M 2>/dev/null | wc -l)
if [ "$large_files" -gt 0 ]; then
    warning "Found $large_files files >100MB - will use copy instead of move for safety"
fi

# Check for symlinks
symlinks=$(find "$HOME/pythons" "$HOME/workspace/ai_cli_research" "$HOME/.claude" "$HOME/.cursor" -type l 2>/dev/null | wc -l)
if [ "$symlinks" -gt 0 ]; then
    warning "Found $symlinks symlinks - will preserve link relationships"
fi

echo ""
preview "SUMMARY & IMPACT ANALYSIS"
echo "=========================="

echo "📊 Files to move: $total_files_to_move"
echo "📁 Directories to create: $total_dirs_to_create"
echo "⚠️  Potential conflicts: $potential_conflicts"

echo ""
echo "🎯 BENEFITS OF CONSOLIDATION:"
echo "• Function-based organization (what code DOES vs where it came from)"
echo "• Single source of truth for each component"
echo "• Clear separation: development vs products vs research vs archive"
echo "• Easy navigation and maintenance"
echo "• Monetization-ready product structure"

echo ""
echo "🛡️  SAFETY MEASURES:"
echo "• All moves use 'cp' first, then verify, then optional 'rm'"
echo "• Old directories archived to ~/archive/legacy/ before removal"
echo "• Comprehensive validation at each step"
echo "• Ability to rollback if issues detected"

echo ""
echo "📋 EXECUTION PHASES:"
echo "1. ✅ Foundation setup (directories, navigation)"
echo "2. ✅ AI consolidation (already done)"
echo "3. 🔄 Python ecosystem migration"
echo "4. 🔄 MCP infrastructure packaging"
echo "5. 🔄 Product creation and documentation"
echo "6. 🔄 Cleanup and validation"

echo ""
echo "🚀 READY TO PROCEED?"
echo "==================="
echo "Run the following commands in order:"
echo "1. ~/consolidation_setup.sh      # Foundation"
echo "2. ~/consolidation_ai_setup.sh   # AI tools (already done)"
echo "3. ~/consolidation_migration.sh  # Python ecosystem"
echo "4. ~/consolidation_products.sh   # Product packaging"
echo "5. ~/consolidation_cleanup.sh    # Final cleanup"

echo ""
echo "Each script includes validation and can be run independently."
echo "The consolidation is designed to be safe and reversible."

echo ""
status "Preview complete! No files have been moved yet."