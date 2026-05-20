#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Syncs keys from .env.d to x-cmd configuration

source ~/.env.d/llm-apis.env

echo "🚀 Syncing API Keys to x-cmd..."

# OpenAI
if [ -n "$OPENAI_API_KEY" ]; then
    echo "✅ Configuring OpenAI..."
    x openai --cfg apikey="$OPENAI_API_KEY"
fi

# Anthropic (Claude)
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "✅ Configuring Claude..."
    x claude --cfg apikey="$ANTHROPIC_API_KEY"
fi

# Gemini
if [ -n "$GEMINI_API_KEY" ]; then
    echo "✅ Configuring Gemini..."
    x gemini --cfg apikey="$GEMINI_API_KEY"
fi

# Grok
if [ -n "$GROK_API_KEY" ]; then
    echo "✅ Configuring Grok..."
    x grok --cfg apikey="$GROK_API_KEY"
fi

# Mistral
if [ -n "$MISTRAL_API_KEY" ]; then
    echo "✅ Configuring Mistral..."
    x mistral --cfg apikey="$MISTRAL_API_KEY"
fi

# DeepSeek
if [ -n "$DEEPSEEK_API_KEY" ]; then
    echo "✅ Configuring DeepSeek..."
    x deepseek --cfg apikey="$DEEPSEEK_API_KEY"
fi

# Groq (Requires installing/using if supported)
# x-cmd might support groq via openrouter or specific module
if [ -n "$GROQ_API_KEY" ]; then
    echo "✅ Configuring Groq..."
    # Assuming module name is 'groq' or trying standard init
    x groq --cfg apikey="$GROQ_API_KEY" 2>/dev/null || echo "⚠️  x-cmd groq module not found or standard config failed"
fi

# Perplexity
if [ -n "$PERPLEXITY_API_KEY" ]; then
    echo "✅ Configuring Perplexity..."
    # x-cmd usually calls this 'pplx' or 'perplexity'
    x perplexity --cfg apikey="$PERPLEXITY_API_KEY" 2>/dev/null || echo "⚠️  x-cmd perplexity module not found"
fi

echo "🎉 Sync Complete! Try running '@gpt Hi', '@claude Hi', etc."
