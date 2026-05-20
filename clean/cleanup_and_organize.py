#!/usr/bin/env python3
"""
Comprehensive cleanup and organization script for ~/clean directory
"""

import os
import shutil
from pathlib import Path
from datetime import datetime

def cleanup_clean_directory():
    """Clean up duplicate and backup files in ~/clean directory"""
    clean_dir = Path.home() / "clean"

    print("🧹 Cleaning up ~/clean directory...")
    print("=" * 50)

    # Files to remove (backups and duplicates)
    to_remove = [
        "audio.py-bak",
        "docs.py-bak",
        "sorts.py-bak",
        "cleanup.py",  # Keep cleanup2.py as it's better
    ]

    # Rename cleanup2.py to cleanup.py (better version)
    cleanup2_path = clean_dir / "cleanup2.py"
    cleanup_path = clean_dir / "cleanup.py"

    if cleanup2_path.exists() and not cleanup_path.exists():
        print("📝 Renaming cleanup2.py to cleanup.py (better version)")
        shutil.move(cleanup2_path, cleanup_path)

    # Remove old files
    for filename in to_remove:
        file_path = clean_dir / filename
        if file_path.exists():
            print(f"🗑️  Removing {filename}")
            file_path.unlink()

    print("✅ Clean directory cleanup complete!")

def cleanup_zshrc_backups():
    """Clean up .zshrc backup files, keeping only the 2 most recent"""
    home = Path.home()
    zshrc_backups = list(home.glob(".zshrc.backup*")) + list(home.glob(".zshrc.bak*"))

    print(f"\n🧹 Cleaning up .zshrc backups ({len(zshrc_backups)} found)...")

    if len(zshrc_backups) <= 2:
        print("✅ Only 2 or fewer backups found, keeping all")
        return

    # Sort by modification time (newest first)
    zshrc_backups.sort(key=lambda x: x.stat().st_mtime, reverse=True)

    # Keep only the 2 most recent
    to_keep = zshrc_backups[:2]
    to_remove = zshrc_backups[2:]

    print(f"📁 Keeping: {[f.name for f in to_keep]}")

    for backup in to_remove:
        print(f"🗑️  Removing {backup.name}")
        backup.unlink()

    print("✅ Zshrc backup cleanup complete!")

def create_consolidated_scripts():
    """Create a consolidated script runner"""
    clean_dir = Path.home() / "clean"

    runner_script = '''#!/bin/bash
# Consolidated Clean Directory Runner
# Run all file organization scripts

echo "🚀 Running all clean scripts..."
echo "================================="

scripts=(
    "audio.py"
    "docs.py"
    "img.py"
    "vids.py"
    "other.py"
)

for script in "${scripts[@]}"; do
    script_path="$HOME/clean/$script"
    if [ -f "$script_path" ]; then
        echo ""
        echo "▶️  Running $script..."
        python3 "$script_path"
    else
        echo "⚠️  $script not found"
    fi
done

echo ""
echo "✅ All scripts completed!"
'''

    runner_path = clean_dir / "run_all.sh"
    with open(runner_path, 'w') as f:
        f.write(runner_script)

    # Make executable
    os.chmod(runner_path, 0o755)

    print("📝 Created consolidated runner script: run_all.sh")

def create_readme():
    """Create a README for the clean directory"""
    clean_dir = Path.home() / "clean"

    readme_content = '''# Clean Directory - File Organization Suite

This directory contains scripts for scanning, organizing, and cleaning up files on your system.

## Scripts Overview

### File Scanners
- `audio.py` - Scan for audio files (.mp3, .wav, .flac, .aac, .m4a)
- `docs.py` - Scan for document files (.pdf, .doc, .txt, .py, .html, etc.)
- `img.py` - Scan for image files (.jpg, .png, .gif, .tiff, etc.)
- `vids.py` - Scan for video files (.mp4, .mkv, .mov, .avi, etc.)
- `other.py` - Scan for other file types (fonts, scripts, archives, etc.)

### Utility Scripts
- `cleanup.py` - Remove duplicate files based on CSV reports
- `organize.py` - Copy files to organized directories based on CSV data
- `batch_csv_analyzer.py` - Analyze CSV conversation files
- `csv_analyzer.py` - Analyze individual CSV files
- `dbl.py` - Detect duplicate files using MD5 hashing

### Runner Scripts
- `sortD.sh` - Run all scanners sequentially
- `sorty.sh` - Run all scanners with user confirmation
- `run_all.sh` - Consolidated runner (auto-generated)

## Usage

### Quick Scan All File Types
```bash
cd ~/clean
./run_all.sh
```

### Individual Scans
```bash
python3 audio.py    # Scan for audio files
python3 docs.py     # Scan for documents
python3 img.py      # Scan for images
python3 vids.py     # Scan for videos
python3 other.py    # Scan for other files
```

### Clean Duplicates
```bash
python3 cleanup.py  # Remove duplicate files
```

## Output
All scripts generate timestamped CSV files in the current directory with file metadata and paths.

## Configuration
- Edit `config.py` for default paths and settings
- Scripts remember last scanned directories in `.txt` files
- Exclusion patterns prevent scanning of venv, cache, and system directories

## Maintenance
Run this cleanup script periodically:
```bash
python3 ~/cleanup_and_organize.py
```
'''

    readme_path = clean_dir / "README.md"
    with open(readme_path, 'w') as f:
        f.write(readme_content)

    print("📝 Created README.md for documentation")

def main():
    """Main cleanup and organization function"""
    print("🏠 Home Directory Organization Script")
    print("=" * 50)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    cleanup_clean_directory()
    cleanup_zshrc_backups()
    create_consolidated_scripts()
    create_readme()

    print()
    print("🎉 Organization complete!")
    print("📁 Check ~/clean/README.md for usage instructions")

if __name__ == "__main__":
    main()