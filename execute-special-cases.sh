#!/bin/bash
set -euo pipefail
# Special Cases Organization - Execution Script
# Generated: 2026-02-04 02:15:00

echo "🚀 EXECUTING SPECIAL CASES ORGANIZATION"
echo "========================================="
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p ~/Development/active
mkdir -p ~/AI-Workspace/projects
mkdir -p ~/AI-Workspace/data/openai-logs
mkdir -p ~/XEO/docs
echo "✅ Directories created"
echo ""

# Move development projects
echo "💻 Moving development projects..."
if [ -d ~/eigent ]; then
    mv ~/eigent ~/Development/active/
    echo "  ✅ eigent → ~/Development/active/"
fi

if [ -d ~/hyper ]; then
    mv ~/hyper ~/Development/active/
    echo "  ✅ hyper → ~/Development/active/"
fi
echo ""

# Move AI projects
echo "🤖 Moving AI projects..."
if [ -d ~/IntelliHub ]; then
    mv ~/IntelliHub ~/AI-Workspace/projects/
    echo "  ✅ IntelliHub → ~/AI-Workspace/projects/"
fi

if [ -d ~/gol-ia-newq ]; then
    mv ~/gol-ia-newq ~/AI-Workspace/data/openai-logs/
    echo "  ✅ gol-ia-newq → ~/AI-Workspace/data/openai-logs/"
fi

if [ -d ~/agents ]; then
    mkdir -p ~/AI-Workspace/projects/swarm-orchestrator
    mv ~/agents/* ~/AI-Workspace/projects/swarm-orchestrator/ 2>/dev/null
    rmdir ~/agents
    echo "  ✅ agents → ~/AI-Workspace/projects/swarm-orchestrator/"
fi
echo ""

# Move business documentation
echo "📚 Moving business documentation..."
if [ -d ~/Documentation/xEo-Docs ]; then
    mv ~/Documentation/xEo-Docs ~/XEO/docs
    echo "  ✅ xEo-Docs → ~/XEO/docs/"
fi

if [ -d ~/Documentation ]; then
    rmdir ~/Documentation 2>/dev/null && echo "  ✅ Removed empty Documentation/" || echo "  ⚠️  Documentation/ not empty - review manually"
fi
echo ""

# Delete obsolete
echo "🗑️  Deleting obsolete files..."
if [ -d ~/Cursor_Workspace_Export ]; then
    rm -rf ~/Cursor_Workspace_Export
    echo "  ✅ Deleted Cursor_Workspace_Export"
fi
echo ""

# Verification
echo "========================================="
echo "✅ SPECIAL CASES ORGANIZATION COMPLETE!"
echo "========================================="
echo ""

echo "📊 Verification:"
echo "----------------"
echo ""

if [ -d ~/Development/active ]; then
    echo "Development projects:"
    ls -lh ~/Development/active/ 2>/dev/null | grep -E "^d" | awk '{print "  • " $9}' | head -10
    echo ""
fi

if [ -d ~/AI-Workspace/projects ]; then
    echo "AI projects:"
    ls -lh ~/AI-Workspace/projects/ 2>/dev/null | grep -E "^d" | awk '{print "  • " $9}' | head -10
    echo ""
fi

if [ -d ~/AI-Workspace/data ]; then
    echo "AI data:"
    ls -lh ~/AI-Workspace/data/ 2>/dev/null | grep -E "^d" | awk '{print "  • " $9}' | head -10
    echo ""
fi

if [ -d ~/XEO/docs ]; then
    echo "XEO documentation:"
    ls -lh ~/XEO/docs/ 2>/dev/null | grep -E "^d" | awk '{print "  • " $9}' | head -10
    echo ""
fi

echo "📈 Home directory status:"
ITEM_COUNT=$(ls -1 ~ | grep -v "^\." | wc -l | xargs)
echo "  Total items: $ITEM_COUNT"
echo ""

echo "🎯 Next steps:"
echo "  1. Review organized content in new locations"
echo "  2. Continue with broader home directory cleanup"
echo "  3. Organize remaining 300+ items into functional categories"
echo ""
