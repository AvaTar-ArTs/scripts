#!/usr/bin/env bash

################################################################################
# CleanConnect Pro 2.0 - GitHub Deploy Script
#
# This script syncs changes and pushes them to the GitHub repository
#
# Usage:
#   bash deploy-to-github.sh                    # Full deploy with prompts
#   bash deploy-to-github.sh --help             # Show help
#   bash deploy-to-github.sh --sync-only        # Sync files only
#   bash deploy-to-github.sh --no-sync          # Push without syncing
#   bash deploy-to-github.sh --auto             # Auto-deploy (no prompts)
#
# Configuration:
#   SOURCE_DIR: /Users/steven/tehSiTes/cleanconnect-pro
#   GITHUB_DIR: /Users/steven/Documents/github/cleanconnect-pro
#   REPO_URL:   git@github.com:ichoake/cleanconnect-pro.git
#
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SOURCE_DIR="/Users/steven/tehSiTes/cleanconnect-pro"
GITHUB_DIR="/Users/steven/Documents/github/cleanconnect-pro"
REPO_URL="git@github.com:ichoake/cleanconnect-pro.git"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
BRANCH="${BRANCH:-main}"

# Flags
SYNC_ONLY=false
NO_SYNC=false
AUTO_DEPLOY=false
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
    echo -e "\n${CYAN}→${NC} $1"
}

print_divider() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

ask_yes_no() {
    local prompt="$1"
    local response
    read -p "$(echo -e ${YELLOW}$prompt${NC})" response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

show_help() {
    cat << EOF
${BLUE}CleanConnect Pro 2.0 - GitHub Deploy Script${NC}

${GREEN}Usage:${NC}
    bash deploy-to-github.sh [OPTIONS]

${GREEN}Options:${NC}
    -h, --help              Show this help message
    --sync-only             Sync files only (no git push)
    --no-sync               Push without syncing files
    --auto                  Auto-deploy (no prompts)
    -v, --verbose           Show verbose output

${GREEN}Examples:${NC}
    bash deploy-to-github.sh              # Full deploy with prompts
    bash deploy-to-github.sh --auto       # Auto-deploy
    bash deploy-to-github.sh --sync-only  # Sync files only
    bash deploy-to-github.sh --no-sync    # Push without syncing

${GREEN}Configuration:${NC}
    SOURCE:  $SOURCE_DIR
    TARGET:  $GITHUB_DIR
    REPO:    $REPO_URL
    BRANCH:  $BRANCH

${GREEN}Environment Variables:${NC}
    BRANCH              Git branch to push to (default: main)
    SOURCE_DIR          Source directory (default: project dir)
    GITHUB_DIR          GitHub clone directory
    REPO_URL            GitHub repository URL

${GREEN}What This Script Does:${NC}
    1. Validates directories exist
    2. Syncs files from source to GitHub directory
    3. Creates/updates git status report
    4. Reviews changes
    5. Commits changes with timestamp
    6. Pushes to GitHub repository

${GREEN}Support:${NC}
    Email: dev@quantumforgelabs.org
    Discord: https://discord.gg/quantumforgelabs
    GitHub: https://github.com/quantumforgelabs/cleanconnect-pro

EOF
    exit 0
}

################################################################################
# VALIDATION FUNCTIONS
################################################################################

validate_directories() {
    print_step "Validating directories..."

    if [ ! -d "$SOURCE_DIR" ]; then
        print_error "Source directory not found: $SOURCE_DIR"
        return 1
    fi
    print_success "Source directory exists: $SOURCE_DIR"

    if [ ! -d "$GITHUB_DIR" ]; then
        print_warning "GitHub directory not found: $GITHUB_DIR"
        if ask_yes_no "Would you like to clone the repository? (y/n) "; then
            clone_repository
        else
            print_error "GitHub directory required"
            return 1
        fi
    else
        print_success "GitHub directory exists: $GITHUB_DIR"
    fi

    return 0
}

clone_repository() {
    print_step "Cloning repository..."
    mkdir -p "$(dirname "$GITHUB_DIR")"
    git clone "$REPO_URL" "$GITHUB_DIR"
    print_success "Repository cloned"
}

validate_git_repo() {
    print_step "Validating Git repository..."

    if ! cd "$GITHUB_DIR"; then
        print_error "Cannot navigate to GitHub directory"
        return 1
    fi

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a valid Git repository: $GITHUB_DIR"
        return 1
    fi

    print_success "Valid Git repository"
    return 0
}

check_git_config() {
    print_step "Checking Git configuration..."

    if ! git config user.email > /dev/null 2>&1; then
        print_warning "Git user.email not configured"
        read -p "Enter your email: " email
        git config --global user.email "$email"
    fi

    if ! git config user.name > /dev/null 2>&1; then
        print_warning "Git user.name not configured"
        read -p "Enter your name: " name
        git config --global user.name "$name"
    fi

    print_success "Git configured"
}

################################################################################
# SYNC FUNCTIONS
################################################################################

sync_files() {
    print_step "Syncing files from source to GitHub directory..."

    cd "$SOURCE_DIR"

    # Files and directories to sync
    local files_to_sync=(
        "README.md"
        "YARN_SETUP.md"
        "MIGRATION_SUMMARY.md"
        "UPDATES_2.0.md"
        "INSTALLATION_METHODS.md"
        "environment.yml"
        "setup.sh"
        "deploy-to-github.sh"
        "package.json"
        "yarn.lock"
        "ecosystem.config.js"
        "backend/package.json"
        "backend/yarn.lock"
        "frontend/package.json"
        "database/"
        "docs/"
        "mobile/"
        "admin/"
    )

    local file_count=0
    local sync_count=0

    for file in "${files_to_sync[@]}"; do
        ((file_count++))

        if [ -e "$SOURCE_DIR/$file" ]; then
            # Use rsync for directories
            if [ -d "$SOURCE_DIR/$file" ]; then
                rsync -av --delete "$SOURCE_DIR/$file/" "$GITHUB_DIR/$file/" 2>/dev/null
            else
                cp "$SOURCE_DIR/$file" "$GITHUB_DIR/$file"
            fi
            ((sync_count++))
            [ "$VERBOSE" = true ] && print_info "Synced: $file"
        fi
    done

    print_success "Files synced: $sync_count/$file_count"
}

show_git_status() {
    print_step "Git Status in GitHub Directory..."
    print_divider

    cd "$GITHUB_DIR"
    git status

    print_divider
    print_step "Recent Changes..."
    print_divider

    git diff --stat HEAD~5..HEAD 2>/dev/null || git diff --stat

    print_divider
}

generate_status_report() {
    print_step "Generating status report..."

    cd "$GITHUB_DIR"

    local report_file="DEPLOYMENT_REPORT.md"

    cat > "$report_file" << EOF
# Deployment Report

**Date:** $CURRENT_DATE
**Branch:** $BRANCH
**Source:** $SOURCE_DIR
**Target:** $GITHUB_DIR

## Changes

\`\`\`
$(git diff --stat)
\`\`\`

## Status

\`\`\`
$(git status --short)
\`\`\`

## Recent Commits

\`\`\`
$(git log --oneline -10)
\`\`\`

---

Generated by deploy-to-github.sh

EOF

    print_success "Status report generated: $report_file"
}

################################################################################
# GIT FUNCTIONS
################################################################################

stage_changes() {
    print_step "Staging changes..."

    cd "$GITHUB_DIR"

    git add -A

    local staged_count=$(git diff --cached --name-only | wc -l)
    print_success "Staged $staged_count files"
}

commit_changes() {
    print_step "Committing changes..."

    cd "$GITHUB_DIR"

    local commit_msg="🚀 Deploy: Version 2.0 updates - $CURRENT_DATE"

    if [ "$AUTO_DEPLOY" = true ]; then
        git commit -m "$commit_msg" --quiet
        print_success "Committed: $commit_msg"
    else
        echo ""
        echo -e "${YELLOW}Commit Message:${NC}"
        echo "$commit_msg"
        echo ""

        if ask_yes_no "Commit with this message? (y/n) "; then
            git commit -m "$commit_msg"
            print_success "Committed: $commit_msg"
        else
            print_warning "Commit cancelled"
            return 1
        fi
    fi
}

push_to_github() {
    print_step "Pushing to GitHub..."

    cd "$GITHUB_DIR"

    if [ "$AUTO_DEPLOY" = true ]; then
        git push origin "$BRANCH" --quiet
        print_success "Pushed to GitHub ($BRANCH)"
    else
        echo ""
        print_info "This will push to: $REPO_URL (branch: $BRANCH)"
        echo ""

        if ask_yes_no "Push changes to GitHub? (y/n) "; then
            git push origin "$BRANCH"
            print_success "Pushed to GitHub ($BRANCH)"
        else
            print_warning "Push cancelled"
            return 1
        fi
    fi
}

################################################################################
# MAIN FLOW
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            --sync-only)
                SYNC_ONLY=true
                shift
                ;;
            --no-sync)
                NO_SYNC=true
                shift
                ;;
            --auto)
                AUTO_DEPLOY=true
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

    print_header "🚀 CleanConnect Pro 2.0 - GitHub Deploy"

    print_info "Source Directory: $SOURCE_DIR"
    print_info "GitHub Directory: $GITHUB_DIR"
    print_info "Repository: $REPO_URL"
    print_info "Branch: $BRANCH"

    # Validation
    validate_directories || exit 1
    validate_git_repo || exit 1
    check_git_config || exit 1

    # Sync files
    if [ "$NO_SYNC" = false ]; then
        sync_files
        generate_status_report
        show_git_status
    fi

    if [ "$SYNC_ONLY" = true ]; then
        print_success "Sync complete!"
        exit 0
    fi

    # Git operations
    stage_changes || exit 1
    commit_changes || exit 1
    push_to_github || exit 1

    # Summary
    print_header "✅ Deployment Complete!"

    cat << EOF
${GREEN}Changes have been successfully deployed to GitHub!${NC}

${BLUE}Summary:${NC}
  • Files synced from source
  • Changes committed to Git
  • Repository pushed to GitHub
  • Branch: $BRANCH

${BLUE}Repository:${NC}
  $REPO_URL

${BLUE}View on GitHub:${NC}
  https://github.com/ichoake/cleanconnect-pro

${BLUE}Next Steps:${NC}
  1. Visit the repository on GitHub
  2. Verify changes are pushed
  3. Create a pull request if needed
  4. Review and merge changes

EOF
}

# Run main
main "$@"
