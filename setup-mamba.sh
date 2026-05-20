#!/usr/bin/env bash
################################################################################
# Complete Mamba/Miniforge Setup for /Users/steven
# This script removes old conda installations and sets up fresh Miniforge
################################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
USER_HOME="/Users/steven"
INSTALL_DIR="${USER_HOME}/miniforge3"
BACKUP_DIR="${USER_HOME}/conda_backup_$(date +%Y%m%d_%H%M%S)"
PYTHON_SCRIPTS_DIR="${USER_HOME}/pythons"

# Platform detection
ARCH=$(uname -m)
OS=$(uname -s)

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}${BOLD}▶ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠  $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

get_dir_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

################################################################################
# Main Script
################################################################################

clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                 🚀 MAMBA/MINIFORGE SETUP SCRIPT 🚀                        ║
║                                                                           ║
║  This script will:                                                        ║
║    1. Backup existing conda environments                                  ║
║    2. Remove all conda/anaconda installations                             ║
║    3. Clean shell configuration files                                     ║
║    4. Install fresh Miniforge with Mamba                                  ║
║    5. Configure optimal settings                                          ║
║    6. Set up helper scripts and aliases                                   ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${YELLOW}${BOLD}⚠️  WARNING: This will remove ALL existing conda installations!${NC}"
echo ""
read -p "Do you want to continue? (type 'yes' to confirm): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

################################################################################
# Step 1: Find Existing Conda Installations
################################################################################

print_header "STEP 1: Finding Existing Conda Installations"

CONDA_LOCATIONS=(
    "${USER_HOME}/miniforge3"
    "${USER_HOME}/anaconda3"
    "${USER_HOME}/miniconda3"
    "${USER_HOME}/anaconda"
    "${USER_HOME}/miniconda"
    "${USER_HOME}/mambaforge"
    "/opt/anaconda3"
    "/opt/miniconda3"
)

FOUND_INSTALLATIONS=()

for location in "${CONDA_LOCATIONS[@]}"; do
    if [[ -d "$location" ]]; then
        size=$(get_dir_size "$location")
        echo -e "  ${GREEN}Found:${NC} $location ($size)"
        FOUND_INSTALLATIONS+=("$location")
    fi
done

if [[ ${#FOUND_INSTALLATIONS[@]} -eq 0 ]]; then
    print_success "No existing conda installations found"
else
    echo -e "\n  ${BOLD}Total installations found: ${#FOUND_INSTALLATIONS[@]}${NC}"
fi

################################################################################
# Step 2: Backup Existing Environments
################################################################################

print_header "STEP 2: Backing Up Existing Environments"

mkdir -p "$BACKUP_DIR"

BACKED_UP=0

for install_dir in "${FOUND_INSTALLATIONS[@]}"; do
    envs_dir="${install_dir}/envs"
    
    if [[ ! -d "$envs_dir" ]]; then
        continue
    fi
    
    echo "  Scanning: $envs_dir"
    
    for env_dir in "$envs_dir"/*; do
        if [[ ! -d "$env_dir" ]]; then
            continue
        fi
        
        env_name=$(basename "$env_dir")
        echo "    Backing up: $env_name"
        
        # Try to export environment
        if "${install_dir}/bin/conda" env export -p "$env_dir" --no-builds > "${BACKUP_DIR}/${env_name}.yml" 2>/dev/null; then
            print_success "      Exported ${env_name}.yml"
            ((BACKED_UP++))
        else
            print_warning "      Failed to export $env_name"
        fi
    done
done

if [[ $BACKED_UP -gt 0 ]]; then
    print_success "Backed up $BACKED_UP environments to: $BACKUP_DIR"
else
    echo "  No environments found to backup"
fi

################################################################################
# Step 3: Remove Old Installations
################################################################################

if [[ ${#FOUND_INSTALLATIONS[@]} -gt 0 ]]; then
    print_header "STEP 3: Removing Old Installations"
    
    for install_dir in "${FOUND_INSTALLATIONS[@]}"; do
        echo "  Removing: $install_dir"
        
        # Try to deactivate conda first
        if [[ -f "${install_dir}/bin/conda" ]]; then
            "${install_dir}/bin/conda" init --reverse --all &>/dev/null || true
        fi
        
        # Remove directory
        if rm -rf "$install_dir" 2>/dev/null; then
            print_success "    Removed successfully"
        else
            print_warning "    Need sudo to remove"
            sudo rm -rf "$install_dir" || print_error "    Failed to remove"
        fi
    done
    
    # Clean conda artifacts
    echo ""
    echo "  Cleaning conda artifacts..."
    rm -rf "${USER_HOME}/.conda" 2>/dev/null || true
    rm -f "${USER_HOME}/.condarc" 2>/dev/null || true
    rm -rf "${USER_HOME}/.continuum" 2>/dev/null || true
    print_success "    Cleaned"
else
    print_header "STEP 3: No Old Installations to Remove"
fi

################################################################################
# Step 4: Clean Shell Configuration Files
################################################################################

print_header "STEP 4: Cleaning Shell Configuration Files"

SHELL_FILES=(
    "${USER_HOME}/.bashrc"
    "${USER_HOME}/.bash_profile"
    "${USER_HOME}/.zshrc"
    "${USER_HOME}/.zprofile"
)

for shell_file in "${SHELL_FILES[@]}"; do
    if [[ ! -f "$shell_file" ]]; then
        continue
    fi
    
    echo "  Checking: $(basename $shell_file)"
    
    # Backup
    cp "$shell_file" "${shell_file}.backup_$(date +%Y%m%d_%H%M%S)"
    
    # Remove conda initialization blocks
    sed -i.tmp '/>>> conda initialize >>>/,/<<< conda initialize <<</d' "$shell_file" 2>/dev/null || true
    sed -i.tmp '/>>> mamba initialize >>>/,/<<< mamba initialize <<</d' "$shell_file" 2>/dev/null || true
    
    # Remove conda-related lines (but keep comments)
    grep -v -E '(conda|anaconda|miniconda|miniforge|mamba|mambaforge)' "$shell_file" > "${shell_file}.tmp" || true
    mv "${shell_file}.tmp" "$shell_file" 2>/dev/null || true
    
    rm -f "${shell_file}.tmp" 2>/dev/null || true
    
    print_success "    Cleaned (backup saved)"
done

################################################################################
# Step 5: Download Miniforge
################################################################################

print_header "STEP 5: Downloading Miniforge"

# Determine installer URL based on platform
if [[ "$OS" == "Darwin" ]]; then
    if [[ "$ARCH" == "arm64" ]]; then
        INSTALLER_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh"
        INSTALLER_NAME="Miniforge3-MacOSX-arm64.sh"
    else
        INSTALLER_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
        INSTALLER_NAME="Miniforge3-MacOSX-x86_64.sh"
    fi
elif [[ "$OS" == "Linux" ]]; then
    if [[ "$ARCH" == "aarch64" ]]; then
        INSTALLER_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh"
        INSTALLER_NAME="Miniforge3-Linux-aarch64.sh"
    else
        INSTALLER_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
        INSTALLER_NAME="Miniforge3-Linux-x86_64.sh"
    fi
else
    print_error "Unsupported operating system: $OS"
    exit 1
fi

echo "  Platform: $OS $ARCH"
echo "  Downloading: $INSTALLER_URL"

INSTALLER_PATH="${USER_HOME}/${INSTALLER_NAME}"

if curl -L -o "$INSTALLER_PATH" "$INSTALLER_URL"; then
    print_success "Downloaded to: $INSTALLER_PATH"
else
    print_error "Download failed"
    exit 1
fi

################################################################################
# Step 6: Install Miniforge
################################################################################

print_header "STEP 6: Installing Miniforge"

echo "  Installation directory: $INSTALL_DIR"
echo "  This may take a few minutes..."

chmod +x "$INSTALLER_PATH"

if bash "$INSTALLER_PATH" -b -p "$INSTALL_DIR"; then
    print_success "Miniforge installed successfully"
    rm -f "$INSTALLER_PATH"
    echo "  Removed installer file"
else
    print_error "Installation failed"
    exit 1
fi

################################################################################
# Step 7: Initialize and Configure Mamba
################################################################################

print_header "STEP 7: Initializing and Configuring Mamba"

CONDA_BIN="${INSTALL_DIR}/bin/conda"
MAMBA_BIN="${INSTALL_DIR}/bin/mamba"

# Initialize conda for shell
print_step "Initializing conda for shell..."
"$CONDA_BIN" init zsh
"$CONDA_BIN" init bash

# Configure conda settings
print_step "Configuring optimal settings..."

"$CONDA_BIN" config --set auto_activate_base false
"$CONDA_BIN" config --set solver libmamba
"$CONDA_BIN" config --add channels conda-forge
"$CONDA_BIN" config --set channel_priority strict
"$CONDA_BIN" config --set show_channel_urls true

print_success "Configuration complete"

################################################################################
# Step 8: Update Base Environment
################################################################################

print_header "STEP 8: Updating Base Environment"

print_step "Updating conda and mamba..."
"$MAMBA_BIN" update -n base -c conda-forge conda mamba -y

print_success "Base environment updated"

################################################################################
# Step 9: Install Helper Scripts
################################################################################

print_header "STEP 9: Installing Helper Scripts"

mkdir -p "$PYTHON_SCRIPTS_DIR"

# Create conda-nuke script
cat > "${PYTHON_SCRIPTS_DIR}/conda-nuke" << 'CONDA_NUKE_EOF'
#!/usr/bin/env python3
# Quick conda environment removal tool
import sys, shutil, subprocess
from pathlib import Path

home = Path.home()
envs = home / "miniforge3" / "envs"

if not envs.exists():
    print("No environments found")
    sys.exit(0)

print("Conda Environments:")
env_list = [d for d in envs.iterdir() if d.is_dir()]
for i, env in enumerate(env_list, 1):
    print(f"  {i}. {env.name}")

if len(sys.argv) > 1:
    env_name = sys.argv[1]
else:
    choice = input("\nEnter environment name or number to remove (or 'q' to quit): ")
    if choice.lower() == 'q':
        sys.exit(0)
    
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(env_list):
            env_name = env_list[idx].name
        else:
            print("Invalid choice")
            sys.exit(1)
    else:
        env_name = choice

confirm = input(f"Remove environment '{env_name}'? (yes/no): ")
if confirm.lower() == 'yes':
    subprocess.run(['mamba', 'env', 'remove', '-n', env_name, '-y'])
    print(f"✓ Removed {env_name}")
CONDA_NUKE_EOF

chmod +x "${PYTHON_SCRIPTS_DIR}/conda-nuke"
print_success "Installed conda-nuke"

# Create environment size checker
cat > "${PYTHON_SCRIPTS_DIR}/conda-sizes" << 'CONDA_SIZES_EOF'
#!/usr/bin/env python3
# Show conda environment sizes
import subprocess
from pathlib import Path

home = Path.home()
envs = home / "miniforge3" / "envs"

if not envs.exists():
    print("No environments found")
    exit(0)

print("Conda Environment Sizes:\n")

env_list = []
for env_dir in sorted(envs.iterdir()):
    if not env_dir.is_dir():
        continue
    
    # Get size
    result = subprocess.run(['du', '-sh', str(env_dir)], 
                          capture_output=True, text=True)
    size = result.stdout.split()[0]
    env_list.append((env_dir.name, size))

# Print sorted by name
for name, size in env_list:
    print(f"  {name:30} {size:>10}")

print(f"\n  Total environments: {len(env_list)}")
CONDA_SIZES_EOF

chmod +x "${PYTHON_SCRIPTS_DIR}/conda-sizes"
print_success "Installed conda-sizes"

################################################################################
# Step 10: Create Enhanced .zshrc Section
################################################################################

print_header "STEP 10: Creating Enhanced Shell Configuration"

ZSHRC_ADDITION="${USER_HOME}/.zshrc_mamba"

cat > "$ZSHRC_ADDITION" << 'ZSHRC_EOF'
##### === Mamba/Miniforge Configuration === #####
# Disable auto-activation of base environment
export CONDA_AUTO_ACTIVATE_BASE=false

# Performance optimizations
export CONDA_SOLVER=libmamba
export CONDA_CHANNEL_PRIORITY=strict
export CONDA_VERBOSITY=1

##### === Mamba Helper Functions === #####

# Quick environment activation with tab completion
function ca() {
  if [[ -z "$1" ]]; then
    echo "Usage: ca <env_name>"
    echo "Available environments:"
    mamba env list | grep -v "^#" | awk '{print "  -", $1}'
  else
    conda activate "$1"
  fi
}

# List all environments with sizes
function cenvs() {
  echo "📦 Conda/Mamba Environments:"
  if command -v conda-sizes &>/dev/null; then
    conda-sizes
  else
    mamba env list
  fi
}

# Clean conda/mamba cache
function cclean() {
  echo "🧹 Cleaning conda/mamba cache..."
  mamba clean --all -y
  echo "✅ Done! Cache cleaned."
}

# Export current environment
function cexport() {
  if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    echo "❌ No conda environment active"
  else
    local env_name="$CONDA_DEFAULT_ENV"
    local output="${env_name}_$(date +%Y%m%d).yml"
    mamba env export --no-builds > "$output"
    echo "✅ Exported to: $output"
  fi
}

# Quick environment creation
function cmkenv() {
  local env_name="${1:-myenv}"
  local python_ver="${2:-3.11}"
  echo "🔨 Creating environment: $env_name (Python $python_ver)"
  mamba create -n "$env_name" python="$python_ver" -y
  echo "✅ Created! Activate with: conda activate $env_name"
}

# Install packages quickly
function cpkg() {
  if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    echo "❌ No conda environment active"
    echo "Activate one with: conda activate <env_name>"
  else
    echo "📦 Installing packages in $CONDA_DEFAULT_ENV..."
    mamba install "$@" -y
  fi
}

# Useful aliases
alias mamba='mamba'
alias m='mamba'
alias clist='mamba env list'
alias cinfo='mamba info'
ZSHRC_EOF

print_success "Created $ZSHRC_ADDITION"

# Add source line to .zshrc if not already there
if ! grep -q "source.*\.zshrc_mamba" "${USER_HOME}/.zshrc" 2>/dev/null; then
    echo "" >> "${USER_HOME}/.zshrc"
    echo "# Mamba/Miniforge configuration" >> "${USER_HOME}/.zshrc"
    echo "source ~/.zshrc_mamba" >> "${USER_HOME}/.zshrc"
    print_success "Added to .zshrc"
else
    echo "  Already sourced in .zshrc"
fi

################################################################################
# Step 11: Verification
################################################################################

print_header "STEP 11: Verifying Installation"

# Source the new installation
export PATH="${INSTALL_DIR}/bin:$PATH"

print_step "Checking versions..."
echo -n "  Conda: "
"$CONDA_BIN" --version
echo -n "  Mamba: "
"$MAMBA_BIN" --version

print_step "Checking configuration..."
"$CONDA_BIN" config --show-sources | head -n 10

print_success "Installation verified!"

################################################################################
# Final Summary
################################################################################

clear
cat << EOF

╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    ✅ INSTALLATION COMPLETE! ✅                            ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

📊 Summary:
   • Miniforge installed to: $INSTALL_DIR
   • Mamba ready to use
   • Helper scripts installed
   • Backups saved to: $BACKUP_DIR

🚀 Next Steps:

   1. Restart your terminal:
      ${GREEN}exec \$SHELL${NC}

   2. Or source your shell config:
      ${GREEN}source ~/.zshrc${NC}

   3. Verify installation:
      ${GREEN}mamba --version${NC}
      ${GREEN}which mamba${NC}

📦 Quick Start Commands:

   ${CYAN}# Create a new environment${NC}
   mamba create -n myenv python=3.11 -y
   
   ${CYAN}# Activate environment${NC}
   conda activate myenv
   
   ${CYAN}# Install packages (use mamba, it's faster!)${NC}
   mamba install numpy pandas matplotlib -y
   
   ${CYAN}# List environments${NC}
   cenvs
   
   ${CYAN}# Check environment sizes${NC}
   conda-sizes
   
   ${CYAN}# Remove an environment${NC}
   conda-nuke

🔧 Helper Functions:

   ca <env>          - Quick activate environment
   cenvs             - List all environments with sizes
   cclean            - Clean mamba/conda cache
   cexport           - Export current environment to YAML
   cmkenv <name>     - Quickly create new environment
   cpkg <packages>   - Install packages in active environment

💡 Tips:

   • Always use 'mamba' instead of 'conda' for installations (10-100x faster!)
   • Use 'conda activate/deactivate' for environment management
   • Base environment auto-activation is DISABLED (cleaner workflow)
   • All environments use conda-forge channel by default

EOF

if [[ $BACKED_UP -gt 0 ]]; then
    echo -e "📁 To restore a backed-up environment:"
    echo -e "   ${GREEN}mamba env create -f ${BACKUP_DIR}/<env_name>.yml${NC}"
    echo ""
fi

echo -e "${GREEN}${BOLD}🎉 Enjoy your blazing-fast Mamba setup!${NC}"
echo ""
