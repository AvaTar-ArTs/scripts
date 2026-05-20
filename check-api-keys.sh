#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# ============================================================================
# 🔍 API KEYS CHECKER SCRIPT
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
║   🔍 API KEYS CHECKER 🔍                                 ║
║                                                           ║
║   Check what API keys you have configured                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================================================
# Load Environment Variables
# ============================================================================

print_header "Loading Environment Variables"

# Load from .env.d system
if [ -f "$HOME/.env.d/loader.sh" ]; then
    print_info "Loading from ~/.env.d/loader.sh..."
    source "$HOME/.env.d/loader.sh" 2>/dev/null || print_warning "Could not load from loader.sh"
elif [ -f "$HOME/.env" ]; then
    print_info "Loading from ~/.env..."
    source "$HOME/.env" 2>/dev/null || print_warning "Could not load from ~/.env"
fi

# ============================================================================
# Check API Keys
# ============================================================================

print_header "Checking API Keys Status"

# Define API keys to check
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
    ["COHERE_API_KEY"]="Cohere"
    ["FIREWORKS_API_KEY"]="Fireworks"
    ["RUNWAY_API_KEY"]="Runway"
    ["KAIBER_API_KEY"]="KAIber"
    ["PIKA_API_KEY"]="Pika"
    ["LEONARDO_API_KEY"]="Leonardo"
    ["INVIDEO_API_KEY"]="InVideo"
    ["SORAI_API_KEY"]="SORAI"
    ["QDRANT_API_KEY"]="Qdrant"
    ["CHROMADB_API_KEY"]="ChromaDB"
    ["ZEP_API_KEY"]="Zep"
    ["OPENROUTER_API_KEY"]="OpenRouter"
    ["LANGSMITH_API_KEY"]="LangSmith"
    ["TWILIO_ACCOUNT_SID"]="Twilio Account SID"
    ["TWILIO_AUTH_TOKEN"]="Twilio Auth Token"
    ["ZAPIER_API_KEY"]="Zapier"
    ["MAKE_API_KEY"]="Make"
    ["NOTION_TOKEN"]="Notion"
    ["SLITE_API_KEY"]="Slite"
    ["MOONVALLEY_API_KEY"]="Moonvalley"
    ["ARCGIS_API_KEY"]="ArcGIS"
    ["SUPERNORMAL_API_KEY"]="Supernormal"
    ["DESCRIPT_API_KEY"]="Descript"
    ["SONIX_API_KEY"]="Sonix"
    ["REVAI_API_KEY"]="Rev.ai"
    ["SPEECHMATICS_API_KEY"]="Speechmatics"
    ["AZURE_OPENAI_KEY"]="Azure OpenAI"
)

CONFIGURED=0
MISSING=0
CONFIGURED_KEYS=()
MISSING_KEYS=()

echo ""
print_info "Checking API Keys:"
echo ""

for key in "${!API_KEYS[@]}"; do
    value="${!key:-}"
    if [ -n "$value" ] && [ "$value" != "" ] && ! [[ "$value" =~ ^your_ ]] && ! [[ "$value" =~ ^# ]]; then
        # Show first 10 and last 4 characters for security
        masked_value="${value:0:10}...${value: -4}"
        print_success "${API_KEYS[$key]} ($key) = $masked_value"
        CONFIGURED=$((CONFIGURED + 1))
        CONFIGURED_KEYS+=("$key")
    else
        print_warning "${API_KEYS[$key]} ($key) - Missing"
        MISSING=$((MISSING + 1))
        MISSING_KEYS+=("$key")
    fi
done

echo ""
print_info "Summary: $CONFIGURED configured, $MISSING missing"

# ============================================================================
# Show Detailed Status
# ============================================================================

if [ $CONFIGURED -gt 0 ]; then
    echo ""
    print_header "Configured APIs"
    echo ""
    for key in "${CONFIGURED_KEYS[@]}"; do
        echo "  ✅ ${API_KEYS[$key]}"
    done
fi

if [ $MISSING -gt 0 ]; then
    echo ""
    print_header "Missing APIs"
    echo ""
    for key in "${MISSING_KEYS[@]}"; do
        echo "  ❌ ${API_KEYS[$key]}"
    done
fi

# ============================================================================
# Test Available APIs
# ============================================================================

if [ $CONFIGURED -gt 0 ]; then
    echo ""
    print_header "Testing Available APIs"
    echo ""
    
    # Test OpenAI if available
    if [ -n "${OPENAI_API_KEY:-}" ]; then
        print_info "Testing OpenAI API..."
        if python3 -c "
import os
from openai import OpenAI
try:
    client = OpenAI()
    response = client.chat.completions.create(
        model='gpt-3.5-turbo',
        messages=[{'role': 'user', 'content': 'Say \"API test successful!\" and nothing else.'}],
        max_tokens=10
    )
    print('✅ OpenAI API working:', response.choices[0].message.content)
except Exception as e:
    print('❌ OpenAI API error:', str(e))
" 2>/dev/null; then
            print_success "OpenAI API test passed"
        else
            print_warning "OpenAI API test failed"
        fi
    fi
    
    # Test other APIs if available
    if [ -n "${GROQ_API_KEY:-}" ]; then
        print_info "Testing Groq API..."
        if python3 -c "
import os
from groq import Groq
try:
    client = Groq()
    response = client.chat.completions.create(
        model='llama3-8b-8192',
        messages=[{'role': 'user', 'content': 'Say \"API test successful!\" and nothing else.'}],
        max_tokens=10
    )
    print('✅ Groq API working:', response.choices[0].message.content)
except Exception as e:
    print('❌ Groq API error:', str(e))
" 2>/dev/null; then
            print_success "Groq API test passed"
        else
            print_warning "Groq API test failed"
        fi
    fi
fi

# ============================================================================
# Create Summary Report
# ============================================================================

print_header "Creating Summary Report"

REPORT_FILE="$HOME/API_KEYS_DETAILED_REPORT.md"
cat > "$REPORT_FILE" << EOF
# Detailed API Keys Report
Generated: $(date)

## Summary
- ✅ Configured APIs: $CONFIGURED
- ❌ Missing APIs: $MISSING

## Configured APIs
EOF

for key in "${CONFIGURED_KEYS[@]}"; do
    echo "- ✅ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"
echo "## Missing APIs" >> "$REPORT_FILE"

for key in "${MISSING_KEYS[@]}"; do
    echo "- ❌ ${API_KEYS[$key]} ($key)" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## Next Steps

### If you have missing APIs you want to add:

1. **Open the appropriate .env.d file:**
   - LLM APIs: \`nano ~/.env.d/llm-apis.env\`
   - Art/Vision: \`nano ~/.env.d/art-vision.env\`
   - Audio/Music: \`nano ~/.env.d/audio-music.env\`
   - Automation: \`nano ~/.env.d/automation-agents.env\`
   - SEO/Analytics: \`nano ~/.env.d/seo-analytics.env\`

2. **Add your API keys:**
   \`\`\`
   API_KEY_NAME=your_actual_api_key_here
   \`\`\`

3. **Update unified .env file:**
   \`\`\`bash
   ./setup-api-keys-final.sh
   \`\`\`

### Test your setup:
\`\`\`bash
# Test all APIs
python3 ~/test-apis.py

# Run automation
bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh
\`\`\`
EOF

print_success "Created detailed report: $REPORT_FILE"

# ============================================================================
# Final Summary
# ============================================================================

echo ""
print_success "🎉 API Keys Check Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Configured APIs: $CONFIGURED"
echo "❌ Missing APIs: $MISSING"
echo ""
echo "📁 Report created: $REPORT_FILE"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review detailed report: cat $REPORT_FILE"
echo "  2. Add missing keys if needed"
echo "  3. Test your setup: python3 ~/test-apis.py"
echo "  4. Run automation: bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh"
echo ""
