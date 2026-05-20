#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Interactive Grok CLI wrapper

# Load environment
source ~/.env.d/loader.sh llm-apis 2>/dev/null

# Set API key
export GROK_API_KEY="$XAI_API_KEY"

echo "🤖 Grok CLI Interactive Mode"
echo "Type your questions and press Enter. Type 'exit' to quit."
echo ""

while true; do
    read -p "❯ " question
    if [ "$question" = "exit" ]; then
        echo "Goodbye! 👋"
        break
    fi
    if [ -n "$question" ]; then
        echo ""
        grok --print "$question"
        echo ""
    fi
done
