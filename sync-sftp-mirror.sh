#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Configuration via environment variables with fallbacks
SFTP_HOST=${SFTP_HOST:-"access981577610.webspace-data.io"}
SFTP_USER=${SFTP_USER:-"u114071855"}
SFTP_LOCAL_DIR=${SFTP_LOCAL_DIR:-"/Volumes/2T-Xx/AvaTarArTs"}
SFTP_REMOTE_DIR=${SFTP_REMOTE_DIR:-"/"}

# Check for SFTP password environment variable
if [ -z "$SFTP_PASSWORD" ]; then
    echo "Error: SFTP_PASSWORD environment variable is not set."
    echo "Please set it before running the script (e.g., export SFTP_PASSWORD='your_password')."
    exit 1
fi

echo "Starting SFTP synchronization with lftp..."
echo "Host: $SFTP_HOST"
echo "User: $SFTP_USER"
echo "Local Directory: $SFTP_LOCAL_DIR"
echo "Remote Directory: $SFTP_REMOTE_DIR"

# Execute lftp with password from environment variable
lftp -u "$SFTP_USER","$SFTP_PASSWORD" sftp://$SFTP_HOST <<EOF
set ssl:verify-certificate no
mirror --reverse --delete --verbose "$SFTP_LOCAL_DIR" "$SFTP_REMOTE_DIR"
quit
EOF

if [ $? -eq 0 ]; then
    echo "SFTP synchronization completed successfully."
else
    echo "SFTP synchronization failed."
fi
