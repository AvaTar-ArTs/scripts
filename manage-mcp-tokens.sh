#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# MCP Token Setup Helper
# Makes it easy to add API tokens to your Claude config

CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
BACKUP_PATH="$HOME/Documents/claude_config_backup_$(date +%Y%m%d_%H%M%S).json"

echo "======================================"
echo "MCP TOKEN SETUP HELPER"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Backup config
echo -e "${YELLOW}Creating backup...${NC}"
cp "$CONFIG_PATH" "$BACKUP_PATH"
echo -e "${GREEN}✓${NC} Backup saved to: $BACKUP_PATH"
echo ""

# Function to open URLs
open_url() {
    echo -e "${BLUE}Opening $1...${NC}"
    open "$2"
    sleep 2
}

# Main menu
while true; do
    echo ""
    echo "Which token do you want to add?"
    echo "1) GitHub Token (Recommended - most useful)"
    echo "2) Brave Search API Key"
    echo "3) Slack Bot Token"
    echo "4) View current config"
    echo "5) Open config file in editor"
    echo "6) Done - Restart Claude"
    echo "0) Exit"
    echo ""
    read -p "Choose (0-6): " choice

    case $choice in
        1)
            echo ""
            echo -e "${YELLOW}Setting up GitHub Token...${NC}"
            echo ""
            echo "I'll open GitHub's token page. You need to:"
            echo "1. Click 'Generate new token' (classic)"
            echo "2. Give it a name like 'Claude MCP'"
            echo "3. Check these boxes:"
            echo "   - repo (all sub-items)"
            echo "   - read:org"
            echo "   - workflow"
            echo "4. Click 'Generate token' at bottom"
            echo "5. Copy the token (starts with ghp_)"
            echo ""
            read -p "Press Enter to open GitHub... " 
            open_url "GitHub Token Page" "https://github.com/settings/tokens/new"
            
            echo ""
            read -p "Paste your GitHub token here: " github_token
            
            if [[ $github_token == ghp_* ]]; then
                # Update config using Python
                python3 << EOF
import json
with open("$CONFIG_PATH", 'r') as f:
    config = json.load(f)
config['mcpServers']['github']['env']['GITHUB_PERSONAL_ACCESS_TOKEN'] = "$github_token"
with open("$CONFIG_PATH", 'w') as f:
    json.dump(config, f, indent=2)
EOF
                echo -e "${GREEN}✓${NC} GitHub token added!"
            else
                echo -e "${RED}✗${NC} Invalid token format (should start with ghp_)"
            fi
            ;;
            
        2)
            echo ""
            echo -e "${YELLOW}Setting up Brave Search API Key...${NC}"
            echo ""
            echo "I'll open Brave's API page. You need to:"
            echo "1. Sign up or log in"
            echo "2. Go to 'API Keys'"
            echo "3. Create a new API key"
            echo "4. Copy the key"
            echo ""
            read -p "Press Enter to open Brave Search API... "
            open_url "Brave Search API" "https://brave.com/search/api/"
            
            echo ""
            read -p "Paste your Brave API key here: " brave_key
            
            if [[ -n $brave_key ]]; then
                python3 << EOF
import json
with open("$CONFIG_PATH", 'r') as f:
    config = json.load(f)
config['mcpServers']['brave-search']['env']['BRAVE_API_KEY'] = "$brave_key"
with open("$CONFIG_PATH", 'w') as f:
    json.dump(config, f, indent=2)
EOF
                echo -e "${GREEN}✓${NC} Brave Search key added!"
            else
                echo -e "${RED}✗${NC} No key entered"
            fi
            ;;
            
        3)
            echo ""
            echo -e "${YELLOW}Setting up Slack Bot Token...${NC}"
            echo ""
            echo "This is more complex. Steps:"
            echo "1. Create a new Slack app"
            echo "2. Add OAuth scopes"
            echo "3. Install to workspace"
            echo "4. Copy bot token and team ID"
            echo ""
            echo "Full guide: /Users/steven/Documents/MCP_TOKEN_SETUP.md"
            echo ""
            read -p "Press Enter to open Slack API page... "
            open_url "Slack API" "https://api.slack.com/apps"
            
            echo ""
            read -p "Paste your Slack bot token (xoxb-...): " slack_token
            read -p "Paste your Slack team ID (T...): " team_id
            
            if [[ $slack_token == xoxb-* ]] && [[ $team_id == T* ]]; then
                python3 << EOF
import json
with open("$CONFIG_PATH", 'r') as f:
    config = json.load(f)
config['mcpServers']['slack']['env']['SLACK_BOT_TOKEN'] = "$slack_token"
config['mcpServers']['slack']['env']['SLACK_TEAM_ID'] = "$team_id"
with open("$CONFIG_PATH", 'w') as f:
    json.dump(config, f, indent=2)
EOF
                echo -e "${GREEN}✓${NC} Slack credentials added!"
            else
                echo -e "${RED}✗${NC} Invalid token/team ID format"
            fi
            ;;
            
        4)
            echo ""
            echo -e "${YELLOW}Current Configuration:${NC}"
            echo ""
            python3 << 'EOF'
import json
with open("$CONFIG_PATH") as f:
    config = json.load(f)
    for name, server in config.get('mcpServers', {}).items():
        env = server.get('env', {})
        print(f"📦 {name}")
        if env:
            for key, value in env.items():
                status = "✅ Set" if value else "❌ Empty"
                print(f"   {status} {key}")
        else:
            print(f"   ✅ No token needed")
        print()
EOF
            ;;
            
        5)
            echo ""
            echo -e "${YELLOW}Opening config in editor...${NC}"
            open "$CONFIG_PATH"
            echo -e "${GREEN}✓${NC} Edit manually, then save"
            ;;
            
        6)
            echo ""
            echo -e "${GREEN}Configuration saved!${NC}"
            echo ""
            echo -e "${YELLOW}IMPORTANT: You must restart Claude Desktop!${NC}"
            echo ""
            echo "Steps:"
            echo "1. Press Cmd+Q to quit Claude completely"
            echo "2. Reopen Claude Desktop"
            echo "3. Look for 🔌 icon (bottom left)"
            echo "4. Check that servers are connected"
            echo ""
            read -p "Press Enter to quit this script... "
            exit 0
            ;;
            
        0)
            echo ""
            echo "Exiting. Remember to restart Claude if you made changes!"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
done
