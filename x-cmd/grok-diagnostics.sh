#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# grok-cli Diagnostics Script with Log Output
# Save this as grok-diagnostics.sh, then run: chmod +x grok-diagnostics.sh && ./grok-diagnostics.sh
# The script will display output in the terminal AND save it to a timestamped log file in your home directory.
# IMPORTANT: If any API key appears in the output, redact it (replace with REDACTED) before sharing.

LOGFILE="$HOME/grok-diagnostics-$(date +%Y-%m-%d_%H-%M-%S).log"

echo "=== grok-cli Diagnostics ==="
echo "Generated on: $(date)"
echo "User: $(whoami) @ $(hostname)"
echo "Log file: $LOGFILE"
echo

(
  echo "grok version:"
  grok --version 2>&1 || echo "grok command not found or failed"
  echo

  echo "grok location:"
  which grok || echo "grok not in PATH"
  echo

  echo "Runtime versions:"
  node --version 2>/dev/null || echo "Node.js not installed"
  bun --version 2>/dev/null || echo "Bun not installed"
  echo

  echo "Installed grok-cli package:"
  if command -v npm >/dev/null 2>&1; then
    npm list -g --depth=0 2>/dev/null | grep '@vibe-kit/grok-cli' || echo "Not found via npm"
  fi
  if command -v bun >/dev/null 2>&1; then
    bun pm ls -g 2>/dev/null | grep '@vibe-kit/grok-cli' || echo "Not found via bun"
  fi
  echo

  echo "Relevant environment variables (auto-redacted):"
  env | grep -i -E 'GROK_API_KEY|XAI_API_KEY' | sed 's/=.*$/=REDACTED/' || echo "No GROK_API_KEY or XAI_API_KEY found"
  echo

  echo "User config file (~/.grok/user-settings.json) - auto-redacted:"
  if [ -f ~/.grok/user-settings.json ]; then
    cat ~/.grok/user-settings.json | sed -E 's/("apiKey": ")[^"]*"/\1REDACTED"/g'
  else
    echo "No ~/.grok/user-settings.json file found"
  fi
  echo

  echo "System info:"
  sw_vers
  uname -a
  echo "Shell: $SHELL"
  echo

  echo "=== End of Diagnostics ==="
  echo
  echo "Diagnostics complete. Full output saved to: $LOGFILE"
  echo "You can view it with: cat \"$LOGFILE\" or open \"$LOGFILE\""
) | tee "$LOGFILE"

echo
echo "Done! Share the contents of $LOGFILE here (redact any sensitive info)."
