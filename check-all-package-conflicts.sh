#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Comprehensive conflict checker for all package managers

echo "🔍 Scanning All Package Managers for Conflicts..."
echo ""

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

CONFLICTS_FOUND=0

# 1. Check Homebrew
echo "=== Homebrew ==="
if command -v brew &> /dev/null; then
    echo "✅ Homebrew installed"
    
    # Check for broken dependencies
    echo "  Checking for broken dependencies..."
    BREW_BROKEN=$(brew missing 2>&1)
    if [ -n "$BREW_BROKEN" ] && [ "$BREW_BROKEN" != "No missing dependencies." ]; then
        echo -e "  ${YELLOW}⚠️  Missing dependencies:${NC}"
        echo "$BREW_BROKEN" | sed 's/^/    /'
        ((CONFLICTS_FOUND++))
    else
        echo "  ✅ No missing dependencies"
    fi
    
    # Check for outdated packages
    echo "  Checking for outdated packages..."
    BREW_OUTDATED=$(brew outdated 2>/dev/null | wc -l)
    if [ "$BREW_OUTDATED" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  $BREW_OUTDATED outdated packages${NC}"
        echo "    Run 'brew outdated' to see list"
    else
        echo "  ✅ All packages up to date"
    fi
    
    # Check for conflicting casks
    echo "  Checking for conflicting casks..."
    BREW_CONFLICTS=$(brew list --cask 2>/dev/null | wc -l)
    echo "  ℹ️  $BREW_CONFLICTS casks installed"
    
    # Check for duplicate Quick Look plugins (already fixed, but verify)
    echo "  Checking Quick Look plugins..."
    QL_DUPLICATES=$(find ~/Library/QuickLook -name "*.qlgenerator" -type f 2>/dev/null | wc -l)
    QL_SYMLINKS=$(find ~/Library/QuickLook -name "*.qlgenerator" -type l 2>/dev/null | wc -l)
    if [ "$QL_DUPLICATES" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  Found $QL_DUPLICATES plugin files (should be symlinks)${NC}"
        ((CONFLICTS_FOUND++))
    else
        echo "  ✅ All plugins are symlinks"
    fi
else
    echo "  ℹ️  Homebrew not installed"
fi

echo ""

# 2. Check Python/pip
echo "=== Python / pip ==="
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "✅ Python: $PYTHON_VERSION"
    
    # Check for pip
    if command -v pip3 &> /dev/null; then
        echo "✅ pip3 installed"
        
        # Check for conflicting packages
        echo "  Checking for conflicting packages..."
        PIP_LIST=$(pip3 list 2>/dev/null)
        
        # Check for duplicate packages
        PIP_DUPLICATES=$(echo "$PIP_LIST" | grep -iE "(quicklook|ql|preview)" | wc -l)
        if [ "$PIP_DUPLICATES" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠️  Found pip packages that might conflict:${NC}"
            echo "$PIP_LIST" | grep -iE "(quicklook|ql|preview)" | sed 's/^/    /'
            ((CONFLICTS_FOUND++))
        else
            echo "  ✅ No obvious conflicts"
        fi
        
        # Check for broken packages
        echo "  Checking for broken installations..."
        PIP_BROKEN=$(pip3 check 2>&1)
        if echo "$PIP_BROKEN" | grep -q "has requirement"; then
            echo -e "  ${RED}❌ Dependency conflicts found:${NC}"
            echo "$PIP_BROKEN" | sed 's/^/    /'
            ((CONFLICTS_FOUND++))
        else
            echo "  ✅ No dependency conflicts"
        fi
    else
        echo "  ℹ️  pip3 not found"
    fi
    
    # Check for multiple Python versions
    PYTHON_VERSIONS=$(ls -1 /usr/local/bin/python* /opt/homebrew/bin/python* 2>/dev/null | wc -l)
    if [ "$PYTHON_VERSIONS" -gt 2 ]; then
        echo -e "  ${YELLOW}⚠️  Multiple Python versions detected ($PYTHON_VERSIONS)${NC}"
    fi
else
    echo "  ℹ️  Python not installed"
fi

echo ""

# 3. Check Node.js/npm
echo "=== Node.js / npm ==="
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>&1)
    echo "✅ Node.js: $NODE_VERSION"
    
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version 2>&1)
        echo "✅ npm: $NPM_VERSION"
        
        # Check for global packages that might conflict
        echo "  Checking global packages..."
        NPM_GLOBAL=$(npm list -g --depth=0 2>/dev/null | grep -E "^\S" | tail -n +2)
        
        # Check for Quick Look related packages
        NPM_QL=$(echo "$NPM_GLOBAL" | grep -iE "(quicklook|ql|preview)" | wc -l)
        if [ "$NPM_QL" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠️  Found npm packages that might conflict:${NC}"
            echo "$NPM_GLOBAL" | grep -iE "(quicklook|ql|preview)" | sed 's/^/    /'
            ((CONFLICTS_FOUND++))
        fi
        
        # Check for audit issues
        echo "  Checking for security vulnerabilities..."
        NPM_AUDIT=$(npm audit --json 2>/dev/null | grep -o '"vulnerabilities":[0-9]*' | grep -o '[0-9]*')
        if [ -n "$NPM_AUDIT" ] && [ "$NPM_AUDIT" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠️  $NPM_AUDIT vulnerabilities found${NC}"
            echo "    Run 'npm audit' for details"
        else
            echo "  ✅ No critical vulnerabilities"
        fi
    else
        echo "  ℹ️  npm not found"
    fi
    
    # Check for multiple Node versions (nvm)
    if [ -d "$HOME/.nvm" ]; then
        echo -e "  ${YELLOW}ℹ️  nvm detected (multiple Node versions possible)${NC}"
    fi
else
    echo "  ℹ️  Node.js not installed"
fi

echo ""

# 4. Check Ruby/gem
echo "=== Ruby / gem ==="
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby --version 2>&1 | head -1)
    echo "✅ Ruby: $RUBY_VERSION"
    
    if command -v gem &> /dev/null; then
        echo "✅ gem installed"
        
        # Check for Quick Look related gems
        GEM_LIST=$(gem list 2>/dev/null)
        GEM_QL=$(echo "$GEM_LIST" | grep -iE "(quicklook|ql|preview)" | wc -l)
        if [ "$GEM_QL" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠️  Found gems that might conflict:${NC}"
            echo "$GEM_LIST" | grep -iE "(quicklook|ql|preview)" | sed 's/^/    /'
            ((CONFLICTS_FOUND++))
        else
            echo "  ✅ No obvious conflicts"
        fi
    else
        echo "  ℹ️  gem not found"
    fi
else
    echo "  ℹ️  Ruby not installed"
fi

echo ""

# 5. Check system extensions
echo "=== System Extensions ==="
echo "  Checking Quick Look extensions..."
QL_EXTENSIONS=$(systemextensionsctl list 2>/dev/null | grep -i quicklook | wc -l)
if [ "$QL_EXTENSIONS" -gt 0 ]; then
    echo -e "  ${YELLOW}ℹ️  $QL_EXTENSIONS Quick Look extensions found${NC}"
    systemextensionsctl list 2>/dev/null | grep -i quicklook | sed 's/^/    /'
else
    echo "  ✅ No system extensions found"
fi

echo ""

# 6. Check for duplicate binaries in PATH
echo "=== PATH Conflicts ==="
echo "  Checking for duplicate commands in PATH..."
DUPLICATES=$(for cmd in python python3 node npm pip pip3 brew gem; do
    which -a "$cmd" 2>/dev/null | wc -l | awk -v c="$cmd" '{if($1>1) print c": "$1" versions"}'
done)

if [ -n "$DUPLICATES" ]; then
    echo -e "  ${YELLOW}⚠️  Multiple versions in PATH:${NC}"
    echo "$DUPLICATES" | sed 's/^/    /'
    ((CONFLICTS_FOUND++))
else
    echo "  ✅ No duplicate commands in PATH"
fi

echo ""

# 7. Check for conflicting library paths (excluding false positives)
echo "=== Library Path Conflicts ==="
# Only look for actual Quick Look generators, ignore database/code libraries
CONFLICTING_LIBS=$(find /usr/local/lib /opt/homebrew/lib ~/.local/lib -name "*quicklook*" -o -name "*ql*" 2>/dev/null | \
    grep -v "node_modules" | grep -v "sqlite" | grep -v "sqlstring" | grep -v "pandas.*sql" | \
    grep -v "__pycache__" | grep -v "tdbc" | grep -v "postgresql" | grep -v "mysql" | \
    grep -v "pygments.*qlik" | grep -v "qlik" | grep -i "quicklook\|\.qlgenerator" | head -5)
if [ -n "$CONFLICTING_LIBS" ]; then
    echo -e "  ${YELLOW}⚠️  Found Quick Look related libraries:${NC}"
    echo "$CONFLICTING_LIBS" | sed 's/^/    /'
    ((CONFLICTS_FOUND++))
else
    echo "  ✅ No conflicting libraries found"
    echo "  ℹ️  (Ignoring database/code libraries - not Quick Look conflicts)"
fi

echo ""

# 8. Check for conflicting environment variables (excluding config vars)
echo "=== Environment Variables ==="
ENV_CONFLICTS=$(env | grep -iE "(QUICKLOOK|QL_)" | grep -v "FZF_DEFAULT_OPTS" | wc -l)
if [ "$ENV_CONFLICTS" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠️  Found Quick Look related environment variables:${NC}"
    env | grep -iE "(QUICKLOOK|QL_)" | grep -v "FZF_DEFAULT_OPTS" | sed 's/^/    /'
    ((CONFLICTS_FOUND++))
else
    echo "  ✅ No conflicting environment variables"
    echo "  ℹ️  (FZF_DEFAULT_OPTS is a config variable, not a conflict)"
fi

echo ""

# Summary
echo "=========================================="
if [ "$CONFLICTS_FOUND" -eq 0 ]; then
    echo -e "${GREEN}✅ No conflicts found!${NC}"
else
    echo -e "${YELLOW}⚠️  Found $CONFLICTS_FOUND potential conflict(s)${NC}"
    echo ""
    echo "💡 Recommendations:"
    echo "  1. Review the warnings above"
    echo "  2. Update outdated packages: brew upgrade"
    echo "  3. Fix pip conflicts: pip3 check"
    echo "  4. Run npm audit: npm audit fix"
fi
echo "=========================================="
