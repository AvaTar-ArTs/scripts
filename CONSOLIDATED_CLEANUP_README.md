# Consolidated Cleanup Script

This script combines the functionality of multiple cleanup scripts into a single, comprehensive tool for maintaining your macOS system.

## Features

- **No sudo required**: Safe operations only that don't require elevated permissions
- **Dry-run mode**: Preview operations without executing them
- **Modular design**: Select which cleanup modules to run
- **Interactive mode**: Confirmations for major operations (optional)
- **Comprehensive coverage**: System caches, app caches, package managers, Python environments, temp files, and duplicates
- **Detailed reporting**: Shows space freed and operations performed

## Usage

```bash
# Run all modules (default)
./consolidated_cleanup.sh

# Preview operations without executing them
./consolidated_cleanup.sh --dry-run

# Run specific modules only
./consolidated_cleanup.sh --modules system,apps

# Skip confirmations (for automation)
./consolidated_cleanup.sh --force

# Run without interactive prompts
./consolidated_cleanup.sh --non-interactive

# Show help
./consolidated_cleanup.sh --help
```

## Available Modules

- `system`: System caches and metadata
- `apps`: Application caches (Chrome, VS Code, Cursor, Adobe, etc.)
- `package-managers`: npm, yarn, conda, pip, rust, bun caches
- `python`: Python environments and caches
- `temp`: Temporary files
- `duplicates`: Duplicate files and logs

## What Gets Cleaned

### System Caches
- `~/Library/Caches/*`
- `/var/tmp/*` and `/tmp/*`
- `~/Library/Biome/*`
- `~/Library/Metadata/*`

### Application Caches
- Chrome cache and application cache
- Gradle caches
- Adobe media cache
- Container caches
- VS Code cached data
- Cursor editor cached data

### Package Manager Caches
- Homebrew cache and cleanup
- npm cache
- Yarn cache
- Conda cache
- Rust cargo registry cache
- Bun package manager cache

### Python Cleanup
- `__pycache__` directories
- `.pyc` files
- pip cache
- Old Python environments (with confirmation)

### Temporary and Duplicate Files
- `.tmp` and `.temp` files
- Backup files ending with `~`
- `backup.zip` and `Archive.zip` files
- Large log files

## Safety Notes

- This script only performs safe operations that don't require sudo
- All operations target cache and temporary files that can be safely removed
- Old Python environments are only removed after confirmation
- The script preserves your important data and code files

## Recommended Usage

Run this script monthly for routine maintenance, or as needed when you want to free up disk space. Use the `--dry-run` flag first to see what would be cleaned.