#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Script to reboot into Recovery Mode
# After rebooting, open Terminal from Utilities menu and run the repair commands

echo "=========================================="
echo "Mac Disk Repair - Recovery Mode Reboot"
echo "=========================================="
echo ""
echo "This will reboot your Mac into Recovery Mode."
echo ""
echo "AFTER REBOOTING:"
echo "1. Your Mac will restart and boot into Recovery Mode"
echo "2. Go to: Utilities menu → Terminal"
echo "3. Run these commands in order:"
echo ""
echo "------- Copy these commands -------"
echo ""
echo "# List disks to verify"
echo "diskutil list"
echo ""
echo "# Repair APFS container"
echo "diskutil repairVolume disk0s2"
echo ""
echo "# Repair individual volumes"
echo "diskutil repairVolume disk1s1"
echo "diskutil repairVolume disk1s2"
echo "diskutil repairVolume disk1s3"
echo ""
echo "# Repair entire disk (answer 'y' when prompted)"
echo "diskutil repairDisk disk0"
echo ""
echo "-----------------------------------"
echo ""
read -p "Press ENTER to reboot into Recovery Mode (Ctrl+C to cancel)..."

echo ""
echo "Rebooting into Recovery Mode..."
echo "Hold Command+R if it doesn't enter Recovery automatically..."

# Reboot into Recovery Mode
sudo nvram "recovery-boot-mode=unused"
sudo reboot
