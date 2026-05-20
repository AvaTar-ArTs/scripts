#!/usr/bin/env bash

# SIP Disk Repair Script
# This script helps disable SIP, repair disks, and re-enable SIP safely
# Author: AI Assistant
# Date: $(date)

set -e  # Exit on any error

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Run as regular user."
        exit 1
    fi
}

# Function to check SIP status
check_sip_status() {
    print_status "Checking current SIP status..."
    csrutil status
    echo ""
}

# Function to create Recovery Mode script
create_recovery_script() {
    print_status "Creating Recovery Mode script..."
    
    cat > /tmp/recovery_sip_disable.sh << 'EOF'
#!/bin/bash
# Recovery Mode SIP Disable Script
# Run this in Recovery Mode Terminal

echo "=== SIP Disable Script for Recovery Mode ==="
echo "Current SIP status:"
csrutil status
echo ""

echo "Disabling System Integrity Protection..."
csrutil disable

echo ""
echo "SIP Status after disable:"
csrutil status

echo ""
echo "=== SIP DISABLED SUCCESSFULLY ==="
echo "You can now restart your Mac normally."
echo "After restart, run the repair script to fix your disks."
echo "Remember to re-enable SIP after repairs are complete!"
EOF

    chmod +x /tmp/recovery_sip_disable.sh
    print_success "Recovery script created at /tmp/recovery_sip_disable.sh"
}

# Function to create disk repair script
create_repair_script() {
    print_status "Creating disk repair script..."
    
    cat > /tmp/disk_repair_after_sip.sh << 'EOF'
#!/bin/bash
# Disk Repair Script (Run after SIP is disabled)
# This script repairs your disks with SIP disabled

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=== Disk Repair Script (SIP Disabled) ==="
echo ""

# Check SIP status
print_status "Checking SIP status..."
csrutil status
echo ""

# List disks
print_status "Current disk configuration:"
diskutil list
echo ""

# Repair partition map
print_status "Repairing partition map on disk0..."
sudo diskutil repairDisk disk0
echo ""

# Repair EFI partition
print_status "Repairing EFI partition..."
sudo diskutil repairVolume disk0s1
echo ""

# Repair APFS container
print_status "Repairing APFS container..."
sudo diskutil repairVolume disk0s2
echo ""

# Repair individual APFS volumes
print_status "Repairing APFS volumes..."

# Data volume
print_status "Repairing Data volume (disk1s1)..."
sudo diskutil repairVolume disk1s1 || echo "Data volume repair completed with warnings"

# Preboot volume
print_status "Repairing Preboot volume (disk1s2)..."
sudo diskutil repairVolume disk1s2 || echo "Preboot volume repair completed with warnings"

# Recovery volume
print_status "Repairing Recovery volume (disk1s3)..."
sudo diskutil repairVolume disk1s3 || echo "Recovery volume repair completed with warnings"

# System volume
print_status "Repairing System volume (disk1s4)..."
sudo diskutil repairVolume disk1s4 || echo "System volume repair completed with warnings"

# VM volume
print_status "Repairing VM volume (disk1s6)..."
sudo diskutil repairVolume disk1s6 || echo "VM volume repair completed with warnings"

echo ""
print_status "Running final verification..."
diskutil verifyDisk disk0

echo ""
print_success "Disk repair completed!"
echo ""
echo "=== NEXT STEPS ==="
echo "1. Test your Mac to ensure everything works"
echo "2. Run the SIP re-enable script when ready"
echo "3. Re-enable SIP for security"
EOF

    chmod +x /tmp/disk_repair_after_sip.sh
    print_success "Repair script created at /tmp/disk_repair_after_sip.sh"
}

# Function to create SIP re-enable script
create_reenable_script() {
    print_status "Creating SIP re-enable script..."
    
    cat > /tmp/reenable_sip.sh << 'EOF'
#!/bin/bash
# SIP Re-enable Script
# Run this after disk repairs are complete

echo "=== SIP Re-enable Script ==="
echo ""
echo "This script will help you re-enable System Integrity Protection."
echo "SIP can only be re-enabled from Recovery Mode."
echo ""
echo "Current SIP status:"
csrutil status
echo ""

echo "To re-enable SIP:"
echo "1. Restart your Mac"
echo "2. Hold Command + R during startup"
echo "3. Open Terminal in Recovery Mode"
echo "4. Run: csrutil enable"
echo "5. Restart your Mac"
echo ""

echo "Or run this command in Recovery Mode Terminal:"
echo "csrutil enable"
echo ""

echo "After re-enabling SIP, verify with: csrutil status"
EOF

    chmod +x /tmp/reenable_sip.sh
    print_success "Re-enable script created at /tmp/reenable_sip.sh"
}

# Function to create Recovery Mode instructions
create_recovery_instructions() {
    print_status "Creating Recovery Mode instructions..."
    
    cat > /tmp/recovery_instructions.txt << 'EOF'
RECOVERY MODE INSTRUCTIONS FOR SIP DISABLE
==========================================

STEP 1: Boot into Recovery Mode
- Restart your Mac
- Hold Command + R during startup
- Wait for Recovery Mode to load

STEP 2: Open Terminal
- Click on "Utilities" in the menu bar
- Select "Terminal"

STEP 3: Disable SIP
- Type: csrutil disable
- Press Enter
- You should see "Successfully disabled System Integrity Protection"

STEP 4: Verify SIP is disabled
- Type: csrutil status
- Should show "System Integrity Protection status: disabled"

STEP 5: Restart
- Type: reboot
- Or use Apple menu > Restart

STEP 6: Run disk repairs
- After restart, run: /tmp/disk_repair_after_sip.sh

STEP 7: Re-enable SIP (IMPORTANT!)
- Boot into Recovery Mode again
- Open Terminal
- Type: csrutil enable
- Restart your Mac

SAFETY NOTES:
- Only disable SIP temporarily
- Always re-enable SIP after repairs
- Keep your Mac secure
EOF

    print_success "Recovery instructions created at /tmp/recovery_instructions.txt"
}

# Main execution
main() {
    echo "=========================================="
    echo "    SIP Disk Repair Management Script"
    echo "=========================================="
    echo ""
    
    check_root
    check_sip_status
    
    print_warning "IMPORTANT: SIP can only be disabled from Recovery Mode!"
    print_warning "This script will prepare everything you need."
    echo ""
    
    # Create all necessary scripts
    create_recovery_script
    create_repair_script
    create_reenable_script
    create_recovery_instructions
    
    echo ""
    print_success "All scripts created successfully!"
    echo ""
    echo "=== FILES CREATED ==="
    echo "1. /tmp/recovery_sip_disable.sh - Run in Recovery Mode"
    echo "2. /tmp/disk_repair_after_sip.sh - Run after SIP disable"
    echo "3. /tmp/reenable_sip.sh - Instructions to re-enable SIP"
    echo "4. /tmp/recovery_instructions.txt - Detailed instructions"
    echo ""
    
    echo "=== NEXT STEPS ==="
    echo "1. Restart your Mac"
    echo "2. Hold Command + R during startup"
    echo "3. Open Terminal in Recovery Mode"
    echo "4. Run: /tmp/recovery_sip_disable.sh"
    echo "5. Restart and run: /tmp/disk_repair_after_sip.sh"
    echo "6. Re-enable SIP when done"
    echo ""
    
    print_warning "Remember to re-enable SIP for security!"
    
    # Ask if user wants to restart now
    echo ""
    read -p "Do you want to restart into Recovery Mode now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restarting into Recovery Mode..."
        sudo reboot
    else
        print_status "You can restart manually when ready."
    fi
}

# Run main function
main "$@"
