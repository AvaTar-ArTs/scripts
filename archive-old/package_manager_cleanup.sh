#!/usr/bin/env bash

# Package Manager Cleanup Script
# This script helps organize and clean up brew, node/npm, and pip installations
# Run with: bash package_manager_cleanup.sh

set -e

echo "======================================"
echo "Package Manager Cleanup & Organization"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
BACKUP_DIR="$HOME/.package_manager_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
print_status "Created backup directory: $BACKUP_DIR"

# 1. PYTHON CLEANUP
echo ""
echo "======================================"
echo "1. Python Environment Analysis"
echo "======================================"

print_status "Installed Python versions via Homebrew:"
brew list --formula | grep python

print_status "Current Python paths:"
which -a python python3 pip pip3

print_status "Backing up pip package list..."
pip3 list > "$BACKUP_DIR/pip_packages_backup.txt"
print_success "Saved to: $BACKUP_DIR/pip_packages_backup.txt"

# 2. HOMEBREW CLEANUP
echo ""
echo "======================================"
echo "2. Homebrew Cleanup"
echo "======================================"

print_status "Backing up Homebrew package list..."
brew list --formula > "$BACKUP_DIR/brew_formula_backup.txt"
brew list --cask > "$BACKUP_DIR/brew_cask_backup.txt"
print_success "Saved Homebrew packages to backup directory"

print_status "Running Homebrew cleanup..."
brew cleanup -s
print_success "Homebrew cleanup complete"

print_status "Removing old versions..."
brew autoremove
print_success "Old versions removed"

# 3. NODE/NPM CLEANUP
echo ""
echo "======================================"
echo "3. Node/NPM Cleanup"
echo "======================================"

print_status "Backing up global npm packages..."
npm list -g --depth=0 > "$BACKUP_DIR/npm_global_backup.txt" 2>&1
print_success "Saved to: $BACKUP_DIR/npm_global_backup.txt"

print_status "Cleaning npm cache..."
npm cache clean --force
print_success "NPM cache cleaned"

print_status "Updating outdated global packages..."
npm update -g
print_success "Global npm packages updated"

# 4. GENERATE RECOMMENDATIONS
echo ""
echo "======================================"
echo "4. Recommendations"
echo "======================================"

cat > "$BACKUP_DIR/RECOMMENDATIONS.md" << 'EOF'
# Package Manager Cleanup Recommendations

## Current Issues

### 1. Multiple Python Versions
You have Python 3.11, 3.12, and 3.13 installed via Homebrew. This can cause conflicts.

**Recommendation:**
- Choose ONE primary Python version (recommend 3.12 or 3.13)
- Uninstall the others:
  ```bash
  # Keep Python 3.12 or 3.13, remove others
  brew uninstall python@3.11
  # Or brew uninstall python@3.12 python@3.13 (if keeping 3.11)
  ```

### 2. Pip Package Location
Your pip packages are installed in ~/Library/Python/3.12/, which is the user site-packages.
This is actually correct for user-level packages!

**Best Practice:**
- Use `pip3 install --user <package>` for user-level packages
- Use virtual environments (venv) for project-specific packages
- Never use `sudo pip install` (avoid system-wide pollution)

### 3. PATH Order Optimization
Your PATH should prioritize:
1. Homebrew binaries (/usr/local/bin)
2. User binaries (~/.local/bin)
3. System binaries (/usr/bin)

**Current PATH looks good!** ✅

## Best Practices Going Forward

### For Python/Pip:
```bash
# Always use pip with python -m
python3 -m pip install <package>

# Or use the alias you already have
pip install <package>  # Your alias: python3 -m pip

# For projects, use virtual environments
python3 -m venv myproject_env
source myproject_env/bin/activate
pip install -r requirements.txt
```

### For Node/NPM:
```bash
# Global packages (tools you use across projects)
npm install -g <package>

# Project-local packages (always)
npm install <package>

# Consider using npx for one-off command executions
npx <package>
```

### For Homebrew:
```bash
# Regular updates
brew update && brew upgrade

# Regular cleanup
brew cleanup

# Check for issues
brew doctor

# Remove unused dependencies
brew autoremove
```

## Package Manager Decision Matrix

| Use Case | Tool | Example |
|----------|------|---------|
| System tools & utilities | Homebrew | `brew install git ffmpeg` |
| Python libraries for projects | pip + venv | `python3 -m venv env && pip install` |
| Global CLI tools (Python) | pipx | `pipx install black` |
| Node.js CLI tools (global) | npm -g | `npm install -g n8n` |
| Node.js project dependencies | npm | `npm install express` |
| One-off Node commands | npx | `npx create-react-app myapp` |

## Optional: Install pipx
pipx is great for installing Python CLI tools in isolated environments:
```bash
brew install pipx
pipx ensurepath

# Then install Python CLI tools with pipx instead of pip
pipx install black
pipx install flake8
pipx install youtube-dl
```

## Cleanup Commands

### Remove unused Python packages:
```bash
# List all installed packages
pip3 list

# Use pip-autoremove (install first)
pip3 install pip-autoremove
pip-autoremove <package-name> -y
```

### Find duplicate packages:
```bash
# Check for packages installed in multiple locations
pip3 list -v
```

### Clean npm cache periodically:
```bash
npm cache verify
```

## Your Current Setup (Summary)

✅ **Homebrew**: 4.6.20 - Healthy
✅ **Node**: v25.1.0 (via Homebrew)
✅ **NPM**: 11.6.2 (via Node)
✅ **Python**: 3.12.8 (via Homebrew)
✅ **Pip**: 25.3 (user site-packages)
⚠️ **Multiple Python versions**: 3.11, 3.12, 3.13
⚠️ **225+ pip packages**: Consider using venv for projects

EOF

print_success "Recommendations saved to: $BACKUP_DIR/RECOMMENDATIONS.md"

# 5. SUMMARY
echo ""
echo "======================================"
echo "5. Summary"
echo "======================================"

print_success "Cleanup complete!"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "Files created:"
echo "  - pip_packages_backup.txt"
echo "  - brew_formula_backup.txt"
echo "  - brew_cask_backup.txt"
echo "  - npm_global_backup.txt"
echo "  - RECOMMENDATIONS.md"
echo ""
print_warning "Next steps:"
echo "  1. Review $BACKUP_DIR/RECOMMENDATIONS.md"
echo "  2. Decide which Python version to keep"
echo "  3. Consider using virtual environments for Python projects"
echo "  4. Install pipx for Python CLI tools (optional)"
echo ""

# Generate a quick removal script for Python versions
cat > "$BACKUP_DIR/remove_extra_pythons.sh" << 'PYEOF'
#!/bin/bash
# Choose ONE of these commands based on which Python version you want to KEEP

# Option 1: Keep Python 3.13 (latest), remove 3.11 and 3.12
# brew uninstall python@3.11 python@3.12

# Option 2: Keep Python 3.12 (recommended), remove 3.11 and 3.13
# brew uninstall python@3.11 python@3.13

# Option 3: Keep Python 3.11, remove 3.12 and 3.13
# brew uninstall python@3.12 python@3.13

echo "Uncomment ONE of the above options and run this script"
PYEOF

chmod +x "$BACKUP_DIR/remove_extra_pythons.sh"

print_status "Created helper script: $BACKUP_DIR/remove_extra_pythons.sh"
echo ""
print_success "All done! 🎉"
