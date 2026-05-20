#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


LOG_FILE="$HOME/grok_setup_diagnostic_$(date +%Y%m%d_%H%M%S).log"

echo "=== GROK CLI FULL SETUP DIAGNOSTIC (Steven's System) ===" | tee "$LOG_FILE"
echo "Run on: $(date)" | tee -a "$LOG_FILE"
echo "User: $USER @ $(hostname)" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 1. System Basics
echo "1. macOS & Shell" | tee -a "$LOG_FILE"
sw_vers | tee -a "$LOG_FILE"
echo "Shell: $SHELL (version: ${ZSH_VERSION:-unknown})" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 2. PATH Summary
echo "2. PATH (key directories only)" | tee -a "$LOG_FILE"
echo "$PATH" | tr ':' '\n' | grep -E '(local|bin|python|brew|uv)' | nl | tee -a "$LOG_FILE"
echo "Full PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l | tr -d ' ')" | tee -a "$LOG_FILE"
echo "Includes ~/.local/bin: $( [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] && echo "YES" || echo "NO" )" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 3. Package Managers
echo "3. Package Managers" | tee -a "$LOG_FILE"
if command -v brew >/dev/null; then echo "✓ Homebrew: $(brew --version | head -1)"; else echo "✗ Homebrew missing"; fi | tee -a "$LOG_FILE"
if command -v uv >/dev/null; then echo "✓ uv: $(uv --version)"; else echo "✗ uv missing"; fi | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 4. Python Environment
echo "4. Python Details" | tee -a "$LOG_FILE"
echo "Default python3: $(which python3 2>/dev/null || echo 'not found') → $(python3 --version 2>&1 || echo 'broken')" | tee -a "$LOG_FILE"
for ver in 3.11 3.12 3.14; do
    if command -v python$ver >/dev/null 2>&1; then
        echo "python$ver: $(which python$ver) → $(python$ver --version 2>&1)" | tee -a "$LOG_FILE"
    fi
done
echo "pip3: $(which pip3 2>/dev/null || echo 'not found') → $(pip3 --version 2>&1 || echo 'broken')" | tee -a "$LOG_FILE"
if command -v uv >/dev/null; then
    echo "uv python list:" | tee -a "$LOG_FILE"
    uv python list 2>/dev/null | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"

# 5. openai Library
echo "5. openai Python Package" | tee -a "$LOG_FILE"
if python3 -c "import openai, sys; print('✓ openai', openai.__version__); sys.exit(0)" 2>/dev/null; then
    echo "   Import successful" | tee -a "$LOG_FILE"
    python3 - <<'PY' | tee -a "$LOG_FILE"
import pkg_resources, openai
try:
    dist = pkg_resources.get_distribution('openai')
    print(f"   Installed via: {dist.location}")
except:
    print("   Location: unknown (uv or non-standard install)")
PY
else
    echo "✗ openai not importable with python3" | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"

# 6. API Keys (your .env.d system)
echo "6. API Keys" | tee -a "$LOG_FILE"
if [[ -n "$GROK_API_KEY" ]]; then
    echo "✓ GROK_API_KEY: set (length: ${#GROK_API_KEY})" | tee -a "$LOG_FILE"
else
    echo "✗ GROK_API_KEY: not set" | tee -a "$LOG_FILE"
fi
[[ -n "$OPENAI_API_KEY" ]] && echo "OPENAI_API_KEY: set" | tee -a "$LOG_FILE"
[[ -n "$ANTHROPIC_API_KEY" ]] && echo "ANTHROPIC_API_KEY: set" | tee -a "$LOG_FILE"
echo ".env.d files: $(ls ~/.env.d/*.env 2>/dev/null | wc -l | tr -d ' ') found" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 7. Ollama (for --local fallback)
echo "7. Ollama Status" | tee -a "$LOG_FILE"
if command -v ollama >/dev/null; then
    echo "✓ ollama: $(ollama --version 2>&1 || echo 'installed but error')" | tee -a "$LOG_FILE"
    echo "Pulled models:" | tee -a "$LOG_FILE"
    ollama list 2>/dev/null | tee -a "$LOG_FILE"
else
    echo "✗ ollama not installed" | tee -a "$LOG_FILE"
fi
[[ -n "$OLLAMA_MODEL" ]] && echo "OLLAMA_MODEL env: $OLLAMA_MODEL" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# 8. Existing grok Command (if any)
echo "8. Existing grok CLI" | tee -a "$LOG_FILE"
if command -v grok >/dev/null 2>&1; then
    echo "Found at: $(which grok)" | tee -a "$LOG_FILE"
    echo "Type: $(file "$(which grok)" 2>/dev/null || echo 'unknown')" | tee -a "$LOG_FILE"
else
    echo "✗ No grok command in PATH" | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"

# 9. Quick Status Summary
echo "9. Quick Status Summary" | tee -a "$LOG_FILE"
if [[ -n "$GROK_API_KEY" ]] && python3 -c "import openai" &>/dev/null; then
    echo "• Ready for xAI API: YES" | tee -a "$LOG_FILE"
else
    echo "• Ready for xAI API: NO" | tee -a "$LOG_FILE"
fi
if command -v ollama >/dev/null; then
    echo "• Ready for Ollama local: YES" | tee -a "$LOG_FILE"
else
    echo "• Ready for Ollama local: NO" | tee -a "$LOG_FILE"
fi
echo "• ~/.local/bin in PATH: $( [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] && echo "YES" || echo "NO" )" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

echo "=== DIAGNOSTIC COMPLETE ===" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Please paste the contents of this file (or the terminal output) in your next message." | tee -a "$LOG_FILE"
