# Consolidated Update Script

This script provides a comprehensive update solution for all major components of your system, designed to work in conjunction with the consolidated cleanup script.

## Features

- **Comprehensive coverage**: Updates macOS, Homebrew, package managers, Python environments, and applications
- **Safety checks**: Verifies disk space and internet connectivity before proceeding
- **Dry-run mode**: Preview updates without applying them
- **Interactive mode**: Confirmations for major operations (optional)
- **Integration**: Option to run cleanup after updates
- **Detailed reporting**: Shows what is being updated and the results

## Usage

```bash
# Run all updates (default)
./consolidated_update.sh

# Preview updates without applying them
./consolidated_update.sh --dry-run

# Skip confirmations (for automation)
./consolidated_update.sh --force

# Run cleanup after updates
./consolidated_update.sh --cleanup-after

# Run without interactive prompts
./consolidated_update.sh --non-interactive

# Show help
./consolidated_update.sh --help
```

## Update Process

The script follows this logical order:

1. **System checks**: Verify disk space and internet connectivity
2. **macOS updates**: Check for and install system updates
3. **Homebrew and packages**: Update Homebrew and installed packages
4. **Package managers**: Update npm, yarn, conda, rust, bun
5. **Python environments**: Update pip and Python packages
6. **Applications**: Update applications installed via Homebrew Cask
7. **Final steps**: Optional cleanup and service checks

## What Gets Updated

### System Level
- macOS system components
- Homebrew package manager
- Installed Homebrew packages
- Homebrew Cask applications

### Development Tools
- npm (Node.js package manager)
- yarn (JavaScript package manager)
- conda (Python environment manager)
- pip (Python package installer)
- Rust toolchain
- Bun JavaScript runtime

### Python Environments
- pip package manager
- Outdated Python packages
- Conda environments

### Applications
- Applications installed via Homebrew Cask
- VS Code extensions (if applicable)

## Safety Notes

- The script checks for sufficient disk space before proceeding
- Internet connectivity is verified before starting updates
- Major operations can be confirmed before execution
- The script handles errors gracefully and continues with remaining updates

## Recommended Usage

Run this script regularly (weekly or bi-weekly) to keep your system up-to-date. Consider pairing it with the consolidated cleanup script to maintain optimal system performance. Use the `--dry-run` flag first to see what would be updated.