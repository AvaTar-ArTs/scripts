#!/usr/bin/env bash

# Logging functions for consistent output
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $*"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $*"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $*"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $*" >&2
}


# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# QuantumForgeLabs Mobile Development Server
# This script starts a local server accessible from your iPhone

echo "🚀 Starting QuantumForgeLabs Mobile Server..."
echo ""

# Get local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
PORT=3000

echo "📱 Access from iPhone: http://$LOCAL_IP:$PORT/"
echo "💻 Access from Mac: http://localhost:$PORT/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
node server.js
