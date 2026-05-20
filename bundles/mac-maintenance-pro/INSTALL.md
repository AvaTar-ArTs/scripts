# Installation Guide — Mac Maintenance Pro Suite

**Version:** 1.0.0
**Last Updated:** 2026-04-12
**Platform:** macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Install (60 seconds)](#quick-install-60-seconds)
- [Manual Installation](#manual-installation)
- [Installer Script](#installer-script)
- [Post-Installation Verification](#post-installation-verification)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before installing, ensure your system meets these requirements:

### Required

| Requirement | How to Check | Minimum |
|-------------|--------------|---------|
| **macOS** | `sw_vers` | 12.0+ |
| **Bash** | `bash --version` | 5.0+ |
| **Homebrew** | `brew --version` | Any |
| **Disk Space** | `df -h /` | 50 MB free |

### Optional (for full features)

| Feature | Requirement |
|---------|-------------|
| AI Analysis | Internet connection + API key |
| Parallel Operations | Multi-core CPU |
| Cloud Sync | AWS/GCP credentials (optional) |

### Check Your System

```bash
# Run this one-liner to verify your setup
echo "macOS: $(sw_vers -productVersion)" && \
echo "Bash: $(bash --version | head -1)" && \
echo "Homebrew: $(brew --version | head -1)" && \
echo "Free Space: $(df -h / | awk 'NR==2 {print $4}')"
```

---

## Quick Install (60 seconds)

The fastest way to get up and running:

```bash
# 1. Download the bundle
curl -LO https://github.com/avatararts/mac-maintenance-pro/releases/download/v1.0.0/mac-maintenance-pro-v1.0.0.zip

# 2. Extract
unzip mac-maintenance-pro-v1.0.0.zip
cd mac-maintenance-pro-v1.0.0

# 3. Make scripts executable
chmod +x scripts/*.sh

# 4. Verify installation
scripts/mac-cleanup-pro.sh --help
```

**Expected output:**
```
Usage: mac-cleanup-pro.sh [OPTIONS]

Post-update cleanup: Homebrew, Yarn, npm, pip, Bun caches + Python .pyc.

Options:
  -h, --help     Show this help
  -v, --verbose  Show commands and extra detail
  --dry-run      Show what would be done without deleting anything
```

---

## Manual Installation

For users who want full control over the installation process.

### Step 1: Create Installation Directory

```bash
# Choose your preferred location
INSTALL_DIR="$HOME/bin/mac-maintenance-pro"
mkdir -p "$INSTALL_DIR"
```

### Step 2: Copy Scripts

```bash
# Copy all scripts to the installation directory
cp scripts/*.sh "$INSTALL_DIR/"

# Set correct permissions
chmod +x "$INSTALL_DIR"/*.sh
```

### Step 3: Add to PATH

Add the installation directory to your shell's PATH:

**For zsh (default on macOS):**
```bash
echo 'export PATH="$HOME/bin/mac-maintenance-pro:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo 'export PATH="$HOME/bin/mac-maintenance-pro:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 4: Verify Installation

```bash
# Check that all scripts are accessible
which mac-cleanup-pro.sh
which advanced-system-maintenance-v5.sh
which enhanced_cleanup.sh
which enhanced_disk_cleanup.sh
which cleanup_python_conservative.sh
which cleanup_duplicates.sh
which package_manager_cleanup.sh
```

Each command should return the full path to the script.

### Step 5: First Run (Dry-Run Mode)

```bash
# Safe first run — preview only
mac-cleanup-pro.sh --dry-run

# If satisfied, run for real
mac-cleanup-pro.sh
```

---

## Installer Script

The bundle includes an automated installer for convenience.

### Run the Installer

```bash
bash install.sh
```

### What the Installer Does

1. ✅ Checks system prerequisites
2. ✅ Creates installation directory
3. ✅ Copies and chmod +x scripts
4. ✅ Updates PATH in ~/.zshrc or ~/.bashrc
5. ✅ Creates default configuration file
6. ✅ Runs verification tests
7. ✅ Displays summary report

### Installer Output Example

```
====================================
Mac Maintenance Pro — Installer v1.0
====================================

✅ macOS 14.3 — OK
✅ Bash 5.2.26 — OK
✅ Homebrew 4.2.0 — OK
✅ 45 GB free space — OK

Installing to: /Users/steven/bin/mac-maintenance-pro
[1/7] mac-cleanup-pro.sh ............ ✅
[2/7] advanced-system-maintenance ... ✅
[3/7] enhanced_cleanup.sh ........... ✅
[4/7] enhanced_disk_cleanup.sh ...... ✅
[5/7] cleanup_python_conservative ... ✅
[6/7] cleanup_duplicates.sh ......... ✅
[7/7] package_manager_cleanup.sh .... ✅

Updated ~/.zshrc with PATH entry
Created config: ~/.config/advanced-maintenance.conf

====================================
✅ Installation Complete!
====================================

Run 'mac-cleanup-pro.sh --dry-run' to get started.
```

### Installer Options

```bash
# Custom install location
bash install.sh --prefix /opt/mac-maintenance-pro

# Silent mode (no prompts)
bash install.sh --silent

# Uninstall
bash install.sh --uninstall
```

---

## Post-Installation Verification

Run the built-in verification suite:

```bash
# Check all scripts are executable
ls -la ~/bin/mac-maintenance-pro/*.sh

# Verify bash syntax (no execution)
for script in ~/bin/mac-maintenance-pro/*.sh; do
    echo -n "Checking $(basename "$script")... "
    bash -n "$script" && echo "✅ OK" || echo "❌ FAIL"
done

# Run help flags
for script in mac-cleanup-pro.sh enhanced_cleanup.sh enhanced_disk_cleanup.sh; do
    echo "--- $script ---"
    $script --help | head -3
    echo ""
done
```

### Expected Results

All 7 scripts should:
- ✅ Be executable (`-rwxr-xr-x`)
- ✅ Pass `bash -n` syntax check
- ✅ Respond to `--help` flag

---

## Uninstallation

### Quick Uninstall

```bash
# Remove scripts
rm -rf ~/bin/mac-maintenance-pro

# Remove configuration
rm -f ~/.config/advanced-maintenance.conf

# Remove logs (optional)
rm -rf ~/logs/advanced-maintenance

# Remove PATH entry from ~/.zshrc or ~/.bashrc
# Edit manually and remove the line:
#   export PATH="$HOME/bin/mac-maintenance-pro:$PATH"
```

### Using the Installer

```bash
bash install.sh --uninstall
```

This will:
1. Remove all scripts
2. Remove PATH entry from shell config
3. Offer to remove logs and config
4. Display confirmation summary

---

## Troubleshooting

### "command not found" after installation

**Cause:** PATH not updated or shell not reloaded.

**Fix:**
```bash
# Reload shell config
source ~/.zshrc  # or source ~/.bashrc

# Verify PATH
echo $PATH | tr ':' '\n' | grep mac-maintenance
```

### "Permission denied" when running scripts

**Cause:** Scripts not marked as executable.

**Fix:**
```bash
chmod +x ~/bin/mac-maintenance-pro/*.sh
```

### "bash: bad interpreter" error

**Cause:** Wrong bash version or path.

**Fix:**
```bash
# Check bash location
which bash

# If not /bin/bash or /opt/homebrew/bin/bash, update scripts:
sed -i '' '1s|.*|#!/usr/bin/env bash|' ~/bin/mac-maintenance-pro/*.sh
```

### Homebrew cleanup fails

**Cause:** Homebrew not installed or corrupted.

**Fix:**
```bash
# Reinstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify
brew doctor
```

### AI analysis feature not working

**Cause:** Missing API key or no internet.

**Fix:**
```bash
# Set API key (example for OpenAI)
export OPENAI_API_KEY="sk-your-key-here"

# Or disable AI features
echo 'DEFAULT_AI_ANALYSIS_ENABLED=false' >> ~/.config/advanced-maintenance.conf
```

### Parallel operations cause high CPU

**Cause:** Too many concurrent jobs.

**Fix:**
```bash
# Reduce parallel jobs (default is 6)
echo 'DEFAULT_PARALLEL_JOBS=3' >> ~/.config/advanced-maintenance.conf
```

### Logs taking up too much space

**Cause:** Verbose logging enabled over time.

**Fix:**
```bash
# Check log size
du -sh ~/logs/advanced-maintenance/

# Clean old logs (older than 30 days)
find ~/logs/advanced-maintenance/ -name "*.log" -mtime +30 -delete
```

---

## Next Steps

After successful installation:

1. **Run your first cleanup:**
   ```bash
   mac-cleanup-pro.sh --dry-run
   ```

2. **Read the full documentation:**
   ```bash
   cat README.md
   ```

3. **Explore advanced features:**
   ```bash
   advanced-system-maintenance-v5.sh --interactive
   ```

4. **Set up weekly automation:**
   ```bash
   # Add to crontab (runs every Monday at 9 AM)
   crontab -e
   # Add: 0 9 * * 1 $HOME/bin/mac-maintenance-pro/mac-cleanup-pro.sh >> ~/logs/cleanup-weekly.log 2>&1
   ```

---

<div align="center">

**Need more help?**

📧 support@avatararts.dev | 📖 [README.md](README.md) | 🐛 [GitHub Issues](#)

</div>
