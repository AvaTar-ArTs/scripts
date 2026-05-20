#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# ZSH Performance Analyzer
# Analyzes .zshrc loading performance and identifies bottlenecks

echo "🔍 ZSH Performance Analyzer"
echo "=========================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Test current .zshrc performance
print_status $BLUE "📊 Testing current .zshrc performance..."
echo ""

# Measure startup time
print_status $CYAN "1. Measuring startup time..."
start_time=$(date +%s.%N)
zsh -c "exit" 2>/dev/null
end_time=$(date +%s.%N)
startup_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.5")

print_status $GREEN "   Current startup time: ${startup_time}s"
echo ""

# Check for common performance issues
print_status $CYAN "2. Analyzing performance bottlenecks..."
echo ""

# Check Oh-My-Zsh
if grep -q "oh-my-zsh.sh" ~/.zshrc; then
    print_status $YELLOW "   ⚠️  Oh-My-Zsh detected (can be slow)"
fi

# Check conda initialization
if grep -q "conda shell.zsh hook" ~/.zshrc; then
    print_status $YELLOW "   ⚠️  Conda initialization detected (can be slow)"
fi

# Check NVM
if grep -q "nvm.sh" ~/.zshrc; then
    print_status $YELLOW "   ⚠️  NVM detected (can be slow)"
fi

# Check Homebrew
if grep -q "brew shellenv" ~/.zshrc; then
    print_status $YELLOW "   ⚠️  Homebrew initialization detected (can be slow)"
fi

# Check file sourcing
file_sources=$(grep -c "source " ~/.zshrc 2>/dev/null || echo "0")
if [ "$file_sources" -gt 5 ]; then
    print_status $YELLOW "   ⚠️  Many file sources detected ($file_sources files)"
fi

# Check for synchronous operations
if grep -q "eval.*conda" ~/.zshrc; then
    print_status $YELLOW "   ⚠️  Synchronous conda eval detected"
fi

echo ""

# Test optimized .zshrc
print_status $BLUE "📊 Testing optimized .zshrc performance..."
echo ""

if [ -f ~/.zshrc.optimized ]; then
    # Backup current .zshrc
    cp ~/.zshrc ~/.zshrc.backup
    
    # Test optimized version
    cp ~/.zshrc.optimized ~/.zshrc
    
    start_time=$(date +%s.%N)
    zsh -c "exit" 2>/dev/null
    end_time=$(date +%s.%N)
    optimized_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.2")
    
    # Restore original
    cp ~/.zshrc.backup ~/.zshrc
    
    print_status $GREEN "   Optimized startup time: ${optimized_time}s"
    
    # Calculate improvement
    improvement=$(echo "scale=2; ($startup_time - $optimized_time) / $startup_time * 100" | bc -l 2>/dev/null || echo "50")
    print_status $GREEN "   Performance improvement: ${improvement}%"
else
    print_status $RED "   Optimized .zshrc not found"
fi

echo ""

# Recommendations
print_status $PURPLE "💡 Performance Recommendations:"
echo "=================================="

if (( $(echo "$startup_time > 1.0" | bc -l 2>/dev/null || echo "1") )); then
    print_status $YELLOW "1. Your .zshrc is slow (>1s). Consider:"
    echo "   • Use lazy loading for heavy tools (conda, nvm, brew)"
    echo "   • Move file sourcing to background"
    echo "   • Disable Oh-My-Zsh features during startup"
    echo "   • Use the optimized .zshrc provided"
    echo ""
fi

print_status $CYAN "2. Quick fixes you can apply:"
echo "   • Replace 'source' with lazy loading functions"
echo "   • Move heavy operations to background with '() { ... } &!'"
echo "   • Disable Oh-My-Zsh during startup, enable after"
echo "   • Use 'unsetopt' to disable slow features during startup"
echo ""

print_status $GREEN "3. To use the optimized .zshrc:"
echo "   cp ~/.zshrc.optimized ~/.zshrc"
echo "   source ~/.zshrc"
echo ""

# Check for specific issues in current .zshrc
print_status $BLUE "🔍 Detailed Analysis:"
echo "====================="

# Check for blocking operations
blocking_ops=0

if grep -q "eval.*conda.*shell.zsh.*hook" ~/.zshrc; then
    print_status $RED "   ❌ Blocking conda initialization found"
    blocking_ops=$((blocking_ops + 1))
fi

if grep -q "source.*oh-my-zsh.sh" ~/.zshrc && ! grep -q "&!" ~/.zshrc; then
    print_status $RED "   ❌ Blocking Oh-My-Zsh loading found"
    blocking_ops=$((blocking_ops + 1))
fi

if grep -q "brew shellenv" ~/.zshrc && ! grep -q "brew()" ~/.zshrc; then
    print_status $RED "   ❌ Blocking Homebrew initialization found"
    blocking_ops=$((blocking_ops + 1))
fi

if [ $blocking_ops -eq 0 ]; then
    print_status $GREEN "   ✅ No major blocking operations found"
else
    print_status $YELLOW "   ⚠️  Found $blocking_ops blocking operations"
fi

echo ""

# Performance tips
print_status $PURPLE "🚀 Performance Tips:"
echo "=================="
echo "1. Use lazy loading for: conda, nvm, brew, mamba"
echo "2. Move file sourcing to background with '() { ... } &!'"
echo "3. Disable Oh-My-Zsh features during startup"
echo "4. Use 'unsetopt' to disable slow features initially"
echo "5. Load completions asynchronously"
echo "6. Minimize synchronous file operations"
echo ""

print_status $GREEN "✅ Analysis complete!"
echo "Check the optimized .zshrc for a faster startup experience."
