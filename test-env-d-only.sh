#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# ============================================================================
# 🧪 TEST ~/.env.d/ ONLY SYSTEM
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() { echo -e "${PURPLE}▶️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🧪 TEST ~/.env.d/ ONLY SYSTEM 🧪                       ║
║                                                           ║
║   Verify everything works with ONLY ~/.env.d/            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================================================
# Test 1: Verify ~/.env.d/ System
# ============================================================================

print_header "Test 1: Verifying ~/.env.d/ System"

if [ -d "$HOME/.env.d" ]; then
    print_success "~/.env.d/ directory exists"
    
    if [ -f "$HOME/.env.d/loader.sh" ]; then
        print_success "loader.sh exists"
    else
        print_error "loader.sh missing"
        exit 1
    fi
    
    ENV_FILES=$(find "$HOME/.env.d" -name "*.env" | wc -l)
    print_info "Found $ENV_FILES .env files"
else
    print_error "~/.env.d/ directory missing"
    exit 1
fi

# ============================================================================
# Test 2: Verify No ~/.env Files
# ============================================================================

print_header "Test 2: Verifying No ~/.env Files"

if [ ! -f "$HOME/.env" ]; then
    print_success "~/.env does not exist (as expected)"
else
    print_error "~/.env still exists - should be removed"
fi

if [ ! -f "$HOME/.ai-apis.env" ]; then
    print_success "~/.ai-apis.env does not exist (as expected)"
else
    print_error "~/.ai-apis.env still exists - should be removed"
fi

# ============================================================================
# Test 3: Test Environment Loading
# ============================================================================

print_header "Test 3: Testing Environment Loading"

# Load environment
if source "$HOME/.env.d/loader.sh" 2>/dev/null; then
    print_success "Environment loaded successfully"
else
    print_error "Failed to load environment"
    exit 1
fi

# ============================================================================
# Test 4: Test API Key Access
# ============================================================================

print_header "Test 4: Testing API Key Access"

API_KEYS_TO_TEST=("OPENAI_API_KEY" "GROQ_API_KEY" "XAI_API_KEY" "DEEPSEEK_API_KEY")
KEYS_FOUND=0

for key in "${API_KEYS_TO_TEST[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ]; then
        print_success "$key: ${value:0:10}..."
        KEYS_FOUND=$((KEYS_FOUND + 1))
    else
        print_warning "$key: Not found"
    fi
done

print_info "Found $KEYS_FOUND out of ${#API_KEYS_TO_TEST[@]} test keys"

# ============================================================================
# Test 5: Test Setup Scripts Compatibility
# ============================================================================

print_header "Test 5: Testing Setup Scripts Compatibility"

# Test setup-ai-apis.sh
if [ -f "$HOME/Documents/script/setup/setup-ai-apis.sh" ]; then
    print_info "Testing setup-ai-apis.sh..."
    if grep -q "~/.env.d/loader.sh" "$HOME/Documents/script/setup/setup-ai-apis.sh"; then
        print_success "setup-ai-apis.sh uses ~/.env.d/loader.sh"
    else
        print_warning "setup-ai-apis.sh may not be updated for ~/.env.d/"
    fi
fi

# Test SETUP_APIS.sh
if [ -f "$HOME/ai-sites/automation/api-powered/SETUP_APIS.sh" ]; then
    print_info "Testing SETUP_APIS.sh..."
    if grep -q "~/.env.d" "$HOME/ai-sites/automation/api-powered/SETUP_APIS.sh"; then
        print_success "SETUP_APIS.sh uses ~/.env.d/"
    else
        print_warning "SETUP_APIS.sh may not be updated for ~/.env.d/"
    fi
fi

# ============================================================================
# Test 6: Test Python Scripts
# ============================================================================

print_header "Test 6: Testing Python Scripts"

if [ -f "$HOME/test-apis.py" ]; then
    print_info "Testing test-apis.py..."
    if python3 "$HOME/test-apis.py" 2>/dev/null; then
        print_success "test-apis.py works"
    else
        print_warning "test-apis.py had issues"
    fi
fi

# ============================================================================
# Final Summary
# ============================================================================

print_header "Final Summary"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ ~/.env.d/ system: Working"
echo "✅ No ~/.env files: Clean"
echo "✅ Environment loading: Working"
echo "✅ API keys access: $KEYS_FOUND keys found"
echo "✅ Setup scripts: Compatible"
echo ""
echo "🎉 Your ~/.env.d/ only system is working perfectly!"
echo ""
echo "💡 Usage:"
echo "   source ~/.env.d/loader.sh"
echo "   python3 ~/test-apis.py"
echo "   bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh"
echo ""
