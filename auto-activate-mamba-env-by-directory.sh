#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Auto-activate conda environments based on directory
# Add this to your ~/.zshrc or ~/.bashrc:
#   source ~/ai-sites/environments/auto_activate.sh

auto_activate_env() {
    local dir="$PWD"

    # AI Sites - automation master
    if [[ "$dir" == "/Users/steven/ai-sites"* ]]; then
        if [[ "$CONDA_DEFAULT_ENV" != "automation-master" ]]; then
            if mamba env list | grep -q "^automation-master "; then
                echo "🐍 Auto-activating: automation-master"
                mamba activate automation-master 2>/dev/null || true
            fi
        fi

    # pythons - data analysis
    elif [[ "$dir" == "~/pythons"* ]]; then
        if [[ "$CONDA_DEFAULT_ENV" != "data-analysis" ]]; then
            if mamba env list | grep -q "^data-analysis "; then
                echo "📊 Auto-activating: data-analysis"
                mamba activate data-analysis 2>/dev/null || true
            fi
        fi

    # Voice agents specific
    elif [[ "$dir" == *"ai-voice-agents"* ]]; then
        if [[ "$CONDA_DEFAULT_ENV" != "ai-voice-agents" ]]; then
            if mamba env list | grep -q "^ai-voice-agents "; then
                echo "🎙️ Auto-activating: ai-voice-agents"
                mamba activate ai-voice-agents 2>/dev/null || true
            fi
        fi

    # Downloads - automation master (for testing)
    elif [[ "$dir" == "/Users/steven/Downloads"* ]]; then
        if [[ "$CONDA_DEFAULT_ENV" != "automation-master" ]]; then
            if mamba env list | grep -q "^automation-master "; then
                echo "🐍 Auto-activating: automation-master"
                mamba activate automation-master 2>/dev/null || true
            fi
        fi
    fi
}

# For zsh
if [[ -n "$ZSH_VERSION" ]]; then
    # Initialize mamba for zsh if not already done
    if ! typeset -f mamba > /dev/null; then
        eval "$(mamba shell hook -s zsh 2>/dev/null)" || true
    fi

    # Add to chpwd hooks (runs on directory change)
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd auto_activate_env

# For bash
elif [[ -n "$BASH_VERSION" ]]; then
    # Initialize mamba for bash if not already done
    if ! type mamba > /dev/null 2>&1; then
        eval "$(mamba shell hook -s bash 2>/dev/null)" || true
    fi

    # Add to PROMPT_COMMAND (runs before each prompt)
    if [[ ! "$PROMPT_COMMAND" =~ "auto_activate_env" ]]; then
        PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }auto_activate_env"
    fi
fi

# Run once on sourcing
auto_activate_env
