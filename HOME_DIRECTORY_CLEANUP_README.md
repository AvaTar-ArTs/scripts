# Home Directory Cleanup Routine

This directory contains scripts and instructions for maintaining a clean home directory and reducing disk usage.

## Cleanup Script

The `cleanup_old_files.sh` script performs the following tasks:
- Removes backup and temporary files older than 30 days
- Cleans up pip cache
- Cleans up uv cache
- Prunes Docker system (removes unused images, networks, etc.)
- Cleans up Google API client discovery cache
- Removes temporary directories

## Setup Instructions

### Manual Cleanup
Run the script manually at any time:
```bash
/Users/steven/scripts/cleanup_old_files.sh
```

### Automated Cleanup
To set up automated weekly cleanup:

1. Make sure the script is executable:
```bash
chmod +x /Users/steven/scripts/cleanup_old_files.sh
```

2. Add the following entry to your crontab to run the cleanup weekly:
```bash
crontab -e
```

Then add this line to run the cleanup every Sunday at 2 AM:
```
0 2 * * 0 /Users/steven/scripts/cleanup_old_files.sh >> /Users/steven/logs/cleanup.log 2>&1
```

Or use the provided crontab entry template in `cleanup_crontab_entry.txt`.

## What This Addresses

This cleanup routine addresses the following issues identified in the home directory:
- Accumulation of old backup files (.bak, .backup, etc.)
- Large cache directories
- Unused Docker images and containers
- Temporary files that accumulate over time

Regular execution of this script will help maintain a smaller home directory footprint and prevent the accumulation of unnecessary files.