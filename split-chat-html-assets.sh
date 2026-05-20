#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Paths
LARGE_HTML="/Users/steven/Downloads/json/chat.html"
OUTPUT_DIR="/Users/steven/Downloads/json/organized_chat"
CSS_FILE="$OUTPUT_DIR/assets/css/style.css"
JS_FILE="$OUTPUT_DIR/assets/js/script.js"

# Create directories
mkdir -p "$OUTPUT_DIR/assets/css"
mkdir -p "$OUTPUT_DIR/assets/js"
mkdir -p "$OUTPUT_DIR/partials"

# Extract header, footer, and content from the large HTML file
awk '/<header>/,/<\/header>/' "$LARGE_HTML" > "$OUTPUT_DIR/partials/header.html"
awk '/<footer>/,/<\/footer>/' "$LARGE_HTML" > "$OUTPUT_DIR/partials/footer.html"
awk '!/<header>/ && !/<footer>/' "$LARGE_HTML" > "$OUTPUT_DIR/index.html"

# Copy over CSS and JS files if they exist (replace with real paths)
cp "/path/to/style.css" "$CSS_FILE"
cp "/path/to/script.js" "$JS_FILE"

# Minify CSS and JS
cssnano "$CSS_FILE" "$OUTPUT_DIR/assets/css/style.min.css"
uglifyjs "$JS_FILE" -o "$OUTPUT_DIR/assets/js/script.min.js"

echo "Files organized and minified!"
