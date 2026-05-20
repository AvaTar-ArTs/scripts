#!/usr/bin/env bash

set -euo pipefail

# Carbon Now CLI Automation Script
# This script processes all code files in a directory and generates beautiful Carbon images

# Configuration
INPUT_DIR="${INPUT_DIR:-/Users/steven}"
OUTPUT_DIR="${OUTPUT_DIR:-/Users/steven/Pictures/carbon-images}"
PRESET_NAME="${PRESET_NAME:-steven-preset}"
LOG_FILE="${LOG_FILE:-/Users/steven/carbon-automation.log}"
PRESET_FILE="${PRESET_FILE:-$HOME/.carbon-now.json}"
PROMPT_FOR_INPUT_DIR="${PROMPT_FOR_INPUT_DIR:-1}"
CARBON_SKIP_DISPLAY="${CARBON_SKIP_DISPLAY:-1}"

# Content filtering - only generate images for substantial code
MAX_LINES_FOR_IMAGE=${MAX_LINES_FOR_IMAGE:-800}
MIN_LINES_FOR_IMAGE=${MIN_LINES_FOR_IMAGE:-30}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TOTAL_IMAGES_GENERATED=0
CARBON_DISPLAY_ARGS=()
if [ "$CARBON_SKIP_DISPLAY" = "1" ]; then
    CARBON_DISPLAY_ARGS=(--skip-display)
fi

# Function to log messages
log_message() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo -e "$1" | tee -a "$LOG_FILE"
}

die() {
    log_message "${RED}Error: $1${NC}"
    exit 1
}

require_option_value() {
    local option="$1"
    local value="${2:-}"

    if [[ -z "$value" || "$value" == -* ]]; then
        die "$option requires a value"
    fi
}

prompt_for_input_dir() {
    if [ "$PROMPT_FOR_INPUT_DIR" != "1" ] || [ ! -t 0 ]; then
        return 0
    fi

    local entered_dir=""
    printf "Code source folder [%s]: " "$INPUT_DIR"
    read -r entered_dir

    if [ -n "$entered_dir" ]; then
        INPUT_DIR="${entered_dir/#\~/$HOME}"
    fi
}

# Function to check if carbon-now-cli is installed
check_carbon_cli() {
    if ! command -v carbon-now &> /dev/null; then
        die "carbon-now-cli is not installed. Please install it with: npm i -g carbon-now-cli"
    fi
    log_message "${GREEN}✓ carbon-now-cli is installed${NC}"
}

# Function to create preset configuration
create_preset() {
    log_message "${BLUE}Creating preset configuration...${NC}"

    mkdir -p "$(dirname "$PRESET_FILE")"

    python3 - "$PRESET_FILE" "$PRESET_NAME" <<'PY'
import json
import os
import sys

preset_file, preset_name = sys.argv[1:3]
preset = {
    "theme": "one-dark",
    "windowTheme": "none",
    "fontFamily": "Hack",
    "fontSize": "18px",
    "backgroundColor": "#ADB7C1",
    "windowControls": True,
    "widthAdjustment": True,
    "lineNumbers": True,
    "firstLineNumber": 1,
    "exportSize": "2x",
    "watermark": False,
}

data = {}
if os.path.exists(preset_file) and os.path.getsize(preset_file) > 0:
    with open(preset_file, "r", encoding="utf-8") as fh:
        data = json.load(fh)

data[preset_name] = preset

tmp_file = f"{preset_file}.tmp"
with open(tmp_file, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
os.replace(tmp_file, preset_file)
PY

    log_message "${GREEN}✓ Preset '$PRESET_NAME' created${NC}"
}

# Analyze file content to determine if it's worth creating a Carbon image
should_create_image() {
    local file="$1"
    
    python3 - "$file" "$MIN_LINES_FOR_IMAGE" "$MAX_LINES_FOR_IMAGE" <<'PY'
import re
import sys

file_path, min_lines_str, max_lines_str = sys.argv[1:4]
min_lines = int(min_lines_str)
max_lines = int(max_lines_str)

try:
    with open(file_path, "r", encoding="utf-8", errors="replace") as fh:
        content = fh.read()
        lines = content.split('\n')
except OSError as exc:
    print(f"SKIP: Unable to read file ({exc})")
    sys.exit(1)

total_lines = len([l for l in lines if l.strip()])

# Skip if too small or too large
if total_lines < min_lines:
    print(f"SKIP: Too small ({total_lines} lines)")
    sys.exit(1)
    
if total_lines > max_lines:
    print(f"SKIP: Too large ({total_lines} lines, would be unreadable)")
    sys.exit(1)

# Skip utility/menu/launcher scripts
skip_patterns = [
    (r'\becho\b.*\bselect\b', "Interactive menu script"),
    (r'case\s+\$\w+\s+in.*?(esac|\n\s*\))', "Menu case statement"),
    (r'(print_menu|show_menu|display_menu|main_menu)', "Menu function"),
    (r'while\s+(true|:).*?(read|select)', "Interactive loop"),
    (r'(PS3=|select\s+\w+\s+in)', "Bash select menu"),
    (r'echo\s+["\'].*?(1\)|2\)|3\)|\[1\]|\[2\])', "Numbered menu"),
    (r'(launch|launcher|starter|wrapper).*?(?:def main|if __name__)', "Launcher script"),
]

for pattern, reason in skip_patterns:
    if re.search(pattern, content, re.DOTALL | re.IGNORECASE):
        print(f"SKIP: {reason}")
        sys.exit(1)

# Skip if mostly echo/print statements (likely documentation or menu)
code_lines = [l for l in lines if l.strip() and not l.strip().startswith('#')]
output_lines = [l for l in code_lines if re.match(r'^\s*(echo|print|printf|cat\s+<<)', l, re.IGNORECASE)]

if code_lines and len(output_lines) / len(code_lines) > 0.4:
    print(f"SKIP: Mostly output statements ({len(output_lines)}/{len(code_lines)} lines)")
    sys.exit(1)

# Check for substantial algorithmic content
good_indicators = [
    r'\bclass\s+\w+',
    r'\bdef\s+\w+.*:',
    r'\basync\s+def\s+',
    r'import\s+(numpy|pandas|sklearn|torch|tensorflow)',
    r'\bfor\s+\w+\s+in\s+.*:',
    r'\bwhile\s+.*:',
    r'if.*elif.*else',
    r'^\s*function\s+\w+',
    r'^\s*\w+\(\)\s*\{',
    r'^\s*case\s+',
]

good_score = sum(1 for pattern in good_indicators if re.search(pattern, content))

if good_score >= 3:
    print(f"CREATE: Substantial code ({total_lines} lines, score: {good_score})")
    sys.exit(0)

# Default: create image for reasonable-sized files
print(f"CREATE: Standard code file ({total_lines} lines)")
sys.exit(0)
PY
}

# Process a single file and generate Carbon image if appropriate
process_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        log_message "${RED}✗ File not found: $file${NC}"
        return 1
    fi

    local filename
    filename=$(basename "$file")
    local name_without_ext="${filename%.*}"
    local output_file="$OUTPUT_DIR/$name_without_ext.png"

    if [ -f "$output_file" ] && [ "${OVERWRITE:-0}" != "1" ]; then
        log_message "${YELLOW}⊘ Skipped $filename - output already exists ($output_file). Set OVERWRITE=1 to regenerate.${NC}"
        return 0
    fi

    # Check if this file should get a Carbon image
    local analysis_result
    if analysis_result=$(should_create_image "$file" 2>&1); then
        log_message "${BLUE}✓ ${analysis_result}${NC}"
    else
        log_message "${YELLOW}⊘ Skipped $filename - ${analysis_result}${NC}"
        return 0
    fi

    log_message "${YELLOW}Processing: $filename${NC}"

    if carbon-now "$file" \
        --save-to "$OUTPUT_DIR" \
        --save-as "$name_without_ext" \
        --preset "$PRESET_NAME" \
        --type png \
        "${CARBON_DISPLAY_ARGS[@]}" \
        --quiet; then
        log_message "${GREEN}✓ Generated: $name_without_ext.png${NC}"
        ((TOTAL_IMAGES_GENERATED += 1))
        return 0
    else
        log_message "${RED}✗ Failed to process: $filename${NC}"
        return 1
    fi
}

# Process all files in the configured directory
process_directory() {
    local processed=0
    local failed=0
    
    log_message "${BLUE}Starting batch processing...${NC}"
    log_message "Input directory: $INPUT_DIR"
    log_message "Output directory: $OUTPUT_DIR"
    log_message "Preset: $PRESET_NAME"
    log_message "Filter policy: Skip utility/menu scripts, only process ${MIN_LINES_FOR_IMAGE}-${MAX_LINES_FOR_IMAGE} line files"
    log_message "----------------------------------------"
    
    if [ ! -d "$INPUT_DIR" ]; then
        die "Input directory '$INPUT_DIR' does not exist"
    fi
    
    mkdir -p "$OUTPUT_DIR"
    
    shopt -s nullglob
    local files=( "$INPUT_DIR"/* )
    shopt -u nullglob

    if [ "${#files[@]}" -eq 0 ]; then
        log_message "${YELLOW}No files found in $INPUT_DIR${NC}"
        return 0
    fi

    for file in "${files[@]}"; do
        if [ -d "$file" ]; then
            continue
        fi
        
        if [ ! -f "$file" ]; then
            continue
        fi
        
        if process_file "$file"; then
            ((processed += 1))
        else
            ((failed += 1))
        fi
    done
    
    log_message "----------------------------------------"
    log_message "${GREEN}Processing complete!${NC}"
    log_message "Files processed: $processed"
    log_message "Files failed: $failed"
    log_message "Output directory: $OUTPUT_DIR"
    log_message "Carbon images generated: $TOTAL_IMAGES_GENERATED"
}

# Process only specific file extensions
process_file_types() {
    local file_types="$1"
    local processed=0
    local failed=0

    file_types="${file_types//,/ }"

    log_message "${BLUE}Processing specific file types: $file_types${NC}"

    if [ ! -d "$INPUT_DIR" ]; then
        die "Input directory '$INPUT_DIR' does not exist"
    fi

    mkdir -p "$OUTPUT_DIR"

    shopt -s nullglob
    for ext in $file_types; do
        ext="${ext#.}"
        for file in "$INPUT_DIR"/*."$ext"; do
            if process_file "$file"; then
                ((processed += 1))
            else
                ((failed += 1))
            fi
        done
    done
    shopt -u nullglob
    
    log_message "----------------------------------------"
    log_message "${GREEN}Processing complete!${NC}"
    log_message "Files processed: $processed"
    log_message "Files failed: $failed"
    log_message "Carbon images generated: $TOTAL_IMAGES_GENERATED"
}

# Show usage information
show_usage() {
    echo "Carbon Now CLI Automation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -i, --input DIR         Input directory (default: $INPUT_DIR)"
    echo "  -o, --output DIR        Output directory (default: $OUTPUT_DIR)"
    echo "  -p, --preset NAME       Preset name (default: $PRESET_NAME)"
    echo "  -t, --types EXTENSIONS  Process specific file types (e.g., 'sh py js')"
    echo "  --setup                 Only setup preset configuration"
    echo "  --test                  Test with a single file"
    echo "  --force                 Regenerate images even when output files already exist"
    echo "  --no-prompt             Do not prompt for the code source folder"
    echo ""
    echo "The script intelligently filters which files get Carbon images:"
    echo "  - Skips utility scripts, menus, launchers, and wrappers"
    echo "  - Skips files with mostly echo/print statements"
    echo "  - Only processes files between ${MIN_LINES_FOR_IMAGE} and ${MAX_LINES_FOR_IMAGE} lines"
    echo "  - Prioritizes files with substantial algorithmic content"
    echo ""
    echo "Override via: MIN_LINES_FOR_IMAGE=50 MAX_LINES_FOR_IMAGE=1000 $0"
    echo "Disable folder prompt via: PROMPT_FOR_INPUT_DIR=0 $0"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Process all files in default directory"
    echo "  $0 -i /path/to/code -o /path/to/images  # Custom directories"
    echo "  $0 -t 'sh py js'                      # Process only shell, Python, and JS files"
    echo "  $0 --setup                           # Setup preset configuration only"
    echo "  $0 --test                            # Test with a sample file"
}

# Function to test the setup
test_setup() {
    log_message "${BLUE}Testing carbon-now-cli setup...${NC}"
    
    local test_file
    test_file=$(mktemp "${TMPDIR:-/tmp}/test_carbon.XXXXXX.sh")
    cat > "$test_file" << 'EOF'
#!/bin/bash
# Test script for Carbon Now CLI
echo "Hello, Carbon!"
echo "This is a test file for automation"
EOF
    
    if carbon-now "$test_file" \
        --save-to "$OUTPUT_DIR" \
        --save-as "test_carbon" \
        --preset "$PRESET_NAME" \
        --type png \
        "${CARBON_DISPLAY_ARGS[@]}" \
        --quiet; then
        log_message "${GREEN}✓ Test successful! Check $OUTPUT_DIR/test_carbon.png${NC}"
    else
        log_message "${RED}✗ Test failed${NC}"
    fi
    
    rm -f "$test_file"
}

# Main script logic
main() {
    TOTAL_IMAGES_GENERATED=0
    local file_types=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--input)
                require_option_value "$1" "${2:-}"
                INPUT_DIR="$2"
                shift 2
                ;;
            -o|--output)
                require_option_value "$1" "${2:-}"
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -p|--preset)
                require_option_value "$1" "${2:-}"
                PRESET_NAME="$2"
                shift 2
                ;;
            -t|--types)
                require_option_value "$1" "${2:-}"
                file_types="$2"
                shift 2
                ;;
            --force)
                OVERWRITE=1
                shift
                ;;
            --no-prompt)
                PROMPT_FOR_INPUT_DIR=0
                shift
                ;;
            --setup)
                check_carbon_cli
                create_preset
                log_message "${GREEN}Setup complete!${NC}"
                exit 0
                ;;
            --test)
                check_carbon_cli
                create_preset
                test_setup
                exit 0
                ;;
            *)
                log_message "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done

    prompt_for_input_dir
    check_carbon_cli
    create_preset
    if [ -n "$file_types" ]; then
        process_file_types "$file_types"
    else
        process_directory
    fi
}

main "$@"
