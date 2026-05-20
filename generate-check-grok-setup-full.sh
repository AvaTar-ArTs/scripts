mkdir -p ~/scripts && cat > ~/scripts/check_grok_setup_full.sh <<'EOF'
set -euo pipefail
#!/bin/bash

echo "=== GROK CLI FULL SETUP DIAGNOSTIC (Steven's System) ==="
echo "Run on: $(date)"
echo "User: $USER @ $(hostname)"
echo

# 1. System Basics
echo "1. macOS & Shell"
sw_vers
echo "Shell: $SHELL (version: $ZSH_VERSION)"
echo

# 2. PATH Summary
echo "2. PATH (key directories only)"
echo "$PATH" | tr ':' '\n' | grep -E '(local|bin|python|brew|uv)' | nl
echo "Full PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
echo "Includes ~/.local/bin: $( [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] && echo "YES" || echo "NO" )"
echo

# 3. Package Managers
echo "3. Package Managers"
if command -v brew >/dev/null; then echo "✓ Homebrew: $(brew --version | head -1)"; else echo "✗ Homebrew missing"; fi
if command -v uv >/dev/null; then echo "✓ uv: $(uv --version)"; else echo "✗ uv missing"; fi
echo

# 4. Python Environment
echo "4. Python Details"
echo "Default python3: $(which python3) → $(python3 --version 2>&1 || echo 'broken')"
for ver in 3.11 3.12 3.14; do
    if command -v python$ver >/dev/null 2>&1; then
        echo "python$ver: $(which python$ver) → $(python$ver --version)"
    fi
done
echo "pip3: $(which pip3 2>&1 || echo 'not found') → $(pip3 --version 2>&1 || echo 'broken')"
if command -v uv >/dev/null; then
    echo "uv python list:"
    uv python list 2>/dev/null || echo "  (none or error)"
fi
echo

# 5. openai Library
echo "5. openai Python Package"
if python3 -c "import openai; print('✓ openai', openai.__version__)" 2>/dev/null; then
    python3 -c "import openai, pkg_resources; print('   Installed via:', pkg_resources.get_distribution('openai').location)" 2>/dev/null
else
    echo "✗ openai not importable"
fi
echo

# 6. API Keys (your .env.d system)
echo "6. API Keys"
if [[ -n "$GROK_API_KEY" ]]; then
    echo "✓ GROK_API_KEY: set (length: ${#GROK_API_KEY})"
else
    echo "✗ GROK_API_KEY: not set"
fi
if [[ -n "$OPENAI_API_KEY" ]]; then echo "OPENAI_API_KEY: set"; fi
if [[ -n "$ANTHROPIC_API_KEY" ]]; then echo "ANTHROPIC_API_KEY: set"; fi
echo ".env.d files: $(ls ~/.env.d/*.env 2>/dev/null | wc -l | tr -d ' ') found"
echo

# 7. Ollama (for --local fallback)
echo "7. Ollama Status"
if command -v ollama >/dev/null; then
    echo "✓ ollama: $(ollama --version 2>&1 || echo 'installed but error')"
    echo "Running models:"
    ollama list 2>/dev/null || echo "  (none or not running)"
else
    echo "✗ ollama not installed"
fi
if [[ -n "$OLLAMA_MODEL" ]]; then echo "OLLAMA_MODEL env: $OLLAMA_MODEL"; fi
echo

# 8. Existing grok Command (if any)
echo "8. Existing grok CLI"
if command -v grok >/dev/null 2>&1; then
    echo "Found at: $(which grok)"
    echo "Type: $(file $(which grok) 2>/dev/null || echo 'unknown')"
else
    echo "✗ No grok command in PATH"
fi
echo

# 9. Quick Recommendations Preview
echo "9. Quick Status Summary"
echo "• Ready for xAI API: $(( [[ -n "$GROK_API_KEY" ]] && python3 -c "import openai" &>/dev/null )) && echo "YES" || echo "NO")"
echo "• Ready for Ollama: $(( command -v ollama >/dev/null )) && echo "YES" || echo "NO")"
echo "• ~/.local/bin in PATH: $( [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] && echo "YES" || echo "ALREADY GOOD")"
echo

echo "=== END OF DIAGNOSTIC ==="
echo "Copy-paste the full output back to me – I'll use it to finalize the perfect grok script for your setup (vision, Ollama, concise, integrated with ai()/grok-ai())."
EOF

chmod +x ~/scripts/check_grok_setup_full.sh
