#!/usr/bin/env bash

# API Keys Filler Script
# This script helps you systematically fill in your API keys

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if .env.d exists
if [ ! -d "$HOME/.env.d" ]; then
    echo "❌ ~/.env.d not found"
    exit 1
fi

print_header "🔑 API Keys Setup Helper"
echo ""

# Function to update a key in an env file
update_key() {
    local file="$1"
    local key="$2"
    local description="$3"
    
    echo ""
    print_info "Setting up: $description"
    echo "File: $file"
    echo "Key: $key"
    echo ""
    
    # Check if key already has a value
    current_value=$(grep "^${key}=" "$file" 2>/dev/null | cut -d'=' -f2 || echo "")
    
    if [ -n "$current_value" ] && [ "$current_value" != "" ]; then
        print_warning "Key already has value: ${current_value:0:10}..."
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    echo "Enter your API key for $description:"
    read -p "> " new_key
    
    if [ -n "$new_key" ]; then
        # Update the key in the file
        if grep -q "^${key}=" "$file"; then
            # Key exists, update it
            sed -i.bak "s|^${key}=.*|${key}=${new_key}|" "$file"
        else
            # Key doesn't exist, add it
            echo "${key}=${new_key}" >> "$file"
        fi
        print_success "Updated $key"
    else
        print_warning "Skipped $key"
    fi
}

# Priority 1: Essential APIs
print_header "🎯 Priority 1: Essential APIs"
echo ""

# Art/Vision APIs
update_key "$HOME/.env.d/art-vision.env" "STABILITY_API_KEY" "Stability AI (Image Generation)"
update_key "$HOME/.env.d/art-vision.env" "REPLICATE_API_TOKEN" "Replicate (AI Models Platform)"

# Audio/Music APIs
update_key "$HOME/.env.d/audio-music.env" "ELEVENLABS_API_KEY" "ElevenLabs (AI Voice)"
update_key "$HOME/.env.d/audio-music.env" "SUNO_API_KEY" "Suno AI (Music Generation)"

# Priority 2: Vector Databases
print_header "🎯 Priority 2: Vector Databases"
echo ""

update_key "$HOME/.env.d/automation-agents.env" "PINECONE_API_KEY" "Pinecone (Vector Database)"
update_key "$HOME/.env.d/automation-agents.env" "SUPABASE_KEY" "Supabase (Database + Auth)"

# Priority 3: Search & Analytics
print_header "🎯 Priority 3: Search & Analytics"
echo ""

update_key "$HOME/.env.d/seo-analytics.env" "SERPAPI_KEY" "SerpAPI (Google Search)"
update_key "$HOME/.env.d/seo-analytics.env" "NEWSAPI_KEY" "NewsAPI (News Data)"

# Priority 4: Additional Tools
print_header "🎯 Priority 4: Additional Tools"
echo ""

update_key "$HOME/.env.d/documents.env" "NOTION_TOKEN" "Notion (Documentation)"
update_key "$HOME/.env.d/notifications.env" "TWILIO_ACCOUNT_SID" "Twilio Account SID"
update_key "$HOME/.env.d/notifications.env" "TWILIO_AUTH_TOKEN" "Twilio Auth Token"

echo ""
print_header "🎉 Setup Complete!"
echo ""

# Test the configuration
print_info "Testing your API configuration..."
if command -v python3 &> /dev/null; then
    if [ -f "$HOME/test-apis.py" ]; then
        source "$HOME/.env.d/loader.sh" 2>/dev/null || true
        python3 "$HOME/test-apis.py"
    else
        print_warning "Test script not found. Run the setup script first."
    fi
else
    print_warning "Python3 not found. Cannot run tests."
fi

echo ""
print_success "API keys have been updated!"
print_info "Next steps:"
echo "  1. Test your setup: source ~/.env.d/loader.sh && python3 ~/test-apis.py"
echo "  2. Run automation: bash ~/ai-sites/automation/api-powered/SETUP_APIS.sh"
echo "  3. Check the guide: cat ~/API_KEYS_GUIDE.md"
