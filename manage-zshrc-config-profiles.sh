#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# ZSH Configuration Manager
# Helps manage different .zshrc configurations for performance testing

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

show_help() {
    echo "ZSH Configuration Manager"
    echo "========================"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  backup     - Backup current .zshrc"
    echo "  restore    - Restore from backup"
    echo "  optimize   - Switch to optimized .zshrc"
    echo "  original   - Switch to original .zshrc"
    echo "  test       - Test performance of current config"
    echo "  status     - Show current configuration status"
    echo "  help       - Show this help message"
    echo ""
}

backup_config() {
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        print_status $GREEN "✅ Current .zshrc backed up"
    else
        print_status $RED "❌ No .zshrc found to backup"
    fi
}

restore_config() {
    local latest_backup=$(ls -t ~/.zshrc.backup.* 2>/dev/null | head -1)
    if [ -n "$latest_backup" ]; then
        cp "$latest_backup" ~/.zshrc
        print_status $GREEN "✅ Restored from $latest_backup"
    else
        print_status $RED "❌ No backup found"
    fi
}

switch_to_optimized() {
    if [ -f ~/.zshrc.optimized ]; then
        backup_config
        cp ~/.zshrc.optimized ~/.zshrc
        print_status $GREEN "✅ Switched to optimized .zshrc"
        print_status $YELLOW "💡 Run 'source ~/.zshrc' to apply changes"
    else
        print_status $RED "❌ Optimized .zshrc not found"
    fi
}

switch_to_original() {
    if [ -f ~/.zshrc.original ]; then
        backup_config
        cp ~/.zshrc.original ~/.zshrc
        print_status $GREEN "✅ Switched to original .zshrc"
        print_status $YELLOW "💡 Run 'source ~/.zshrc' to apply changes"
    else
        print_status $RED "❌ Original .zshrc not found"
    fi
}

test_performance() {
    print_status $BLUE "🧪 Testing current .zshrc performance..."
    
    # Measure startup time
    start_time=$(date +%s.%N)
    zsh -c "exit" 2>/dev/null
    end_time=$(date +%s.%N)
    startup_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.5")
    
    print_status $CYAN "Startup time: ${startup_time}s"
    
    if (( $(echo "$startup_time < 0.5" | bc -l 2>/dev/null || echo "0") )); then
        print_status $GREEN "✅ Excellent performance!"
    elif (( $(echo "$startup_time < 1.0" | bc -l 2>/dev/null || echo "0") )); then
        print_status $YELLOW "⚠️  Good performance, but could be better"
    else
        print_status $RED "❌ Slow performance - consider optimization"
    fi
}

show_status() {
    print_status $BLUE "📊 Current Configuration Status:"
    echo "================================="
    
    if [ -f ~/.zshrc ]; then
        print_status $GREEN "✅ .zshrc exists"
        
        # Check if it's optimized
        if grep -q "LAZY LOAD" ~/.zshrc; then
            print_status $GREEN "✅ Optimized configuration detected"
        else
            print_status $YELLOW "⚠️  Standard configuration detected"
        fi
        
        # Check for lazy loading
        lazy_functions=$(grep -c "() {" ~/.zshrc 2>/dev/null || echo "0")
        print_status $CYAN "Lazy load functions: $lazy_functions"
        
        # Check for background operations
        background_ops=$(grep -c "&!" ~/.zshrc 2>/dev/null || echo "0")
        print_status $CYAN "Background operations: $background_ops"
        
    else
        print_status $RED "❌ No .zshrc found"
    fi
    
    echo ""
    
    # Show available configurations
    print_status $BLUE "Available configurations:"
    if [ -f ~/.zshrc.optimized ]; then
        print_status $GREEN "✅ ~/.zshrc.optimized"
    else
        print_status $RED "❌ ~/.zshrc.optimized"
    fi
    
    if [ -f ~/.zshrc.original ]; then
        print_status $GREEN "✅ ~/.zshrc.original"
    else
        print_status $YELLOW "⚠️  ~/.zshrc.original (create with 'backup' command)"
    fi
    
    # Show backups
    backup_count=$(ls ~/.zshrc.backup.* 2>/dev/null | wc -l)
    if [ $backup_count -gt 0 ]; then
        print_status $CYAN "Backups available: $backup_count"
    fi
}

# Main execution
case "${1:-help}" in
    "backup")
        backup_config
        ;;
    "restore")
        restore_config
        ;;
    "optimize")
        switch_to_optimized
        ;;
    "original")
        switch_to_original
        ;;
    "test")
        test_performance
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_status $RED "Unknown command: $1"
        show_help
        ;;
esac
