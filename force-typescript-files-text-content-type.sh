#!/usr/bin/env bash
# Force .ts files to be recognized as text files for Quick Look
# This script uses xattr and mdimport to override the default MPEG transport stream association

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔧 Fixing .ts file content type recognition...${NC}"
echo ""

# Method 1: Use xattr to set a text content type hint
fix_file() {
    local file="$1"
    
    # Remove any quarantine attribute
    xattr -d com.apple.quarantine "$file" 2>/dev/null || true
    
    # Set content type to plain text
    xattr -w com.apple.metadata:kMDItemContentType "public.plain-text" "$file" 2>/dev/null || true
    
    # Force re-indexing
    mdimport -i "$file" 2>/dev/null || true
    
    # Touch to update modification time
    touch "$file"
}

# Method 2: Create a wrapper that forces text recognition
create_text_wrapper() {
    cat > "$HOME/.local/bin/qlmanage-ts" << 'EOF'
#!/bin/bash
# Wrapper for qlmanage that forces .ts files to be treated as text

for file in "$@"; do
    if [[ "$file" == *.ts ]] || [[ "$file" == *.tsx ]]; then
        # Force content type to text
        xattr -w com.apple.metadata:kMDItemContentType "public.plain-text" "$file" 2>/dev/null || true
        mdimport -i "$file" 2>/dev/null || true
    fi
done

# Use system qlmanage
/usr/bin/qlmanage "$@"
EOF
    
    chmod +x "$HOME/.local/bin/qlmanage-ts"
    mkdir -p "$HOME/.local/bin"
    echo -e "${GREEN}✓${NC} Created qlmanage wrapper at ${CYAN}$HOME/.local/bin/qlmanage-ts${NC}"
}

# Method 3: Use duti to set default handler and force text recognition
fix_with_duti() {
    echo -e "${BLUE}Setting file associations...${NC}"
    
    if command -v duti >/dev/null 2>&1; then
        DUTI_CMD="duti"
    elif [ -f "/usr/local/bin/duti" ]; then
        DUTI_CMD="/usr/local/bin/duti"
    else
        echo -e "${YELLOW}duti not found, skipping...${NC}"
        return
    fi
    
    # Set .ts to TextEdit
    $DUTI_CMD -s com.apple.TextEdit .ts all 2>&1 || true
    $DUTI_CMD -s com.apple.TextEdit .tsx all 2>&1 || true
    
    echo -e "${GREEN}✓${NC} File associations set"
}

# Main
echo -e "${CYAN}Applying fixes...${NC}"
echo ""

fix_with_duti
echo ""

create_text_wrapper
echo ""

# Test with a sample file
test_file="/tmp/test_typescript_preview.ts"
cat > "$test_file" << 'EOF'
// TypeScript test file
interface Test {
    value: string;
}
EOF

echo -e "${BLUE}Testing with sample file...${NC}"
fix_file "$test_file"

content_type=$(mdls -name kMDItemContentType "$test_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
echo -e "Content type: ${YELLOW}$content_type${NC}"

if [[ "$content_type" == *"text"* ]] || [[ "$content_type" == *"source"* ]]; then
    echo -e "${GREEN}✓${NC} File recognized as text!"
else
    echo -e "${YELLOW}⚠${NC}  File still shows as: $content_type"
    echo -e "${YELLOW}Note:${NC} You may need to restart Finder or log out/in"
fi

echo ""
echo -e "${GREEN}✓${NC} Fix script completed!"
echo ""
echo -e "${CYAN}To use the wrapper:${NC}"
echo -e "  ${YELLOW}$HOME/.local/bin/qlmanage-ts /path/to/file.ts${NC}"
echo ""
echo -e "${CYAN}Or restart Finder:${NC}"
echo -e "  ${YELLOW}killall Finder${NC}"
