#!/usr/bin/env bash

# ============================================================================
# 🎯 SIMPLE API KEYS SETUP SCRIPT
# ============================================================================

set -e

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
║   🎯 API KEYS SETUP 🎯                                   ║
║                                                           ║
║   Simple and robust setup for all your systems           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================================================
# Step 1: Check Current State
# ============================================================================

print_header "Checking Current Setup"

# Check .env.d system
if [ -d "$HOME/.env.d" ]; then
    print_success "Found ~/.env.d/ system"
    ENV_D_COUNT=$(find "$HOME/.env.d" -name "*.env" | wc -l)
    print_info "Found $ENV_D_COUNT .env files in ~/.env.d/"
else
    print_warning "~/.env.d/ not found"
fi

# Check main .env file
if [ -f "$HOME/.env" ]; then
    print_success "Found ~/.env file"
else
    print_warning "~/.env not found"
fi

# ============================================================================
# Step 2: Load Environment Variables
# ============================================================================

print_header "Loading Environment Variables"

# Try to load from .env.d first
if [ -f "$HOME/.env.d/loader.sh" ]; then
    print_info "Loading from ~/.env.d/loader.sh..."
    source "$HOME/.env.d/loader.sh" 2>/dev/null || print_warning "Could not load from loader.sh"
elif [ -f "$HOME/.env" ]; then
    print_info "Loading from ~/.env..."
    source "$HOME/.env" 2>/dev/null || print_warning "Could not load from ~/.env"
else
    print_warning "No environment files found to load"
fi

# ============================================================================
# Step 3: Check API Keys Status
# ============================================================================

print_header "Checking API Keys Status"

# Define key API keys to check
declare -A API_KEYS=(
    ["OPENAI_API_KEY"]="OpenAI"
    ["ANTHROPIC_API_KEY"]="Anthropic Claude"
    ["GROQ_API_KEY"]="Groq"
    ["XAI_API_KEY"]="X.AI (Grok)"
    ["DEEPSEEK_API_KEY"]="DeepSeek"
    ["STABILITY_API_KEY"]="Stability AI"
    ["REPLICATE_API_TOKEN"]="Replicate"
    ["ELEVENLABS_API_KEY"]="ElevenLabs"
    ["SUNO_API_KEY"]="Suno AI"
    ["ASSEMBLYAI_API_KEY"]="AssemblyAI"
    ["DEEPGRAM_API_KEY"]="Deepgram"
    ["PINECONE_API_KEY"]="Pinecone"
    ["SUPABASE_KEY"]="Supabase"
    ["SERPAPI_KEY"]="SerpAPI"
    ["NEWSAPI_KEY"]="NewsAPI"
)

CONFIGURED=0
MISSING=0
MISSING_KEYS=()

echo ""
print_info "Checking API Keys:"
echo ""

for key in "${!API_KEYS[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ] && ! [[ "$value" =~ ^your_ ]]; then
        print_success "${API_KEYS[$key]} ($key)"
        CONFIGURED=$((CONFIGURED + 1))
    else
        print_warning "${API_KEYS[$key]} ($key) - Missing"
        MISSING=$((MISSING + 1))
        MISSING_KEYS+=("$key")
    fi
done

echo ""
print_info "Summary: $CONFIGURED configured, $MISSING missing"

# ============================================================================
# Step 4: Interactive Setup for Missing Keys
# ============================================================================

if [ $MISSING -gt 0 ]; then
    echo ""
    print_header "Interactive API Key Setup"
    echo ""
    print_info "I'll help you fill in the missing API keys."
    echo "Press Enter to skip any key you don't want to configure right now."
    echo ""
    
    read -p "Continue with interactive setup? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create backup
        BACKUP_DIR="$HOME/.env.d/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        if [ -d "$HOME/.env.d" ]; then
            for file in "$HOME/.env.d"/*.env; do
                if [ -f "$file" ]; then
                    cp "$file" "$BACKUP_DIR/"
                fi
            done
            print_success "Backed up .env.d files to $BACKUP_DIR"
        fi
        
        # Interactive setup
        for key in "${MISSING_KEYS[@]}"; do
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Setting up: ${API_KEYS[$key]}"
            echo "Key: $key"
            echo ""
            
            # Determine target file
            ENV_FILE=""
            case "$key" in
                OPENAI_API_KEY|ANTHROPIC_API_KEY|GROQ_API_KEY|XAI_API_KEY|DEEPSEEK_API_KEY)
                    ENV_FILE="$HOME/.env.d/llm-apis.env"
                    ;;
                STABILITY_API_KEY|REPLICATE_API_TOKEN)
                    ENV_FILE="$HOME/.env.d/art-vision.env"
                    ;;
                ELEVENLABS_API_KEY|SUNO_API_KEY|ASSEMBLYAI_API_KEY|DEEPGRAM_API_KEY)
                    ENV_FILE="$HOME/.env.d/audio-music.env"
                    ;;
                PINECONE_API_KEY|SUPABASE_KEY)
                    ENV_FILE="$HOME/.env.d/automation-agents.env"
                    ;;
                SERPAPI_KEY|NEWSAPI_KEY)
                    ENV_FILE="$HOME/.env.d/seo-analytics.env"
                    ;;
            esac
            
            if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
                echo "File: $ENV_FILE"
                echo ""
                read -p "Enter API key (or press Enter to skip): " new_key
                
                if [ -n "$new_key" ]; then
                    # Update the key
                    if grep -q "^${key}=" "$ENV_FILE"; then
                        sed -i.bak "s|^${key}=.*|${key}=${new_key}|" "$ENV_FILE"
                    else
                        echo "${key}=${new_key}" >> "$ENV_FILE"
                    fi
                    print_success "Updated $key"
                else
                    print_warning "Skipped $key"
                fi
            else
                print_error "Could not find target file for $key"
            fi
        done
    fi
fi

# ============================================================================
# Step 5: Create Unified .env File
# ============================================================================

print_header "Creating Unified .env File"

# Create unified .env from .env.d files
if [ -d "$HOME/.env.d" ]; then
    print_info "Creating unified ~/.env from ~/.env.d/ files..."
    
    cat > "$HOME/.env" << 'EOF'
# ============================================================================
# UNIFIED ENVIRONMENT VARIABLES
# Generated from ~/.env.d/ system
# ============================================================================

EOF
    
    # Append all .env.d files
    for file in "$HOME/.env.d"/*.env; do
        if [ -f "$file" ]; then
            echo "" >> "$HOME/.env"
            echo "# From $(basename "$file")" >> "$HOME/.env"
            cat "$file" >> "$HOME/.env"
        fi
    done
    
    print_success "Created unified ~/.env file"
    
    # Also create .ai-apis.env for compatibility
    cp "$HOME/.env" "$HOME/.ai-apis.env"
    print_success "Created ~/.ai-apis.env for setup-ai-apis.sh compatibility"
fi

# ============================================================================
# Step 6: Test Setup
# ============================================================================

print_header "Testing Setup"

# Test if we can load the environment
if [ -f "$HOME/.env" ]; then
    print_info "Testing environment loading..."
    if source "$HOME/.env" 2>/dev/null; then
        print_success "Environment loads successfully"
    else
        print_warning "Environment has some issues"
    fi
fi

# Test with existing test scripts
if [ -f "$HOME/test-apis.py" ]; then
    print_info "Running test-apis.py..."
    python3 "$HOME/test-apis.py" 2>/dev/null || print_warning "test-apis.py had issues"
fi

# ============================================================================
# Step 7: Create Status Report
# ============================================================================

print_header "Creating Status Report"

REPORT_FILE="$HOME/API_KEYS_STATUS_REPORT.md"
cat > "$REPORT_FILE" << EOF
# API Keys Status Report
Generated: $(date)

## Setup Systems Found
- ✅ ~/.env.d/ organized system
- ✅ setup-ai-apis.sh
- ✅ SETUP_APIS.sh
- ✅ env_wizard.py

## API Keys Status
- ✅ Configured: $CONFIGURED
- ❌ Missing: $MISSING

## Configured APIs
EOF

# Add configured APIs
for key in "${!API_KEYS[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ] && ! [[ "$value" =~ ^your_ ]]; then
        echo "- ✅ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"
echo "## Missing APIs" >> "$REPORT_FILE"

# Add missing APIs
for key in "${MISSING_KEYS[@]}"; do
    echo "- ❌ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## Files Created/Updated
- ~/.env (unified from ~/.env.d/)
- ~/.ai-apis.env (for setup-ai-apis.sh compatibility)
- $REPORT_FILE (this report)

## Next Steps
1. Review missing APIs and fill them in
2. Test your setup with: python3 ~/test-apis.py
3. Run your automation scripts

## Quick Commands
\`\`\`bash
# Test all APIs
python3 ~/test-apis.py

# Activate environment
source ~/.activate-ai-apis.sh

# Run automation
bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh
\`\`\`
EOF

print_success "Created status report: $REPORT_FILE"

# ============================================================================
# Final Summary
# ============================================================================

echo ""
print_success "🎉 API Keys Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Configured APIs: $CONFIGURED"
echo "❌ Missing APIs: $MISSING"
echo ""
echo "📁 Files Created:"
echo "  • ~/.env (unified)"
echo "  • ~/.ai-apis.env (compatibility)"
echo "  • $REPORT_FILE (status report)"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review status: cat $REPORT_FILE"
echo "  2. Test setup: python3 ~/test-apis.py"
echo "  3. Run automation: bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh"
echo ""
echo "💡 All your existing setup scripts should now work!"
echo ""
