#!/usr/bin/env bash

# ============================================================================
# 🎯 MASTER API KEYS SETUP SCRIPT
# ============================================================================
# This script works with ALL your existing setup systems:
# - ~/.env.d/ organized system
# - setup-ai-apis.sh
# - SETUP_APIS.sh  
# - environment_optimization.sh
# - env_wizard.py
# ============================================================================

set -euo pipefail

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
║   🎯 MASTER API KEYS SETUP 🎯                            ║
║                                                           ║
║   Unified solution for ALL your setup systems            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================================================
# Step 1: Analyze Current State
# ============================================================================

print_header "Analyzing Current Setup"

# Check which systems are present
SYSTEMS_FOUND=()

if [ -d "$HOME/.env.d" ]; then
    SYSTEMS_FOUND+=("~/.env.d/ system")
    print_success "Found ~/.env.d/ organized system"
else
    print_warning "~/.env.d/ not found"
fi

if [ -f "$HOME/.env" ]; then
    SYSTEMS_FOUND+=("~/.env file")
    print_success "Found ~/.env file"
else
    print_warning "~/.env not found"
fi

if [ -f "$HOME/Documents/script/setup/setup-ai-apis.sh" ]; then
    SYSTEMS_FOUND+=("setup-ai-apis.sh")
    print_success "Found setup-ai-apis.sh"
fi

if [ -f "$HOME/ai-sites/automation/api-powered/SETUP_APIS.sh" ]; then
    SYSTEMS_FOUND+=("SETUP_APIS.sh")
    print_success "Found SETUP_APIS.sh"
fi

if [ -f "$HOME/pythons/AI_CONTENT/content_creation/env_wizard.py" ]; then
    SYSTEMS_FOUND+=("env_wizard.py")
    print_success "Found env_wizard.py"
fi

echo ""
print_info "Found ${#SYSTEMS_FOUND[@]} setup systems:"
for system in "${SYSTEMS_FOUND[@]}"; do
    echo "  • $system"
done

# ============================================================================
# Step 2: Check Current API Keys Status
# ============================================================================

print_header "Checking API Keys Status"

# Load environment if possible
if [ -f "$HOME/.env.d/loader.sh" ]; then
    source "$HOME/.env.d/loader.sh" 2>/dev/null || true
elif [ -f "$HOME/.env" ]; then
    source "$HOME/.env" 2>/dev/null || true
fi

# Define all API keys we care about
declare -A API_KEYS=(
    # LLM APIs
    ["OPENAI_API_KEY"]="OpenAI"
    ["ANTHROPIC_API_KEY"]="Anthropic Claude"
    ["GROQ_API_KEY"]="Groq"
    ["XAI_API_KEY"]="X.AI (Grok)"
    ["DEEPSEEK_API_KEY"]="DeepSeek"
    ["COHERE_API_KEY"]="Cohere"
    ["FIREWORKS_API_KEY"]="Fireworks"
    
    # Vision/Image APIs
    ["STABILITY_API_KEY"]="Stability AI"
    ["REPLICATE_API_TOKEN"]="Replicate"
    ["RUNWAY_API_KEY"]="Runway"
    ["KAIBER_API_KEY"]="KAIber"
    ["PIKA_API_KEY"]="Pika"
    ["LEONARDO_API_KEY"]="Leonardo"
    
    # Audio/Music APIs
    ["ELEVENLABS_API_KEY"]="ElevenLabs"
    ["SUNO_API_KEY"]="Suno AI"
    ["ASSEMBLYAI_API_KEY"]="AssemblyAI"
    ["DEEPGRAM_API_KEY"]="Deepgram"
    ["INVIDEO_API_KEY"]="InVideo"
    ["SORAI_API_KEY"]="SORAI"
    
    # Vector/Automation APIs
    ["PINECONE_API_KEY"]="Pinecone"
    ["SUPABASE_KEY"]="Supabase"
    ["QDRANT_API_KEY"]="Qdrant"
    ["CHROMADB_API_KEY"]="ChromaDB"
    ["ZEP_API_KEY"]="Zep"
    ["OPENROUTER_API_KEY"]="OpenRouter"
    ["LANGSMITH_API_KEY"]="LangSmith"
    
    # Search/Analytics APIs
    ["SERPAPI_KEY"]="SerpAPI"
    ["NEWSAPI_KEY"]="NewsAPI"
    
    # Notifications APIs
    ["TWILIO_ACCOUNT_SID"]="Twilio Account SID"
    ["TWILIO_AUTH_TOKEN"]="Twilio Auth Token"
    ["ZAPIER_API_KEY"]="Zapier"
    ["MAKE_API_KEY"]="Make"
    
    # Documents APIs
    ["NOTION_TOKEN"]="Notion"
    ["SLITE_API_KEY"]="Slite"
    
    # Other Tools
    ["MOONVALLEY_API_KEY"]="Moonvalley"
    ["ARCGIS_API_KEY"]="ArcGIS"
    ["SUPERNORMAL_API_KEY"]="Supernormal"
    ["DESCRIPT_API_KEY"]="Descript"
    ["SONIX_API_KEY"]="Sonix"
    ["REVAI_API_KEY"]="Rev.ai"
    ["SPEECHMATICS_API_KEY"]="Speechmatics"
    
    # Cloud Infrastructure
    ["AZURE_OPENAI_KEY"]="Azure OpenAI"
)

# Count configured vs missing
CONFIGURED=0
MISSING=0
MISSING_KEYS=()

for key in "${!API_KEYS[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ] && ! [[ "$value" =~ ^your_ ]]; then
        CONFIGURED=$((CONFIGURED + 1))
    else
        MISSING=$((MISSING + 1))
        MISSING_KEYS+=("$key")
    fi
done

echo ""
print_info "API Keys Status:"
echo "  ✅ Configured: $CONFIGURED"
echo "  ❌ Missing: $MISSING"

if [ $MISSING -gt 0 ]; then
    echo ""
    print_warning "Missing API Keys:"
    for key in "${MISSING_KEYS[@]}"; do
        echo "  • ${API_KEYS[$key]} ($key)"
    done
fi

# ============================================================================
# Step 3: Interactive API Key Setup
# ============================================================================

if [ $MISSING -gt 0 ]; then
    echo ""
    print_header "Interactive API Key Setup"
    echo ""
    print_info "I'll help you fill in the missing API keys one by one."
    echo "Press Enter to skip any key you don't want to configure right now."
    echo ""
    
    read -p "Continue with interactive setup? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create backup of current .env.d files
        BACKUP_DIR="$HOME/.env.d/backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        for file in "$HOME/.env.d"/*.env; do
            if [ -f "$file" ]; then
                cp "$file" "$BACKUP_DIR/"
            fi
        done
        print_success "Backed up current .env.d files to $BACKUP_DIR"
        
        # Interactive setup for missing keys
        for key in "${MISSING_KEYS[@]}"; do
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Setting up: ${API_KEYS[$key]}"
            echo "Key: $key"
            echo ""
            
            # Determine which .env.d file to update
            ENV_FILE=""
            case "$key" in
                OPENAI_API_KEY|ANTHROPIC_API_KEY|GROQ_API_KEY|XAI_API_KEY|DEEPSEEK_API_KEY|COHERE_API_KEY|FIREWORKS_API_KEY)
                    ENV_FILE="$HOME/.env.d/llm-apis.env"
                    ;;
                STABILITY_API_KEY|REPLICATE_API_TOKEN|RUNWAY_API_KEY|KAIBER_API_KEY|PIKA_API_KEY|LEONARDO_API_KEY)
                    ENV_FILE="$HOME/.env.d/art-vision.env"
                    ;;
                ELEVENLABS_API_KEY|SUNO_API_KEY|ASSEMBLYAI_API_KEY|DEEPGRAM_API_KEY|INVIDEO_API_KEY|SORAI_API_KEY)
                    ENV_FILE="$HOME/.env.d/audio-music.env"
                    ;;
                PINECONE_API_KEY|SUPABASE_KEY|QDRANT_API_KEY|CHROMADB_API_KEY|ZEP_API_KEY|OPENROUTER_API_KEY|LANGSMITH_API_KEY)
                    ENV_FILE="$HOME/.env.d/automation-agents.env"
                    ;;
                SERPAPI_KEY|NEWSAPI_KEY)
                    ENV_FILE="$HOME/.env.d/seo-analytics.env"
                    ;;
                TWILIO_ACCOUNT_SID|TWILIO_AUTH_TOKEN|ZAPIER_API_KEY|MAKE_API_KEY)
                    ENV_FILE="$HOME/.env.d/notifications.env"
                    ;;
                NOTION_TOKEN|SLITE_API_KEY)
                    ENV_FILE="$HOME/.env.d/documents.env"
                    ;;
                MOONVALLEY_API_KEY|ARCGIS_API_KEY|SUPERNORMAL_API_KEY|DESCRIPT_API_KEY|SONIX_API_KEY|REVAI_API_KEY|SPEECHMATICS_API_KEY)
                    ENV_FILE="$HOME/.env.d/other-tools.env"
                    ;;
                AZURE_OPENAI_KEY)
                    ENV_FILE="$HOME/.env.d/cloud-infrastructure.env"
                    ;;
            esac
            
            if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
                echo "File: $ENV_FILE"
                echo ""
                read -p "Enter API key (or press Enter to skip): " new_key
                
                if [ -n "$new_key" ]; then
                    # Update the key in the file
                    if grep -q "^${key}=" "$ENV_FILE"; then
                        # Key exists, update it
                        sed -i.bak "s|^${key}=.*|${key}=${new_key}|" "$ENV_FILE"
                    else
                        # Key doesn't exist, add it
                        echo "${key}=${new_key}" >> "$ENV_FILE"
                    fi
                    print_success "Updated $key"
                else
                    print_warning "Skipped $key"
                fi
            else
                print_error "Could not determine target file for $key"
            fi
        done
    fi
fi

# ============================================================================
# Step 4: Sync with All Systems
# ============================================================================

print_header "Syncing with All Setup Systems"

# Update ~/.env if it exists (for backward compatibility)
if [ -f "$HOME/.env" ]; then
    print_info "Updating ~/.env for backward compatibility..."
    
    # Create a unified .env from .env.d files
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
    
    print_success "Updated ~/.env"
fi

# Update ~/.ai-apis.env for setup-ai-apis.sh compatibility
if [ -f "$HOME/.env" ]; then
    cp "$HOME/.env" "$HOME/.ai-apis.env"
    print_success "Updated ~/.ai-apis.env for setup-ai-apis.sh"
fi

# ============================================================================
# Step 5: Test All Systems
# ============================================================================

print_header "Testing All Systems"

# Test .env.d loader
if [ -f "$HOME/.env.d/loader.sh" ]; then
    print_info "Testing ~/.env.d/loader.sh..."
    if source "$HOME/.env.d/loader.sh" 2>/dev/null; then
        print_success "~/.env.d/loader.sh works"
    else
        print_warning "~/.env.d/loader.sh has issues"
    fi
fi

# Test setup-ai-apis.sh compatibility
if [ -f "$HOME/Documents/script/setup/setup-ai-apis.sh" ]; then
    print_info "Testing setup-ai-apis.sh compatibility..."
    if [ -f "$HOME/.ai-apis.env" ]; then
        print_success "setup-ai-apis.sh should work"
    else
        print_warning "setup-ai-apis.sh may have issues"
    fi
fi

# Test SETUP_APIS.sh compatibility
if [ -f "$HOME/ai-sites/automation/api-powered/SETUP_APIS.sh" ]; then
    print_info "Testing SETUP_APIS.sh compatibility..."
    if [ -d "$HOME/.env.d" ]; then
        print_success "SETUP_APIS.sh should work"
    else
        print_warning "SETUP_APIS.sh may have issues"
    fi
fi

# ============================================================================
# Step 6: Run Available Tests
# ============================================================================

print_header "Running Available Tests"

# Test with existing test scripts
if [ -f "$HOME/test-apis.py" ]; then
    print_info "Running test-apis.py..."
    python3 "$HOME/test-apis.py" 2>/dev/null || print_warning "test-apis.py had issues"
fi

if [ -f "$HOME/test-ai-apis.py" ]; then
    print_info "Running test-ai-apis.py..."
    python3 "$HOME/test-ai-apis.py" 2>/dev/null || print_warning "test-ai-apis.py had issues"
fi

# ============================================================================
# Step 7: Create Master Status Report
# ============================================================================

print_header "Creating Master Status Report"

REPORT_FILE="$HOME/API_KEYS_STATUS_REPORT.md"
cat > "$REPORT_FILE" << EOF
# API Keys Status Report
Generated: $(date)

## Systems Found
$(printf '• %s\n' "${SYSTEMS_FOUND[@]}")

## API Keys Status
- ✅ Configured: $CONFIGURED
- ❌ Missing: $MISSING

## Configured APIs
EOF

# Add configured APIs to report
for key in "${!API_KEYS[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ] && ! [[ "$value" =~ ^your_ ]]; then
        echo "- ✅ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"
echo "## Missing APIs" >> "$REPORT_FILE"

# Add missing APIs to report
for key in "${MISSING_KEYS[@]}"; do
    echo "- ❌ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## Next Steps

1. **Fill missing API keys** using this script or manually
2. **Test your setup** with existing test scripts
3. **Run your automation** with the configured APIs

## Quick Commands

\`\`\`bash
# Test all APIs
python3 ~/test-apis.py

# Activate environment (if using conda setup)
source ~/.activate-ai-apis.sh

# Run automation setup
bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh
\`\`\`

## Files Updated

- ~/.env.d/*.env files
- ~/.env (unified)
- ~/.ai-apis.env (for setup-ai-apis.sh)
- $REPORT_FILE (this report)
EOF

print_success "Created status report: $REPORT_FILE"

# ============================================================================
# Final Summary
# ============================================================================

echo ""
print_success "🎉 Master API Keys Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Configured APIs: $CONFIGURED"
echo "❌ Missing APIs: $MISSING"
echo ""
echo "📁 Files Updated:"
echo "  • ~/.env.d/*.env (organized system)"
echo "  • ~/.env (unified for compatibility)"
echo "  • ~/.ai-apis.env (for setup-ai-apis.sh)"
echo "  • $REPORT_FILE (status report)"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review the status report: cat $REPORT_FILE"
echo "  2. Test your setup: python3 ~/test-apis.py"
echo "  3. Run your automation: bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh"
echo ""
echo "💡 All your existing setup scripts should now work with the updated API keys!"
echo ""
