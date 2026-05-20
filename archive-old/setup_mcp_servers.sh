#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Setup script for MCP servers
# Integrates with existing ~/.env.d/ system

echo "🤖 Setting up MCP Servers..."
echo ""

# Check if MCP config directory exists
if [ ! -d "$HOME/.config/mcp" ]; then
  mkdir -p "$HOME/.config/mcp"
  echo "✅ Created ~/.config/mcp directory"
fi

# Check for required API keys in env.d
echo "🔍 Checking for API keys in ~/.env.d/..."

# Try multiple methods to load keys (your existing system)
if [ -f "$HOME/.env.d/loader.sh" ]; then
  source "$HOME/.env.d/loader.sh" llm-apis github >/dev/null 2>&1
  echo "✅ Loaded via ~/.env.d/loader.sh (llm-apis, github)"
elif [ -f "$HOME/.env.d/apis.env" ]; then
  source "$HOME/.env.d/apis.env" 2>/dev/null
  echo "✅ Loaded ~/.env.d/apis.env"
elif [ -f "$HOME/.env.d/llm-apis.env" ]; then
  source "$HOME/.env.d/llm-apis.env" 2>/dev/null
  if [ -f "$HOME/.env.d/github.env" ]; then
    source "$HOME/.env.d/github.env" 2>/dev/null
  fi
  echo "✅ Loaded ~/.env.d/llm-apis.env and github.env"
else
  echo "⚠️  No env.d loader or API files found"
fi

# Check each key
missing_keys=()

if [ -z "$CONTEXT7_API_KEY" ]; then
  missing_keys+=("CONTEXT7_API_KEY")
fi

if [ -z "$BRAVE_API_KEY" ]; then
  missing_keys+=("BRAVE_API_KEY")
fi

if [ -z "$NOTION_API_KEY" ]; then
  missing_keys+=("NOTION_API_KEY")
fi

if [ -z "$GITHUB_TOKEN" ]; then
  # Try to get from gh CLI
  if command -v gh &>/dev/null; then
    export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
    if [ -z "$GITHUB_TOKEN" ]; then
      missing_keys+=("GITHUB_TOKEN (run: gh auth login)")
    fi
  else
    missing_keys+=("GITHUB_TOKEN")
  fi
fi

# Report missing keys
if [ ${#missing_keys[@]} -gt 0 ]; then
  echo "⚠️  Missing API keys:"
  for key in "${missing_keys[@]}"; do
    echo "   - $key"
  done
  echo ""
  echo "💡 Add them to ~/.env.d/llm-apis.env or use your env.d loader system"
  echo "   Then run: env-rebuild"
else
  echo "✅ All required API keys found"
fi

echo ""
echo "📋 MCP Configuration:"
echo "   Config: ~/.config/mcp/servers.json"
echo "   Allowlist: ~/.config/mcp/allowlist.json"
echo ""
echo "✅ Setup complete!"
echo ""
echo "📖 Next steps:"
echo "   1. Review ~/.config/mcp/README.md"
echo "   2. Add any missing API keys to ~/.env.d/"
echo "   3. Restart your MCP client (Cursor/Warp)"
