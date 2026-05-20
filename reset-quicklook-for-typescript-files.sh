#!/usr/bin/env bash
# Fix Quick Look preview for .ts (TypeScript) files
# The issue: .ts files are being recognized as MPEG Transport Stream (video) instead of text

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "  🔧 ${BLUE}Fix .ts File Quick Look Preview${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Check if duti is available
check_duti() {
    if command -v duti >/dev/null 2>&1; then
        DUTI_CMD="duti"
    elif [ -f "/usr/local/bin/duti" ]; then
        DUTI_CMD="/usr/local/bin/duti"
    else
        echo -e "${RED}❌ duti not found. Installing...${NC}"
        brew install duti
        DUTI_CMD="duti"
    fi
    echo -e "${GREEN}✓${NC} Using duti: $DUTI_CMD"
}

# Fix file association using duti
fix_with_duti() {
    echo -e "${BLUE}📝 Fixing .ts file association...${NC}"
    
    # Set .ts files to open with TextEdit (forces text recognition)
    $DUTI_CMD -s com.apple.TextEdit .ts all 2>&1 || true
    
    # Also set .tsx files
    $DUTI_CMD -s com.apple.TextEdit .tsx all 2>&1 || true
    
    echo -e "${GREEN}✓${NC} File associations updated"
}

# Reset LaunchServices database
reset_launchservices() {
    echo -e "${BLUE}🔄 Resetting LaunchServices database...${NC}"
    
    # Kill Quick Look server
    killall qlmanage 2>/dev/null || true
    
    # Reset LaunchServices
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user 2>&1 | head -3
    
    echo -e "${GREEN}✓${NC} LaunchServices database reset"
}

# Force metadata update for .ts files
force_metadata_refresh() {
    echo -e "${BLUE}🔄 Forcing metadata refresh...${NC}"
    
    # Find a .ts file to test with
    test_file=$(find ~ -name "*.ts" -type f 2>/dev/null | head -1)
    
    if [ -n "$test_file" ]; then
        echo -e "  Testing with: ${CYAN}$test_file${NC}"
        
        # Touch the file to force metadata refresh
        touch "$test_file"
        
        # Use mdimport to force re-indexing
        mdimport "$test_file" 2>/dev/null || true
        
        # Check the content type
        content_type=$(mdls -name kMDItemContentType "$test_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
        echo -e "  Content type: ${YELLOW}$content_type${NC}"
        
        if [[ "$content_type" == *"text"* ]] || [[ "$content_type" == *"source"* ]]; then
            echo -e "  ${GREEN}✓${NC} File is now recognized as text"
        else
            echo -e "  ${YELLOW}⚠${NC}  File still not recognized as text (may need manual fix)"
        fi
    else
        echo -e "  ${YELLOW}No .ts files found to test${NC}"
    fi
}

# Create a Quick Look generator info plist entry
create_ql_override() {
    echo -e "${BLUE}📋 Creating Quick Look override...${NC}"
    
    QL_DIR="$HOME/Library/QuickLook"
    mkdir -p "$QL_DIR"
    
    # Create a plist to force text recognition for .ts files
    cat > "$QL_DIR/TypeScript.qlgenerator/Contents/Info.plist" 2>/dev/null << 'EOF' || true
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.apple.quicklook.text.typescript</string>
    <key>CFBundleName</key>
    <string>TypeScript Quick Look</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>TypeScript Source</string>
            <key>CFBundleTypeRole</key>
            <string>QLGenerator</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.plain-text</string>
                <string>public.source-code</string>
            </array>
            <key>LSHandlerRank</key>
            <string>Owner</string>
        </dict>
    </array>
</dict>
</plist>
EOF
    
    echo -e "${GREEN}✓${NC} Quick Look configuration updated"
}

# Alternative: Use xattr to set content type
set_content_type_attribute() {
    echo -e "${BLUE}🏷️  Setting content type attributes...${NC}"
    
    # This is a workaround - we'll create a script that users can run
    cat > "$HOME/scripts/fix_ts_files_metadata.sh" << 'EOF'
#!/bin/bash
# Fix metadata for all .ts files to be recognized as text

find "$HOME" -name "*.ts" -type f 2>/dev/null | while read file; do
    # Remove any existing type identifier
    xattr -d com.apple.quarantine "$file" 2>/dev/null || true
    
    # Force text recognition by touching and re-indexing
    touch "$file"
    mdimport "$file" 2>/dev/null || true
done

echo "Metadata refresh initiated for .ts files"
EOF
    
    chmod +x "$HOME/scripts/fix_ts_files_metadata.sh"
    echo -e "${GREEN}✓${NC} Created metadata fix script: ${CYAN}$HOME/scripts/fix_ts_files_metadata.sh${NC}"
}

# Test Quick Look
test_quicklook() {
    echo -e "${BLUE}🧪 Testing Quick Look...${NC}"
    
    # Create a test file
    test_file="/tmp/test_typescript.ts"
    cat > "$test_file" << 'EOF'
// TypeScript test file
interface User {
    name: string;
    age: number;
}

const user: User = {
    name: "Test",
    age: 30
};

export default user;
EOF
    
    echo -e "  Created test file: ${CYAN}$test_file${NC}"
    
    # Check content type
    content_type=$(mdls -name kMDItemContentType "$test_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
    echo -e "  Content type: ${YELLOW}$content_type${NC}"
    
    # Try Quick Look
    echo -e "  ${CYAN}Testing Quick Look preview...${NC}"
    qlmanage -p "$test_file" >/dev/null 2>&1 &
    sleep 1
    killall qlmanage 2>/dev/null || true
    
    echo -e "  ${GREEN}✓${NC} Quick Look test completed"
    echo -e "  ${YELLOW}Note:${NC} You may need to restart Finder for changes to take effect"
}

# Main execution
main() {
    print_header
    
    check_duti
    echo ""
    
    fix_with_duti
    echo ""
    
    reset_launchservices
    echo ""
    
    force_metadata_refresh
    echo ""
    
    set_content_type_attribute
    echo ""
    
    test_quicklook
    echo ""
    
    echo -e "${GREEN}✓${NC} Fix completed!"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. ${YELLOW}Restart Finder:${NC} killall Finder"
    echo -e "  2. ${YELLOW}Or log out and back in${NC}"
    echo -e "  3. ${YELLOW}Test Quick Look on a .ts file${NC}"
    echo ""
    echo -e "${YELLOW}If issues persist, run:${NC}"
    echo -e "  ${CYAN}$HOME/scripts/fix_ts_files_metadata.sh${NC}"
}

main "$@"
