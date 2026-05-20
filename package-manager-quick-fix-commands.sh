#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Quick Fix Commands for Package Manager Cleanup
# Copy and paste these commands based on what you want to do

echo "======================================"
echo "QUICK FIX COMMANDS"
echo "======================================"
echo ""

cat << 'EOF'

🔴 HIGH PRIORITY FIXES
========================

1️⃣  Remove Extra Python Versions (Choose ONE option):

    # Option A: Keep Python 3.13 (latest) - RECOMMENDED
    brew uninstall python@3.11 python@3.12

    # Option B: Keep Python 3.12 (best compatibility)
    brew uninstall python@3.11 python@3.13

    # Option C: Keep Python 3.11 (if you have compatibility needs)
    brew uninstall python@3.12 python@3.13


2️⃣  Install pipx (better way to install Python CLI tools):

    brew install pipx
    pipx ensurepath
    source ~/.zshrc


3️⃣  Reinstall carbon-now-cli (npm package that was corrupted):

    npm install -g carbon-now-cli


🟡 RECOMMENDED IMPROVEMENTS
============================

4️⃣  Create a Python project template with virtual environment:

    mkdir -p ~/templates/python-project
    cd ~/templates/python-project
    python3 -m venv venv
    cat > activate.sh << 'HEREDOC'
#!/bin/bash
source venv/bin/activate
pip install --upgrade pip
echo "Virtual environment activated!"
HEREDOC
    chmod +x activate.sh
    echo "venv/" > .gitignore
    echo "# Python Project Template" > README.md


5️⃣  Migrate Python CLI tools from pip to pipx:

    # Example: If you have these installed via pip, move to pipx
    pipx install black
    pipx install flake8
    pipx install youtube-dl
    pipx install httpie
    
    # Then optionally remove from pip (after confirming they work)
    # pip uninstall black flake8 youtube-dl httpie


6️⃣  Audit your pip packages:

    # List all installed packages
    pip list > ~/pip_audit_$(date +%Y%m%d).txt
    
    # Open and review
    cat ~/pip_audit_$(date +%Y%m%d).txt
    
    # Count how many you have
    pip list | wc -l


🟢 REGULAR MAINTENANCE
=======================

7️⃣  Weekly/Monthly update routine:

    # Update everything
    brew update && brew upgrade && brew cleanup && brew autoremove
    npm update -g
    pipx upgrade-all
    
    # Check for issues
    brew doctor


8️⃣  Check what's taking up space:

    # Homebrew cache
    du -sh $(brew --cache)
    
    # NPM cache
    du -sh ~/.npm
    
    # Pip cache
    du -sh ~/Library/Caches/pip


📋 VERIFICATION COMMANDS
=========================

9️⃣  Verify your setup after cleanup:

    # Check Python version
    python3 --version
    which python3
    
    # Check pip location
    pip3 --version
    which pip3
    
    # Check node/npm
    node --version
    npm --version
    
    # List what's installed
    brew list --formula | wc -l
    brew list --cask | wc -l
    npm list -g --depth=0
    pip list | wc -l


🔍 TROUBLESHOOTING
===================

🔟  If something breaks:

    # Check PATH
    echo $PATH | tr ':' '\n'
    
    # Find all versions of a command
    which -a python python3 pip pip3
    
    # Restore from backup
    cat ~/.package_manager_backup_20251106_070741/pip_packages_backup.txt
    cat ~/.package_manager_backup_20251106_070741/brew_formula_backup.txt


📚 DOCUMENTATION
=================

Full guides available:
  - ~/CLEANUP_SUMMARY.md              (What was done + next steps)
  - ~/PACKAGE_MANAGER_GUIDE.md        (Complete reference)
  - ~/.package_manager_backup_*/      (All your backups)


🎯 RECOMMENDED ORDER
=====================

If you're going to do everything, do it in this order:

1. Remove extra Python versions (pick one and run command #1)
2. Install pipx (command #2)
3. Reinstall carbon-now-cli (command #3)
4. Create project template (command #4)
5. Set up regular maintenance routine (command #7)


⚡ ONE-LINE QUICK START
========================

Copy and paste this if you want to do everything automatically:

# This will: remove Python 3.11, install pipx, reinstall carbon-now-cli
brew uninstall python@3.11 && brew install pipx && pipx ensurepath && npm install -g carbon-now-cli && source ~/.zshrc

EOF
