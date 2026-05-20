#!/bin/bash
set -euo pipefail
# MCP Diagnostic Script for AvatarArts
# Run this to verify your MCP setup

echo "======================================"
echo "MCP SERVER DIAGNOSTIC TOOL"
echo "Generated: November 6, 2025"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Node.js
echo "1. Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found! Install with: brew install node"
fi

# Check npx
echo ""
echo "2. Checking npx..."
if command -v npx &> /dev/null; then
    NPX_PATH=$(which npx)
    echo -e "${GREEN}✓${NC} npx available at: $NPX_PATH"
else
    echo -e "${RED}✗${NC} npx not found!"
fi

# Check Claude config
echo ""
echo "3. Checking Claude Desktop config..."
CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CONFIG_PATH" ]; then
    echo -e "${GREEN}✓${NC} Config file exists"
    
    # Validate JSON
    if python3 -m json.tool "$CONFIG_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} JSON is valid"
        
        # Count MCP servers
        SERVER_COUNT=$(python3 -c "import json; f=open('$CONFIG_PATH'); d=json.load(f); print(len(d.get('mcpServers', {})))")
        echo -e "${GREEN}✓${NC} $SERVER_COUNT MCP servers configured"
    else
        echo -e "${RED}✗${NC} Invalid JSON in config file!"
    fi
else
    echo -e "${RED}✗${NC} Config file not found at: $CONFIG_PATH"
fi

# Check Chrome remote debugging
echo ""
echo "4. Checking Chrome remote debugging..."
if lsof -i :9222 &> /dev/null; then
    echo -e "${GREEN}✓${NC} Chrome is running with remote debugging on port 9222"
else
    echo -e "${YELLOW}!${NC} Chrome not running with remote debugging"
    echo "   To enable: /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222"
fi

# List configured servers
echo ""
echo "5. Configured MCP Servers:"
if [ -f "$CONFIG_PATH" ]; then
    python3 << 'EOF'
import json
import os

config_path = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
with open(config_path) as f:
    config = json.load(f)
    servers = config.get('mcpServers', {})
    
    for name, details in servers.items():
        print(f"   • {name}")
        print(f"     Command: {details.get('command', 'N/A')}")
        if 'args' in details:
            print(f"     Package: {details['args'][-1] if details['args'] else 'N/A'}")
        print()
EOF
fi

# Check filesystem permissions
echo ""
echo "6. Checking filesystem permissions..."
PATHS=(
    "$HOME/GitHub"
    "$HOME/workspace"
    "$HOME/Documents"
)

for PATH_TO_CHECK in "${PATHS[@]}"; do
    if [ -d "$PATH_TO_CHECK" ]; then
        if [ -r "$PATH_TO_CHECK" ] && [ -w "$PATH_TO_CHECK" ]; then
            echo -e "${GREEN}✓${NC} $PATH_TO_CHECK (read/write)"
        else
            echo -e "${YELLOW}!${NC} $PATH_TO_CHECK (permission issues)"
        fi
    else
        echo -e "${RED}✗${NC} $PATH_TO_CHECK (doesn't exist)"
    fi
done

# Test MCP packages
echo ""
echo "7. Testing MCP package availability..."
PACKAGES=(
    "@wonderwhy-er/desktop-commander"
    "@modelcontextprotocol/server-memory"
    "@modelcontextprotocol/server-filesystem"
    "@kazuph/mcp-fetch"
    "chrome-devtools-mcp"
)

for PACKAGE in "${PACKAGES[@]}"; do
    echo -n "   Testing $PACKAGE... "
    if npx -y "$PACKAGE" --help &> /dev/null 2>&1 || npx -y "$PACKAGE" --version &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}! (may need first-time download)${NC}"
    fi
done

# Summary
echo ""
echo "======================================"
echo "SUMMARY"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. If any checks failed (✗), address those issues"
echo "2. Restart Claude Desktop completely (Cmd+Q then reopen)"
echo "3. Look for the 🔌 icon in Claude to verify servers"
echo "4. Test servers by asking Claude to use them"
echo ""
echo "For detailed setup guide, see:"
echo "$HOME/Documents/MCP_SETUP_GUIDE.md"
echo ""
echo "======================================"
