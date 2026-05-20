#!/usr/bin/env bash

################################################################################
# CleanConnect Pro 2.0 - Complete Setup Script
#
# This script handles complete installation and setup of CleanConnect Pro
#
# Usage:
#   bash setup.sh                    # Full setup
#   bash setup.sh --help             # Show help
#   bash setup.sh --check-only       # Check dependencies only
#   bash setup.sh --skip-db          # Skip database setup
#
# Requirements:
#   - macOS or Linux
#   - curl or wget
#   - Administrator/sudo access for some operations
#
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
SKIP_DB=false
CHECK_ONLY=false
SHOW_HELP=false
VERBOSE=false

################################################################################
# UTILITY FUNCTIONS
################################################################################

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "\n${BLUE}→${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get OS type
get_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Show help
show_help() {
    cat << EOF
${BLUE}CleanConnect Pro 2.0 - Setup Script${NC}

${GREEN}Usage:${NC}
    bash setup.sh [OPTIONS]

${GREEN}Options:${NC}
    -h, --help              Show this help message
    --check-only            Only check dependencies (don't install)
    --skip-db               Skip database setup
    -v, --verbose           Show verbose output

${GREEN}Examples:${NC}
    bash setup.sh                     # Full setup
    bash setup.sh --check-only        # Check dependencies
    bash setup.sh --skip-db           # Skip database setup
    bash setup.sh --verbose           # Verbose output

${GREEN}Requirements:${NC}
    • Node.js 18.0.0+
    • Yarn 3.0.0+
    • PostgreSQL 14+
    • Git
    • macOS or Linux

${GREEN}Support:${NC}
    Email: dev@quantumforgelabs.org
    Discord: https://discord.gg/quantumforgelabs
    GitHub: https://github.com/quantumforgelabs/cleanconnect-pro

EOF
    exit 0
}

################################################################################
# DEPENDENCY CHECKING
################################################################################

check_node() {
    print_step "Checking Node.js..."
    if command_exists node; then
        local version=$(node -v | cut -d'v' -f2)
        print_success "Node.js found: v$version"
        return 0
    else
        print_error "Node.js not found"
        return 1
    fi
}

check_yarn() {
    print_step "Checking Yarn..."
    if command_exists yarn; then
        local version=$(yarn -v)
        print_success "Yarn found: v$version"
        return 0
    else
        print_error "Yarn not found"
        return 1
    fi
}

check_npm() {
    print_step "Checking npm..."
    if command_exists npm; then
        local version=$(npm -v)
        print_success "npm found: v$version"
        return 0
    else
        print_error "npm not found"
        return 1
    fi
}

check_postgres() {
    print_step "Checking PostgreSQL..."
    if command_exists psql; then
        local version=$(psql --version | awk '{print $3}')
        print_success "PostgreSQL found: v$version"
        return 0
    else
        print_error "PostgreSQL not found (required for database)"
        return 1
    fi
}

check_git() {
    print_step "Checking Git..."
    if command_exists git; then
        local version=$(git --version | awk '{print $3}')
        print_success "Git found: v$version"
        return 0
    else
        print_error "Git not found"
        return 1
    fi
}

check_curl() {
    print_step "Checking curl..."
    if command_exists curl; then
        print_success "curl found"
        return 0
    else
        print_warning "curl not found (optional)"
        return 1
    fi
}

check_make() {
    print_step "Checking make..."
    if command_exists make; then
        print_success "make found"
        return 0
    else
        print_warning "make not found (optional)"
        return 1
    fi
}

check_all_dependencies() {
    print_header "Checking Dependencies"

    local all_ok=true

    check_node || all_ok=false
    check_npm || all_ok=false
    check_yarn || all_ok=false
    check_git || all_ok=false
    check_curl || all_ok=false
    check_make || all_ok=false

    if [ "$all_ok" = true ]; then
        print_success "All core dependencies found!"
        return 0
    else
        print_error "Some dependencies are missing"
        return 1
    fi
}

################################################################################
# INSTALLATION FUNCTIONS
################################################################################

install_node_macos() {
    print_step "Installing Node.js via Homebrew..."
    if command_exists brew; then
        brew install node@18
        print_success "Node.js installed"
    else
        print_error "Homebrew not found. Install Node.js manually from https://nodejs.org/"
        return 1
    fi
}

install_node_linux() {
    print_step "Installing Node.js via apt..."
    sudo apt-get update
    sudo apt-get install -y nodejs npm
    print_success "Node.js installed"
}

install_yarn_macos() {
    print_step "Installing Yarn via Homebrew..."
    if command_exists brew; then
        brew install yarn
        print_success "Yarn installed"
    else
        print_info "Installing Yarn via npm..."
        npm install -g yarn
        print_success "Yarn installed"
    fi
}

install_yarn_linux() {
    print_step "Installing Yarn..."
    npm install -g yarn
    print_success "Yarn installed"
}

install_postgres_macos() {
    print_step "Installing PostgreSQL via Homebrew..."
    if command_exists brew; then
        brew install postgresql@14
        brew services start postgresql@14
        print_success "PostgreSQL installed and started"
    else
        print_warning "Homebrew not found. Install PostgreSQL manually from https://postgresql.org/"
        return 1
    fi
}

install_postgres_linux() {
    print_step "Installing PostgreSQL via apt..."
    sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    print_success "PostgreSQL installed and started"
}

################################################################################
# SETUP FUNCTIONS
################################################################################

setup_project_dependencies() {
    print_header "Installing Project Dependencies"

    print_step "Installing root dependencies..."
    yarn install
    print_success "Root dependencies installed"

    print_step "Installing backend dependencies..."
    cd backend
    yarn install
    cd ..
    print_success "Backend dependencies installed"

    print_step "Installing frontend dependencies..."
    cd frontend
    yarn install
    cd ..
    print_success "Frontend dependencies installed"
}

setup_environment() {
    print_header "Setting Up Environment"

    if [ -f .env ]; then
        print_warning ".env file already exists"
    else
        print_step "Creating .env file..."
        cp .env.example .env
        print_success ".env file created"
        print_info "Please edit .env with your configuration"
    fi
}

setup_database() {
    if [ "$SKIP_DB" = true ]; then
        print_warning "Skipping database setup (--skip-db flag)"
        return 0
    fi

    print_header "Setting Up Database"

    print_step "Checking PostgreSQL..."
    if ! command_exists psql; then
        print_error "PostgreSQL not found. Install it first."
        return 1
    fi

    print_step "Creating database..."
    createdb cleanconnect_pro_dev || print_warning "Database may already exist"
    print_success "Database ready"

    print_step "Applying schema..."
    psql -d cleanconnect_pro_dev -f database/database-schema.sql
    print_success "Database schema applied"

    print_step "Loading sample data..."
    if [ -f database/sample-data.sql ]; then
        psql -d cleanconnect_pro_dev -f database/sample-data.sql
        print_success "Sample data loaded"
    else
        print_warning "sample-data.sql not found"
    fi
}

################################################################################
# MAIN SETUP FLOW
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            --check-only)
                CHECK_ONLY=true
                shift
                ;;
            --skip-db)
                SKIP_DB=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                ;;
        esac
    done

    print_header "🚀 CleanConnect Pro 2.0 Setup"

    print_info "Operating System: $(get_os)"
    print_info "Project Directory: $(pwd)"

    # Check dependencies
    if ! check_all_dependencies; then
        print_warning "Some dependencies are missing"

        if [ "$CHECK_ONLY" = true ]; then
            exit 1
        fi

        local os=$(get_os)
        if [ "$os" = "macos" ]; then
            print_step "Would you like to install missing dependencies? (y/n)"
            read -r response
            if [ "$response" = "y" ]; then
                install_node_macos
                install_yarn_macos
                install_postgres_macos
            fi
        elif [ "$os" = "linux" ]; then
            print_step "Would you like to install missing dependencies? (y/n)"
            read -r response
            if [ "$response" = "y" ]; then
                install_node_linux
                install_yarn_linux
                install_postgres_linux
            fi
        fi
    fi

    if [ "$CHECK_ONLY" = true ]; then
        print_success "Dependency check complete!"
        exit 0
    fi

    # Setup project
    setup_environment
    setup_project_dependencies
    setup_database

    print_header "✅ Setup Complete!"

    cat << EOF
${GREEN}CleanConnect Pro 2.0 is ready to use!${NC}

${BLUE}Next steps:${NC}

1. Edit your environment configuration:
   nano .env

2. Start development servers in separate terminals:

   ${YELLOW}Terminal 1 - Backend:${NC}
   yarn dev:api

   ${YELLOW}Terminal 2 - Frontend:${NC}
   yarn dev:frontend

   ${YELLOW}Terminal 3 - Mobile (optional):${NC}
   yarn dev:mobile

3. Access your applications:
   • Frontend:      http://localhost:5173
   • API Server:    http://localhost:3000
   • Mobile App:    http://localhost:5173/mobile
   • Admin Panel:   http://localhost:5173/admin

${BLUE}For more information, see:${NC}
   • README.md - Quick start guide
   • YARN_SETUP.md - Detailed setup instructions
   • docs/api-endpoints.md - API documentation

${BLUE}Questions or Issues?${NC}
   • Email: dev@quantumforgelabs.org
   • Discord: https://discord.gg/quantumforgelabs
   • GitHub: https://github.com/quantumforgelabs/cleanconnect-pro

EOF
}

# Run main
main "$@"
