#!/usr/bin/env bash
set -euo pipefail

# v2: x-cmd-free Grok/XAI diagnostics.
# Safe output: API values are redacted.

LOGFILE="$HOME/grok-diagnostics-v2-$(date +%Y-%m-%d_%H-%M-%S).log"
ENV_FILE="${ENV_FILE:-$HOME/.env.d/llm-apis.env}"

mask_line() {
  sed -E 's/(XAI_API_KEY|GROK_API_KEY)=.*/\1=REDACTED/g; s/("apiKey"[[:space:]]*:[[:space:]]*")[^"]*(")/\1REDACTED\2/g'
}

{
  echo "=== Grok/XAI Diagnostics v2 ==="
  echo "Generated: $(date)"
  echo "User: $(whoami) @ $(hostname)"
  echo "Shell: $SHELL"
  echo

  echo "CLI locations:"
  command -v grok || echo "grok: not found"
  command -v node || echo "node: not found"
  command -v npm || echo "npm: not found"
  command -v bun || echo "bun: not found"
  echo

  echo "Versions:"
  grok --version 2>&1 || true
  node --version 2>&1 || true
  npm --version 2>&1 || true
  bun --version 2>&1 || true
  echo

  echo "Global package check:"
  npm list -g --depth=0 2>/dev/null | grep -Ei 'grok|xai|vibe-kit' || echo "No matching global npm package found"
  echo

  echo "Environment keys (redacted):"
  if [ -f "$ENV_FILE" ]; then
    echo "Using env file: $ENV_FILE"
    # shellcheck disable=SC1090
    source "$ENV_FILE"
  else
    echo "Env file not found: $ENV_FILE"
  fi

  if [ -n "${GROK_API_KEY:-}" ]; then echo "GROK_API_KEY=REDACTED"; else echo "GROK_API_KEY=missing"; fi
  if [ -n "${XAI_API_KEY:-}" ]; then echo "XAI_API_KEY=REDACTED"; else echo "XAI_API_KEY=missing"; fi
  echo

  echo "~/.grok config (redacted if present):"
  if [ -f "$HOME/.grok/user-settings.json" ]; then
    cat "$HOME/.grok/user-settings.json" | mask_line
  else
    echo "No ~/.grok/user-settings.json"
  fi
  echo

  echo "System info:"
  sw_vers 2>/dev/null || true
  uname -a
  echo
  echo "=== End Diagnostics ==="
} | tee "$LOGFILE"

echo
echo "Saved: $LOGFILE"
