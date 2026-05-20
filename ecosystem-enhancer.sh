#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Ecosystem Evolution Enhancer
# Creates update scripts for components that currently lack them
# Part of the comprehensive evolution of your AI development ecosystem

# Text Color Variables
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
PURPLE='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
CLEAR='\033[0m'

# Emojis for progress indication
EMOJIS=("🔧" "⚙️" "🛠️" "🦾" "⚡" "🚀" "💡" "🌟" "🎯" "✅")

# Function to print with emoji
print_with_emoji() {
    local msg=$1
    local emoji=${EMOJIS[RANDOM % ${#EMOJIS[@]}]}
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

# Function to print status
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
}

# Function to create update script for a directory
create_update_script() {
    local dir_path=$1
    local component_name=$2
    
    if [ ! -d "$dir_path" ]; then
        print_status $YELLOW "⚠️  Directory $dir_path does not exist, skipping $component_name"
        return
    fi
    
    local update_script="$dir_path/update.sh"
    
    if [ ! -f "$update_script" ]; then
        print_with_emoji "Creating update script for $component_name"
        
        cat > "$update_script" << EOF
#!/bin/bash

# Auto-generated update script for $component_name
# Generated as part of the Ecosystem Evolution Enhancer

echo "🔄 Updating $component_name..."

# Navigate to the component directory
cd "\$(dirname "\$0")"

# If there's a Git repository, pull the latest changes
if [ -d .git ]; then
    echo "🔍 Detected Git repository, pulling latest changes..."
    git fetch origin
    git pull origin \$(git branch --show-current)
    if [ \$? -eq 0 ]; then
        echo "✅ Git repository updated successfully"
    else
        echo "⚠️  Git update failed or no changes to pull"
    fi
else
    echo "ℹ️  No Git repository detected, skipping Git update"
fi

# If there are Python dependencies, update them
if [ -f "requirements.txt" ]; then
    echo "🐍 Updating Python dependencies..."
    if command -v pip &> /dev/null; then
        pip install -r requirements.txt --upgrade
        echo "✅ Python dependencies updated"
    else
        echo "⚠️  pip not found, skipping Python dependency update"
    fi
elif [ -f "pyproject.toml" ]; then
    echo "🐍 Updating Python dependencies from pyproject.toml..."
    if command -v pip &> /dev/null; then
        pip install . --upgrade
        echo "✅ Python dependencies updated"
    else
        echo "⚠️  pip not found, skipping Python dependency update"
    fi
else
    echo "ℹ️  No Python requirements detected, skipping dependency update"
fi

# If there are Node.js dependencies, update them
if [ -f "package.json" ]; then
    echo "📦 Updating Node.js dependencies..."
    if command -v npm &> /dev/null; then
        npm update
        echo "✅ Node.js dependencies updated"
    elif command -v yarn &> /dev/null; then
        yarn upgrade
        echo "✅ Node.js dependencies updated with Yarn"
    else
        echo "⚠️  npm or yarn not found, skipping Node.js dependency update"
    fi
else
    echo "ℹ️  No Node.js package.json detected, skipping dependency update"
fi

# Run any custom update commands if they exist
if [ -f "custom-update.sh" ]; then
    echo "⚙️  Running custom update commands..."
    source custom-update.sh
    echo "✅ Custom update commands completed"
fi

echo "✅ $component_name update process completed"
EOF
        
        chmod +x "$update_script"
        print_status $GREEN "✅ Update script created for $component_name at $update_script"
    else
        print_status $YELLOW "⚠️  Update script already exists for $component_name"
    fi
}

# Main execution
print_status $BOLD $PURPLE "🔧 ECOSYSTEM EVOLUTION ENHANCER"
print_status $CYAN "=================================="
print_with_emoji "Enhancing your AI development ecosystem with update scripts"
echo ""

# Create update scripts for major components
create_update_script "/Users/steven/AutoTagger/v4-workspace" "AutoTagger"
create_update_script "/Users/steven/MasterxEo" "MasterxEo"
create_update_script "/Users/steven/xRoad" "xRoad"
create_update_script "/Users/steven/.claude" "Claude"
create_update_script "/Users/steven/.cursor" "Cursor"
create_update_script "/Users/steven/.qwen" "Qwen"
create_update_script "/Users/steven/.gemini" "Gemini"
create_update_script "/Users/steven/.grok" "Grok"
create_update_script "/Users/steven/.mcp-central" "MCP Central"
create_update_script "/Users/steven/.qodo" "Qodo"
create_update_script "/Users/steven/codebase_analysis" "Codebase Analysis"

# Create a master update script that coordinates all updates
MASTER_UPDATE_SCRIPT="/Users/steven/ecosystem-coordinator.sh"
print_with_emoji "Creating master ecosystem coordinator script"

cat > "$MASTER_UPDATE_SCRIPT" << EOF
#!/bin/bash

# Ecosystem Coordinator
# Coordinates updates across all components of the AI development ecosystem

echo "🌟 Starting comprehensive ecosystem coordination..."

# Define component update scripts
COMPONENTS=(
    "/Users/steven/AutoTagger/v4-workspace/update.sh"
    "/Users/steven/MasterxEo/update.sh"
    "/Users/steven/xRoad/update.sh"
    "/Users/steven/.claude/update.sh"
    "/Users/steven/.cursor/update.sh"
    "/Users/steven/.qwen/update.sh"
    "/Users/steven/.gemini/update.sh"
    "/Users/steven/.grok/update.sh"
    "/Users/steven/.mcp-central/update.sh"
    "/Users/steven/.qodo/update.sh"
    "/Users/steven/codebase_analysis/update.sh"
)

# Update each component
for component in "\${COMPONENTS[@]}"; do
    if [ -f "\$component" ]; then
        echo "🔄 Updating component: \$component"
        "\$component"
        if [ \$? -eq 0 ]; then
            echo "✅ Component \$component updated successfully"
        else
            echo "❌ Component \$component update failed"
        fi
    else
        echo "⚠️  Component update script not found: \$component"
    fi
    echo ""
done

# Run the evolution updater after component updates
echo "🔄 Running evolution updater..."
/Users/steven/scripts/evolution-updater.sh evolve-all

echo "✅ Ecosystem coordination completed!"
EOF

chmod +x "$MASTER_UPDATE_SCRIPT"
print_status $GREEN "✅ Master coordinator script created at $MASTER_UPDATE_SCRIPT"

print_with_emoji "Ecosystem evolution enhancement complete!"
print_status $CYAN "You now have:"
print_status $GREEN "• Update scripts for all major components"
print_status $GREEN "• A master coordinator script to update all components"
print_status $GREEN "• Enhanced ability to evolve your AI development ecosystem"

print_status $BOLD $PURPLE "🚀 Ready to evolve your ecosystem further!"
