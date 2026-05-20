#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Cron job script to update Qwen conversation history

# Change to home directory
cd $HOME

# Run the advanced Qwen conversation manager
/usr/bin/python3 /Users/steven/qwen_manager_advanced.py >> /Users/steven/qwen_manager.log 2>&1

# Optionally send notification (requires appropriate setup)
# echo "Qwen conversation history updated at $(date)" | mail -s "Qwen Update" your-email@example.com
