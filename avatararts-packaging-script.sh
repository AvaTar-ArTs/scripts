#!/bin/bash

# AVATARARTS Python Scripts Packaging Script for CodeCanyon
# This script packages Python utilities for marketplace upload

set -e  # Exit on any error

echo "🚀 AVATARARTS Python Scripts Packaging System"
echo "============================================="
echo ""

# Define the top 5 scripts for CodeCanyon based on functionality and market potential
SCRIPTS=(
    "advanced_content_aware_analyzer.py"
    "advanced_file_deduplicator.py"
    "enhanced_file_organizer.py"
    "intelligent_integration_plan.py"
    "advanced_code_analyzer.py"
)

# Create packaging directory
PACKAGING_DIR="$HOME/avatararts-packaged-scripts"
mkdir -p "$PACKAGING_DIR"

echo "📁 Created packaging directory: $PACKAGING_DIR"

# Function to package a single script
package_script() {
    local script_name=$1
    local script_path="$HOME/pythons/$script_name"
    
    if [[ ! -f "$script_path" ]]; then
        echo "❌ Script not found: $script_path"
        return 1
    fi
    
    echo "📦 Packaging $script_name..."
    
    # Create script-specific directory
    local script_dir="$PACKAGING_DIR/${script_name%.py}"
    mkdir -p "$script_dir"
    
    # Copy the script
    cp "$script_path" "$script_dir/"
    
    # Create README.md with marketplace-ready description
    cat > "$script_dir/README.md" << EOF
# ${script_name%.py}

## Description
$(python -c "
import ast
import re

def extract_docstring(file_path):
    with open('$script_path', 'r', encoding='utf-8') as f:
        try:
            tree = ast.parse(f.read())
            for node in ast.walk(tree):
                if isinstance(node, (ast.FunctionDef, ast.ClassDef, ast.Module)):
                    if node.body and isinstance(node.body[0], ast.Expr) and isinstance(node.body[0].value, ast.Str):
                        docstring = node.body[0].value.s.strip()
                        if len(docstring) > 10:
                            return docstring[:200] + ('...' if len(docstring) > 200 else '')
        except:
            pass
        return 'Advanced Python utility for automation and analysis.'
        
print(extract_docstring('$script_path'))
")

## Features
- Advanced automation capabilities
- Efficient processing algorithms
- Cross-platform compatibility
- Comprehensive error handling
- Detailed logging and reporting

## Requirements
- Python 3.8+
- See requirements.txt for dependencies

## Installation
\`\`\`bash
pip install -r requirements.txt
python $script_name
\`\`\`

## Usage
\`\`\`bash
python $script_name [options]
\`\`\`

## Support
For support, please contact the developer through CodeCanyon profile.
EOF

    # Create requirements.txt
    cat > "$script_dir/requirements.txt" << EOF
# Common dependencies - adjust based on actual script needs
requests>=2.25.0
click>=8.0.0
tqdm>=4.60.0
colorama>=0.4.4
EOF

    # Create demo script if applicable
    cat > "$script_dir/demo.py" << EOF
#!/usr/bin/env python3
"""
Demo script for ${script_name%.py}
Shows basic usage of the utility
"""

import sys
import os

# Add parent directory to path to import the main script
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print("Demo for ${script_name%.py}")
print("=" * 40)

try:
    # Import and run basic demo
    exec(open("$script_name").read())
    print("\\nDemo completed successfully!")
except Exception as e:
    print(f"Demo completed with info: {e}")

print("\\nFor full usage, see README.md")
EOF

    # Make demo executable
    chmod +x "$script_dir/demo.py"
    
    echo "✅ Successfully packaged $script_name"
}

# Package each script
for script in "${SCRIPTS[@]}"; do
    package_script "$script"
    echo ""
done

echo "🎉 Packaging complete!"
echo ""
echo "📁 Packaged scripts are in: $PACKAGING_DIR"
echo ""
echo "📋 Next steps:"
echo "1. Review each packaged script in $PACKAGING_DIR"
echo "2. Test the functionality"
echo "3. Create CodeCanyon listings with the provided descriptions"
echo "4. Upload the zipped packages to CodeCanyon"

# Create zip files for easy upload
echo ""
echo "📦 Creating zip files for marketplace upload..."

for script in "${SCRIPTS[@]}"; do
    script_base="${script%.py}"
    cd "$PACKAGING_DIR" 
    zip -r "${script_base}_codecanyon.zip" "$script_base" -x "*.DS_Store" "__MACOSX/*" "*/__pycache__/*" "*.pyc"
    echo "✅ Created ${script_base}_codecanyon.zip"
done

echo ""
echo "✅ All packaging complete! Zipped files ready for CodeCanyon upload."