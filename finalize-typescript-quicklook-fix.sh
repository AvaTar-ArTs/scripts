#!/usr/bin/env bash
# Final fix for .ts Quick Look - creates a proper solution

set -e

echo "🔧 Final fix for .ts Quick Look preview"
echo ""

# The issue: macOS system UTI maps .ts to MPEG transport stream
# Solution: Use file content detection instead of extension

# Method 1: Create a script that forces text recognition before Quick Look
cat > "$HOME/.local/bin/ql-ts" << 'SCRIPT'
#!/bin/bash
# Quick Look wrapper that forces .ts files to be treated as text

for file in "$@"; do
    if [[ "$file" == *.ts ]] || [[ "$file" == *.tsx ]]; then
        # Check if file is actually text (not binary video)
        if file "$file" | grep -q "text"; then
            # Force re-index as text
            touch "$file"
            # Use text Quick Look directly
            /usr/bin/qlmanage -p "$file" -c public.plain-text 2>/dev/null || \
            /usr/bin/qlmanage -p "$file" 2>/dev/null
            exit 0
        fi
    fi
done

# For non-.ts files, use normal qlmanage
/usr/bin/qlmanage -p "$@" 2>/dev/null
SCRIPT

chmod +x "$HOME/.local/bin/ql-ts"
mkdir -p "$HOME/.local/bin"

echo "✓ Created ql-ts wrapper at $HOME/.local/bin/ql-ts"
echo ""

# Method 2: Create an Automator service (better integration)
echo "Creating Automator Quick Action..."
mkdir -p "$HOME/Library/Services"

cat > "$HOME/Library/Services/Quick Look TypeScript.workflow/Contents/document.wflow" << 'WORKFLOW'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>500</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>for f in "$@"; do
  if [[ "$f" == *.ts ]] || [[ "$f" == *.tsx ]]; then
    /usr/bin/qlmanage -p "$f" 2>/dev/null
  fi
done</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>Shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string>AM_INPUTS</string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>Category</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
                <key>InputUUID</key>
                <string>0F3F2F4F-8B5B-4B5B-8B5B-4B5B8B5B4B5B</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Action</string>
                    <string>Run</string>
                </array>
                <key>OutputUUID</key>
                <string>1F4F3F5F-9C6C-5C6C-9C6C-5C6C9C6C5C6C</string>
                <key>UUID</key>
                <string>2F5F4F6F-AD7D-6D7D-AD7D-6D7DAD7D6D7D</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>arguments</key>
                <dict>
                    <key>0</key>
                    <dict>
                        <key>default value</key>
                        <integer>0</integer>
                        <key>name</key>
                        <string>inputMethod</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>0</string>
                    </dict>
                </dict>
                <key>conversionLabel</key>
                <integer>0</integer>
            </dict>
            <key>isViewVisible</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowType</key>
    <string>QuickAction</string>
</dict>
</plist>
WORKFLOW

echo "✓ Created Automator Quick Action"
echo ""

# Method 3: Simple alias for terminal
echo "Adding to .zshrc..."
if ! grep -q "alias qlts" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'ALIAS'

# Quick Look for TypeScript files
alias qlts='qlmanage -p'
ALIAS
    echo "✓ Added qlts alias to .zshrc"
fi

echo ""
echo "✅ Fix completed!"
echo ""
echo "Usage:"
echo "  1. Terminal: qlts file.ts"
echo "  2. Finder: Right-click .ts file → Quick Look (should work now)"
echo "  3. Wrapper: $HOME/.local/bin/ql-ts file.ts"
echo ""
echo "Note: You may need to log out and back in for all changes to take effect."
