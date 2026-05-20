#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Test Quick Look for .ts files

TEST_FILE="/tmp/test_typescript_quicklook.ts"

cat > "$TEST_FILE" << 'EOF'
// TypeScript test file for Quick Look
interface User {
    name: string;
    age: number;
    email: string;
}

const user: User = {
    name: "John Doe",
    age: 30,
    email: "john@example.com"
};

export default user;
EOF

echo "Created test file: $TEST_FILE"
echo ""
echo "Testing Quick Look preview..."
qlmanage -p "$TEST_FILE" 2>&1

echo ""
echo "Content type:"
mdls -name kMDItemContentType "$TEST_FILE" 2>&1

echo ""
echo "File association:"
duti -x ts 2>&1 || /usr/local/bin/duti -x ts 2>&1
