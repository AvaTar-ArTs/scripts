#!/bin/bash
# 📊 **COMPREHENSIVE HOME DIRECTORY INVENTORY**
# Complete analysis of all files and folders for final organization

set -e

echo "📊 COMPREHENSIVE HOME DIRECTORY INVENTORY"
echo "========================================"

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
section() { echo -e "${PURPLE}📁 $1${NC}"; }
count() { echo -e "${CYAN}📊 $1${NC}"; }

# Function to safely count files
safe_count() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        find "$path" -type f 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

# Function to get directory size
dir_size() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        du -sh "$path" 2>/dev/null | cut -f1
    else
        echo "N/A"
    fi
}

# Function to analyze a directory
analyze_dir() {
    local path="$1"
    local category="$2"

    if [ ! -d "$path" ]; then
        return
    fi

    local file_count=$(safe_count "$path")
    local size=$(dir_size "$path")

    echo "$category|$path|$file_count|$size"
}

echo ""
info "Analyzing all directories in your home folder..."
echo ""

# Create temporary file for analysis
TEMP_FILE="/tmp/home_inventory_$(date +%s).txt"

# Header
echo "CATEGORY|PATH|FILES|SIZE" > "$TEMP_FILE"

# Analyze each directory from the user's list
echo "Scanning directories..."

# Already organized (from previous attempts)
analyze_dir "$HOME/active" "CURRENT_ACTIVE" >> "$TEMP_FILE"
analyze_dir "$HOME/dev" "CURRENT_DEV" >> "$TEMP_FILE"
analyze_dir "$HOME/tools" "CURRENT_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/archive" "CURRENT_ARCHIVE" >> "$TEMP_FILE"
analyze_dir "$HOME/products" "CURRENT_PRODUCTS" >> "$TEMP_FILE"

# Project directories
analyze_dir "$HOME/AI_Chats" "PROJECT_AI" >> "$TEMP_FILE"
analyze_dir "$HOME/AI-Ecosystem" "PROJECT_AI" >> "$TEMP_FILE"
analyze_dir "$HOME/AI-Workspace" "PROJECT_AI" >> "$TEMP_FILE"
analyze_dir "$HOME/AutoTagger" "PROJECT_AUTOMATION" >> "$TEMP_FILE"
analyze_dir "$HOME/AVATARARTS" "PROJECT_AVATARARTS" >> "$TEMP_FILE"
analyze_dir "$HOME/DiGiTaLDiVe" "PROJECT_DIGITAL" >> "$TEMP_FILE"
analyze_dir "$HOME/MasterxEo" "PROJECT_MASTERXEO" >> "$TEMP_FILE"
analyze_dir "$HOME/MasterxEo " "PROJECT_MASTERXEO" >> "$TEMP_FILE"
analyze_dir "$HOME/nocTurneMeLoDieS" "PROJECT_MUSIC" >> "$TEMP_FILE"
analyze_dir "$HOME/projects" "PROJECT_GENERAL" >> "$TEMP_FILE"
analyze_dir "$HOME/rag_self_hosted_project" "PROJECT_AI" >> "$TEMP_FILE"
analyze_dir "$HOME/XEO" "PROJECT_XEO" >> "$TEMP_FILE"

# Development environments
analyze_dir "$HOME/aider-env" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/google-cloud-sdk" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/grok" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/n8n" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/node_modules" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/notebooklm-mcp" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/uv-demo" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/zsh-autocomplete" "DEV_ENVIRONMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/zsh-completions" "DEV_ENVIRONMENT" >> "$TEMP_FILE"

# Scripts and tools
analyze_dir "$HOME/avatararts-packaged-scripts" "SCRIPTS_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/bin" "SCRIPTS_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/clean" "SCRIPTS_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/Fixes" "SCRIPTS_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/github" "SCRIPTS_TOOLS" >> "$TEMP_FILE"
analyze_dir "$HOME/userscripts" "SCRIPTS_TOOLS" >> "$TEMP_FILE"

# Archives and backups
analyze_dir "$HOME/Archives" "ARCHIVES_BACKUPS" >> "$TEMP_FILE"
analyze_dir "$HOME/backups" "ARCHIVES_BACKUPS" >> "$TEMP_FILE"
analyze_dir "$HOME/reports" "ARCHIVES_BACKUPS" >> "$TEMP_FILE"
analyze_dir "$HOME/reports_2026" "ARCHIVES_BACKUPS" >> "$TEMP_FILE"

# Analysis and documentation
analyze_dir "$HOME/advanced_analysis_report" "ANALYSIS_DOCS" >> "$TEMP_FILE"
analyze_dir "$HOME/PHASE_3_ANALYSIS" "ANALYSIS_DOCS" >> "$TEMP_FILE"
analyze_dir "$HOME/python_syntax_fix_report" "ANALYSIS_DOCS" >> "$TEMP_FILE"
analyze_dir "$HOME/marketplace_consolidation" "ANALYSIS_DOCS" >> "$TEMP_FILE"
analyze_dir "$HOME/PROJECT_PREVIEW" "ANALYSIS_DOCS" >> "$TEMP_FILE"

# Development directories
analyze_dir "$HOME/Development" "DEVELOPMENT" >> "$TEMP_FILE"
analyze_dir "$HOME/docker_configs" "DEVELOPMENT" >> "$TEMP_FILE"

# Business/product
analyze_dir "$HOME/GumRoad" "BUSINESS_PRODUCT" >> "$TEMP_FILE"
analyze_dir "$HOME/Memory-Optimization-Tools" "BUSINESS_PRODUCT" >> "$TEMP_FILE"
analyze_dir "$HOME/Miniforge_Mamba_Analysis" "BUSINESS_PRODUCT" >> "$TEMP_FILE"

# Media and content
analyze_dir "$HOME/Movies" "MEDIA_CONTENT" >> "$TEMP_FILE"
analyze_dir "$HOME/Music" "MEDIA_CONTENT" >> "$TEMP_FILE"
analyze_dir "$HOME/Pictures" "MEDIA_CONTENT" >> "$TEMP_FILE"

# System directories (usually leave alone)
analyze_dir "$HOME/Applications" "SYSTEM_IGNORE" >> "$TEMP_FILE"
analyze_dir "$HOME/Desktop" "SYSTEM_IGNORE" >> "$TEMP_FILE"
analyze_dir "$HOME/Documents" "SYSTEM_IGNORE" >> "$TEMP_FILE"
analyze_dir "$HOME/Downloads" "SYSTEM_IGNORE" >> "$TEMP_FILE"
analyze_dir "$HOME/Library" "SYSTEM_IGNORE" >> "$TEMP_FILE"
analyze_dir "$HOME/Public" "SYSTEM_IGNORE" >> "$TEMP_FILE"

# Dot directories (usually leave alone)
analyze_dir "$HOME/.env.d" "DOT_CONFIG" >> "$TEMP_FILE"
analyze_dir "$HOME/.tagger" "DOT_CONFIG" >> "$TEMP_FILE"

echo ""
info "ANALYSIS COMPLETE"
echo "================="

# Display results by category
echo ""
section "CURRENT ORGANIZATION ATTEMPTS"
echo "=================================="
grep "CURRENT_" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

echo ""
section "ACTIVE PROJECTS"
echo "=================="
grep "PROJECT_" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

echo ""
section "DEVELOPMENT ENVIRONMENTS"
echo "=========================="
grep "DEV_ENVIRONMENT" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

echo ""
section "SCRIPTS & TOOLS"
echo "================"
grep "SCRIPTS_TOOLS" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

echo ""
section "ARCHIVES & BACKUPS"
echo "===================="
grep "ARCHIVES_BACKUPS" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

echo ""
section "ANALYSIS & DOCUMENTATION"
echo "==========================="
grep "ANALYSIS_DOCS" "$TEMP_FILE" | sort -t'|' -k3 -nr | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

# Calculate totals
echo ""
section "GRAND TOTALS"
echo "=============="

total_files=$(awk -F'|' 'NR>1 {sum += $3} END {print sum}' "$TEMP_FILE")
total_dirs=$(grep -c "|" "$TEMP_FILE")

count "Total directories analyzed: $((total_dirs - 1))"
count "Total files across all directories: $total_files"

# Top 10 largest directories
echo ""
section "TOP 10 LARGEST DIRECTORIES"
echo "============================"

grep "|" "$TEMP_FILE" | sort -t'|' -k3 -nr | head -10 | while IFS='|' read -r category path files size; do
    printf "%-20s %-40s %8s files %8s\n" "$category" "$(basename "$path")/" "$files" "$size"
done

# Save full report
FINAL_REPORT="$HOME/comprehensive_home_inventory_$(date +%Y%m%d_%H%M%S).txt"
cp "$TEMP_FILE" "$FINAL_REPORT"

echo ""
status "Complete inventory saved to: $FINAL_REPORT"

# Cleanup
rm "$TEMP_FILE"

echo ""
warning "KEY INSIGHTS:"
echo "=============="
echo "• You have multiple organization attempts already (active/, dev/, tools/, etc.)"
echo "• Massive project portfolio across AI, automation, music, digital content"
echo "• Many development environments (aider, n8n, grok, etc.)"
echo "• Substantial archives and backup collections"
echo "• Multiple analysis and documentation efforts"
echo ""
echo "🎯 RECOMMENDATION:"
echo "=================="
echo "Your ecosystem is too large for simple 3-folder organization."
echo "Consider a hybrid approach:"
echo ""
echo "📁 ~/work/          ← Merge active/ + current projects"
echo "📁 ~/environments/  ← All dev environments (aider-env, n8n, etc.)"
echo "📁 ~/tools/         ← Scripts and automation tools"
echo "📁 ~/projects/      ← All project directories"
echo "📁 ~/archive/       ← Consolidated archives"
echo "📁 ~/business/      ← GumRoad, marketplace, etc."
echo ""
status "Ready for next-level organization strategy!"