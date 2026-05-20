#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# mac_diag.sh — System Diagnostic for TechnoMancer Maintenance Script

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🪄  TechnoMancer Mac System Diagnostic  🪄"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# System basics
echo "User:        $USER"
echo "Hostname:    $(hostname)"
echo "OS:          $(sw_vers | grep ProductName | awk '{print $2, $3}')"
echo "Version:     $(sw_vers | grep ProductVersion | awk '{print $2}')"
echo "Kernel:      $(uname -a)"
echo "Shell:       $SHELL"
echo "Shell Type:  $(if [[ -n "${ZSH_VERSION:-}" ]]; then echo zsh; else echo bash; fi)"
echo "Arch:        $(uname -m)"
echo

# TouchID sudo status
if [[ "$(uname)" == "Darwin" ]]; then
    echo -n "TouchID for sudo: "
    if grep -q pam_tid.so /etc/pam.d/sudo 2>/dev/null; then
        echo "ENABLED"
    else
        echo "NOT enabled"
    fi
fi

echo
# Homebrew
echo -n "Homebrew: "
if command -v brew >/dev/null; then
    echo "yes ($(brew --version | head -1))"
else
    echo "no"
fi

# Pip3/Python3
echo -n "Python3:  "
if command -v python3 >/dev/null; then
    echo "yes ($(python3 --version 2>&1))"
else
    echo "no"
fi

echo -n "pip3:     "
if command -v pip3 >/dev/null; then
    echo "yes ($(pip3 --version 2>&1))"
else
    echo "no"
fi

# Node/NPM/Yarn
echo -n "Node.js:  "
if command -v node >/dev/null; then
    echo "yes ($(node --version 2>&1))"
else
    echo "no"
fi

echo -n "npm:      "
if command -v npm >/dev/null; then
    echo "yes ($(npm --version 2>&1))"
else
    echo "no"
fi

echo -n "yarn:     "
if command -v yarn >/dev/null; then
    echo "yes ($(yarn --version 2>&1))"
else
    echo "no"
fi

# Conda
echo -n "conda:    "
if command -v conda >/dev/null; then
    echo "yes ($(conda --version 2>&1))"
else
    echo "no"
fi

# Java
echo -n "Java:     "
if command -v java >/dev/null; then
    echo "yes ($(java -version 2>&1 | head -n 1))"
else
    echo "no"
fi

echo

# Disk space
echo "Available disk space on /:"
df -h /

echo

# Check existence of key app/cache directories
check_dir() {
    if [ -d "$1" ]; then
        echo "✔️  $1"
    else
        echo "✖️  $1"
    fi
}

echo "Common cache/log/backup directories:"
for d in \
    "$HOME/.Trash" \
    "/Library/Caches" \
    "/System/Library/Caches" \
    "$HOME/Library/Caches" \
    "$HOME/Library/Application Support/Adobe/Common/Media Cache Files" \
    "$HOME/Library/Application Support/Google/Chrome/Default/Application Cache" \
    "$HOME/Dropbox/.dropbox.cache" \
    "$HOME/Music/iTunes/iTunes Media/Mobile Applications" \
    "$HOME/Library/Application Support/MobileSync/Backup" \
    "$HOME/Library/Developer/Xcode/DerivedData" \
    "$HOME/Library/Developer/Xcode/Archives" \
    "$HOME/Library/Developer/Xcode/iOS Device Logs" \
    "$HOME/Library/Application Support/Steam" \
    "$HOME/Library/Application Support/minecraft" \
    "$HOME/.lunarclient" \
    "$HOME/.gradle/caches" \
    "$HOME/.android/cache" \
    "$HOME/.kite/logs" \
    "$HOME/.cacher/logs"
do
    check_dir "$d"
done

echo

# Active Python environment
echo -n "Active Python venv: "
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "$VIRTUAL_ENV"
else
    echo "none"
fi

# Extra: Show the last 5 shell config files, if any
echo
echo "Last 5 modified shell config files:"
ls -lt $HOME/.{bash*,zsh*,profile,aliases} 2>/dev/null | head -5

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Copy this output and share it for script refinement."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
