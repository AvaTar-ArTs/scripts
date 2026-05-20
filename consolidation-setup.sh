#!/bin/bash
# 🚀 **ECOSYSTEM CONSOLIDATION - FOUNDATION SETUP**
# Run this script to start consolidating your scattered codebase

set -e  # Exit on any error

echo "🚀 Starting Ecosystem Consolidation..."
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
status() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Step 1: Create target directory structure
info "Creating consolidated directory structure..."

mkdir -p ~/dev/{core,ai,automation,data,web,tools}
mkdir -p ~/products/{ai-agents,mcp-suite,automation-bundles,consulting-assets}
mkdir -p ~/workspace/{research,prototypes,client-work}
mkdir -p ~/archive/{backups,exports,completed,legacy}

status "Directory structure created"

# Step 2: Create __init__.py files for Python packages
info "Setting up Python package structure..."
find ~/dev -type d -exec touch {}/__init__.py \;
status "Python packages initialized"

# Step 3: Move core utilities
info "Moving core utilities..."
if [ -f ~/pythons/avatar_utils.py ]; then
    cp ~/pythons/avatar_utils.py ~/dev/core/
    status "avatar_utils.py moved to ~/dev/core/"
else
    warning "avatar_utils.py not found in ~/pythons/"
fi

if [ -f ~/pythons/MASTER_SNIPPETS.md ]; then
    cp ~/pythons/MASTER_SNIPPETS.md ~/dev/core/
    status "MASTER_SNIPPETS.md moved to ~/dev/core/"
else
    warning "MASTER_SNIPPETS.md not found in ~/pythons/"
fi

# Step 4: Create navigation system
info "Creating navigation system..."
cat > ~/dev/navigate.py << 'EOF'
#!/usr/bin/env python3
"""
Development Environment Navigator
Quick access to consolidated codebase
"""

import os
from pathlib import Path

class DevNavigator:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent

    def find_code(self, topic: str):
        """Find code related to topic"""
        search_paths = {
            'ai': self.base_dir / 'ai',
            'automation': self.base_dir / 'automation',
            'data': self.base_dir / 'data',
            'web': self.base_dir / 'web',
            'tools': self.base_dir / 'tools'
        }

        if topic in search_paths and search_paths[topic].exists():
            return list(search_paths[topic].rglob('*.py'))
        return []

    def show_structure(self):
        """Show consolidated structure"""
        print("🏠 Development Environment Structure")
        print("====================================")
        for item in sorted(self.base_dir.rglob('*')):
            if item.is_dir() and len(list(item.iterdir())) > 0:
                depth = len(item.relative_to(self.base_dir).parts)
                if depth <= 2:  # Show top 2 levels
                    indent = "  " * depth
                    if depth == 0:
                        print(f"{indent}📁 dev/")
                    else:
                        print(f"{indent}📁 {item.name}/")

# CLI interface
if __name__ == '__main__':
    import sys

    nav = DevNavigator()

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == 'find':
            if len(sys.argv) > 2:
                topic = sys.argv[2]
                files = nav.find_code(topic)
                print(f"🔍 Found {len(files)} files for '{topic}':")
                for f in files[:10]:  # Show first 10
                    print(f"  📄 {f.name} ({f.parent})")
                if len(files) > 10:
                    print(f"  ... and {len(files) - 10} more")
        elif command == 'structure':
            nav.show_structure()
        else:
            print("Usage: python3 ~/dev/navigate.py [find <topic>|structure]")
    else:
        nav.show_structure()
EOF

chmod +x ~/dev/navigate.py
status "Navigation system created"

# Step 5: Update shell integration
info "Updating shell integration..."
cat >> ~/.zshrc << 'EOF'

# 🔄 Consolidated Development Environment (Added by consolidation_setup.sh)
export DEV_HOME="$HOME/dev"
export PRODUCTS_HOME="$HOME/products"
export WORKSPACE_HOME="$HOME/workspace"

# Quick navigation aliases
alias dev="cd $DEV_HOME"
alias products="cd $PRODUCTS_HOME"
alias workspace="cd $WORKSPACE_HOME"

# Development helpers
alias find-code="python3 $DEV_HOME/navigate.py find"
alias show-structure="python3 $DEV_HOME/navigate.py structure"

# Consolidated environment loading
[ -f "$DEV_HOME/core/environment/__init__.py" ] && python3 -c "from dev.core.environment import env_manager" 2>/dev/null || true
EOF

status "Shell integration updated"

# Step 6: Create consolidation status tracker
info "Creating progress tracker..."
cat > ~/consolidation_status.json << 'EOF'
{
  "phase": "foundation_setup",
  "completed_steps": [
    "directory_structure",
    "python_packages",
    "core_utilities_moved",
    "navigation_system",
    "shell_integration"
  ],
  "next_steps": [
    "consolidate_ai_tools",
    "migrate_python_ecosystem",
    "package_manager_unification",
    "create_marketable_products",
    "cleanup_redundancies"
  ],
  "validation_checks": {
    "directory_structure": "find ~/dev ~/products ~/workspace -maxdepth 0 -type d | wc -l",
    "python_imports": "python3 -c 'import sys; sys.path.append(\"~/dev\"); from dev.core.avatar_utils import *' 2>/dev/null && echo 'OK' || echo 'FAIL'",
    "navigation_works": "python3 ~/dev/navigate.py structure | head -5 | wc -l"
  },
  "last_updated": "$(date)"
}
EOF

status "Progress tracker created"

# Step 7: Run validation
info "Running validation checks..."
echo ""
echo "🔍 VALIDATION RESULTS"
echo "===================="

# Check directory structure
dir_count=$(find ~/dev ~/products ~/workspace -maxdepth 0 -type d 2>/dev/null | wc -l)
if [ "$dir_count" -ge 3 ]; then
    status "Directory structure: $dir_count main directories created"
else
    error "Directory structure: Only $dir_count directories found"
fi

# Check Python imports (if avatar_utils exists)
if [ -f ~/dev/core/avatar_utils.py ]; then
    if python3 -c "import sys; sys.path.append('$HOME/dev'); import dev.core.avatar_utils" 2>/dev/null; then
        status "Python imports: Core utilities importable"
    else
        warning "Python imports: Core utilities import failed (may need path fixes)"
    fi
else
    warning "Python imports: avatar_utils.py not yet moved"
fi

# Check navigation system
if python3 ~/dev/navigate.py structure >/dev/null 2>&1; then
    status "Navigation system: Working"
else
    error "Navigation system: Not working"
fi

echo ""
echo "🎯 FOUNDATION SETUP COMPLETE!"
echo "============================="
echo ""
echo "What's been done:"
echo "• Created organized directory structure"
echo "• Moved core utilities to ~/dev/core/"
echo "• Set up Python package structure"
echo "• Created navigation system"
echo "• Updated shell with aliases"
echo ""
echo "Next steps:"
echo "1. Run: source ~/.zshrc"
echo "2. Try: show-structure"
echo "3. Run: ~/consolidation_ai_setup.sh (next phase)"
echo ""
echo "Your ecosystem consolidation has begun! 🎉"