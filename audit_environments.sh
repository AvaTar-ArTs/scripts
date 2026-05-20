#!/bin/bash
# audit_environments.sh
# Inventories installed Python (pip) and Node.js (npm) packages and their locations.

OUTPUT_FILE="$HOME/scripts/ENVIRONMENT_AUDIT.csv"

echo "filename,package_manager,package_name,location,version" > "$OUTPUT_FILE"

echo "Auditing Python packages (pip)..."
# Find all pip installed packages (this might take a moment)
pip list --format=freeze 2>/dev/null | while IFS='=' read -r name version; do
    # Try to find the location
    location=$(pip show "$name" 2>/dev/null | grep "Location:" | cut -d' ' -f2-)
    echo "$name,pip,$name,$location,$version" >> "$OUTPUT_FILE"
done

echo "Auditing Node.js packages (npm global)..."
# Find global npm packages
npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | to_entries[] | [.key, "npm", .key, "global", .value.version] | @csv' >> "$OUTPUT_FILE"

echo "Audit complete. Results saved to $OUTPUT_FILE"
