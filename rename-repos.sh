#!/bin/bash
# GitHub Repository Bulk Rename Script (Shell)
# Renames multiple repositories using the GitHub API.
#
# Usage:
#     ./rename-repos.sh --token YOUR_TOKEN
#
# Requirements:
#     - GitHub Personal Access Token with repo admin permissions
#     - curl command-line tool
#     - jq for JSON parsing (optional, but recommended)

set -euo pipefail

# Configuration
OWNER="AvaTar-ArTs"
BASE_URL="https://api.github.com"

# Mapping of old repo names to new names
declare -A RENAME_MAP=(
    ["Ai-Code-Hub"]="AgentForge-Core"
    ["Ai-Merge-GitHub"]="GitMergeAI"
    ["VAULT-OPS-PRO"]="CreatorOS-Vault"
    ["trend-pulse-pro"]="CreatorOS-Trends"
    ["n8n_workflows"]="CreatorOS-Workflows"
    ["PasTe-Export"]="CreatorOS-Export"
    ["NotebookLM"]="NotebookLM-Lab"
    ["my-manus"]="AgentForge-Manus"
    ["my-cline"]="AgentForge-Cline"
    ["my-codex"]="AgentForge-Codex"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
SUCCESS_COUNT=0
FAILURE_COUNT=0

# Functions
print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --token TOKEN      GitHub Personal Access Token (required)
    --owner OWNER      GitHub username/org (default: AvaTar-ArTs)
    --dry-run          Show what would be renamed without making changes
    --help             Show this help message

Examples:
    $0 --token ghp_xxxxxxxxxxxxxxxxxxxx
    $0 --token \$GITHUB_TOKEN --dry-run

EOF
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Parse arguments
TOKEN=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            TOKEN="$2"
            shift 2
            ;;
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate token
if [[ -z "$TOKEN" ]]; then
    print_error "GitHub token is required!"
    print_usage
    exit 1
fi

# Check for required tools
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed."
    exit 1
fi

# Dry run mode
if [[ "$DRY_RUN" == true ]]; then
    echo ""
    print_info "DRY RUN - No changes will be made"
    echo ""
    printf "%-30s → %-30s\n" "Old Name" "New Name"
    printf '%s\n' "$(printf '=%.0s' {1..62})"
    
    for old_name in "${!RENAME_MAP[@]}"; do
        new_name="${RENAME_MAP[$old_name]}"
        printf "%-30s → %-30s\n" "$old_name" "$new_name"
    done
    echo ""
    exit 0
fi

# Rename repositories
echo ""
print_info "Starting bulk rename for ${#RENAME_MAP[@]} repositories..."
echo ""

for old_name in "${!RENAME_MAP[@]}"; do
    new_name="${RENAME_MAP[$old_name]}"
    
    # API endpoint
    URL="$BASE_URL/repos/$OWNER/$old_name"
    
    # JSON payload
    PAYLOAD=$(cat <<EOF
{
  "name": "$new_name"
}
EOF
)
    
    # Make API call
    RESPONSE=$(curl -s -X PATCH \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        -d "$PAYLOAD" \
        "$URL")
    
    # Check response
    if echo "$RESPONSE" | grep -q '"id"'; then
        # Success - repo was renamed
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        print_success "$old_name → $new_name"
    elif echo "$RESPONSE" | grep -q '"Not Found"'; then
        # Repository not found
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        print_error "$old_name: Repository not found (404)"
    elif echo "$RESPONSE" | grep -q '"message"'; then
        # Error response
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        print_error "$old_name: $ERROR_MSG"
    else
        # Unknown response
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        print_error "$old_name: Unexpected response"
    fi
done

# Summary
echo ""
printf '%s\n' "$(printf '=%.0s' {1..62})"
print_success "Successful: $SUCCESS_COUNT/${#RENAME_MAP[@]}"
if [[ $FAILURE_COUNT -gt 0 ]]; then
    print_error "Failed: $FAILURE_COUNT/${#RENAME_MAP[@]}"
fi
printf '%s\n' "$(printf '=%.0s' {1..62})"
echo ""

# Exit with appropriate code
if [[ $FAILURE_COUNT -eq 0 ]]; then
    exit 0
else
    exit 1
fi
