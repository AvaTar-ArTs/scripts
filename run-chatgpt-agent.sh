#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ChatGPT Agent Launcher
# This script loads your environment and runs the ChatGPT agent

echo "🚀 Starting ChatGPT Agent..."
echo "Loading environment from ~/.env.d/llm-apis.env"

# Load your environment
source ~/.env.d/loader.sh llm-apis

# Activate virtual environment and run the agent
source chatgpt_agent_env/bin/activate
python3 chatgpt_agent.py
