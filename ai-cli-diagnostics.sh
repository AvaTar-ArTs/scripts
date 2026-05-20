#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Ultimate AI CLI Environment Layout & Troubleshooting Script
# Save this as ultimate-ai-diagnostics.sh
# Run: chmod +x ultimate-ai-diagnostics.sh && ./ultimate-ai-diagnostics.sh
# BEST PRACTICE: Activate your Aider venv FIRST if you use one:
#   source ~/aider-env/bin/activate
# This captures your ENTIRE current layout: paths, versions, configs, env, packages, files, and more.
# Outputs to terminal + timestamped log in ~/
# ALL sensitive data (keys, tokens) AUTO-REDACTED for safe sharing

LOGFILE="$HOME/ultimate-ai-diagnostics-$(date +%Y-%m-%d_%H-%M-%S).log"

echo "=== Ultimate AI CLI Environment Layout & Diagnostics ==="
echo "Generated on: $(date)"
echo "User: $(whoami) @ $(hostname)"
echo "Current directory: $(pwd)"
echo "Log file: $LOGFILE"
echo
echo "IMPORTANT: Run this in your usual setup (Aider venv activated if applicable) for the most accurate snapshot!"
echo

(
  echo "=== Core System Layout ==="
  echo "Shell & PATH:"
  echo "Shell: $SHELL"
  echo "PATH contents:"
  echo "$PATH" | tr ':' '\n'
  echo

  echo "System info:"
  sw_vers 2>/dev/null || echo "macOS info unavailable"
  uname -a
  echo

  echo "=== Python Layout & Environment ==="
  echo "Python executable:"
  which python3 || which python || echo "No Python found"
  python3 --version 2>&1 || echo "Python version check failed"
  echo "Pip location & version:"
  which pip3 || which pip
  pip3 --version 2>&dev/null || echo "pip not available"
  echo "Active virtual environment:"
  echo "$VIRTUAL_ENV" || echo "None detected"
  echo

  echo "=== Full Python Package Layout (pip freeze) ==="
  echo "All installed packages in current environment:"
  pip freeze 2>/dev/null || echo "pip freeze failed (no pip?)"
  echo

  echo "=== Aider-Specific Deep Dive ==="
  echo "Aider command & version:"
  aider --version 2>&1 || echo "aider not found or failed"
  echo "Aider location:"
  which aider || echo "Not in PATH"
  echo "pip show aider-chat details:"
  pip show aider-chat 2>/dev/null || echo "aider-chat not installed here"
  echo "Aider config/transcript files in ~/:"
  ls -la ~/.aider* 2>/dev/null || echo "No Aider files found in home"
  echo

  echo "=== LiteLLM Deep Dive ==="
  echo "LiteLLM version & details:"
  pip show litellm 2>/dev/null || echo "litellm not installed"
  echo "LiteLLM proxy or config files:"
  ls -la ~/.litellm* 2>/dev/null || echo "No LiteLLM config found"
  echo

  echo "=== grok-cli / Node Layout (if relevant) ==="
  echo "Node & npm:"
  node --version 2>/dev/null || echo "Node not installed"
  npm --version 2>/dev/null || echo "npm not installed"
  echo "grok command:"
  grok --version 2>&1 || echo "grok not found"
  which grok || echo "grok not in PATH"
  echo "Global npm packages related:"
  npm list -g --depth=0 2>/dev/null | grep -i grok || echo "None found"
  echo

  echo "=== Key Config Directories & Files (redacted) ==="
  echo "~/.grok directory layout:"
  ls -la ~/.grok 2>/dev/null || echo "No ~/.grok directory"
  echo "user-settings.json (redacted):"
  if [ -f ~/.grok/user-settings.json ]; then
    cat ~/.grok/user-settings.json | sed -E 's/("apiKey": ")[^"]*"/\1REDACTED"/g ; s/([[:alnum:]]{30,})/REDACTED/g'
  else
    echo "Not found"
  fi
  echo

  echo "~/.continue directory (Continue.dev):"
  ls -la ~/.continue 2>/dev/null || echo "No ~/.continue directory"
  echo

  echo "=== Environment Variables (heavily redacted) ==="
  echo "All env vars containing 'API', 'KEY', 'TOKEN', 'LITELLM', 'XAI', 'OPENAI':"
  env | grep -i -E 'api|key|token|litellm|xai|openai|grok' | sed 's/=.*$/=REDACTED/' || echo "None found"
  echo

  echo "=== Network & API Reachability ==="
  echo "xAI API public endpoint test:"
  curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" https://api.x.ai/v1/models || echo "Failed"
  echo "General internet check:"
  ping -c 3 api.x.ai 2>/dev/null || echo "ping failed (may be blocked)"
  echo

  echo "=== End of Ultimate Diagnostics ==="
  echo
  echo "Full snapshot saved to: $LOGFILE"
  echo "This captures your entire current environment layout—perfect for deep troubleshooting."
) | tee "$LOGFILE"

echo
echo "Complete! Log file: $LOGFILE"
echo "Copy the entire contents of the log and paste it here (it's fully redacted and safe to share)."
echo "This will give me EVERYTHING needed to see your exact setup and fix any issues precisely."
