#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# AI Resource Management Initialization Script

echo "🚀 Initializing AI Resource Management System..."

# Create necessary directories
mkdir -p ~/.mcp-central/{configs,logs,cache}
mkdir -p /tmp/mcp-pids

# Set up resource limits
echo "Setting up resource limits..."
ulimit -n 4096  # Increase file descriptor limit

# Initialize configuration
if [ ! -f ~/.mcp-central/configs/resource-optimization.json ]; then
    echo "Creating default resource optimization configuration..."
    cat > ~/.mcp-central/configs/resource-optimization.json << 'EOF'
{
  "resourceManagement": {
    "limits": {
      "memoryPerServer": "512MB",
      "maxConcurrentRequests": 10,
      "requestTimeout": 30000,
      "idleTimeout": 300000
    },
    "caching": {
      "enabled": true,
      "maxCacheSize": "100MB",
      "ttl": 300,
      "evictionPolicy": "LRU"
    },
    "rateLimiting": {
      "enabled": true,
      "requestsPerMinute": 60,
      "burstLimit": 10
    },
    "healthChecks": {
      "enabled": true,
      "interval": 30000,
      "timeout": 5000,
      "maxFailures": 3
    }
  },
  "serverSpecific": {
    "notebooklm": {
      "memoryLimit": "1GB",
      "timeout": 60000,
      "maxConcurrent": 1
    },
    "filesystem": {
      "memoryLimit": "256MB",
      "timeout": 15000,
      "maxConcurrent": 5
    },
    "brave-search": {
      "memoryLimit": "128MB",
      "timeout": 10000,
      "maxConcurrent": 3
    },
    "github": {
      "memoryLimit": "256MB",
      "timeout": 20000,
      "maxConcurrent": 2
    }
  }
}
EOF
fi

echo "✅ AI Resource Management System initialized!"
echo ""
echo "Available commands:"
echo "  cursor-safe          - Launch Cursor with resource limits"
echo "  claude-safe          - Launch Claude with resource limits"
echo "  qwen-safe            - Launch Qwen with resource limits"
echo "  gemini-safe          - Launch Gemini with resource limits"
echo "  mcp-start [server]   - Start MCP server with resource limits"
echo "  mcp-stop [server]    - Stop MCP server"
echo "  mcp-status           - Check MCP server status"
echo "  ai-monitor           - Monitor AI tool resource usage"
echo "  ai-workflow [tool]   - Start optimized AI workflow"
echo "  ai-shutdown          - Gracefully shut down AI tools"
echo ""
echo "To reload your shell with these functions, run: source ~/.zshrc"
