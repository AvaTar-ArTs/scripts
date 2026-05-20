#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Clipboard Auto-Update Scheduler
# Sets up automatic clipboard organization

SCRIPT_DIR="$HOME/Documents/paste_export"
UPDATE_SCRIPT="$SCRIPT_DIR/auto_update_clipboard.py"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/auto_update.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Function to run update
run_update() {
    echo "=== $(date) ===" >> "$LOG_FILE"
    python3 "$UPDATE_SCRIPT" >> "$LOG_FILE" 2>&1
    echo "" >> "$LOG_FILE"
}

# Check command
case "${1:-}" in
    "now")
        echo "Running update now..."
        run_update
        echo "✅ Update complete! Check log: $LOG_FILE"
        ;;

    "test")
        echo "🧪 Testing update script..."
        python3 "$UPDATE_SCRIPT"
        ;;

    "install")
        echo "📅 Installing daily update schedule..."

        # Create LaunchAgent plist
        PLIST_FILE="$HOME/Library/LaunchAgents/com.user.clipboard-updater.plist"

        cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.clipboard-updater</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>$UPDATE_SCRIPT</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>23</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>

    <key>StandardErrorPath</key>
    <string>$LOG_FILE</string>

    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

        # Load the agent
        launchctl unload "$PLIST_FILE" 2>/dev/null
        launchctl load "$PLIST_FILE"

        echo "✅ Installed! Will run daily at 11:30 PM"
        echo "📝 Logs: $LOG_FILE"
        echo ""
        echo "Commands:"
        echo "  ./schedule_updates.sh now    - Run update now"
        echo "  ./schedule_updates.sh logs   - View logs"
        echo "  ./schedule_updates.sh status - Check status"
        echo "  ./schedule_updates.sh remove - Uninstall"
        ;;

    "remove")
        echo "🗑️  Removing scheduled updates..."
        PLIST_FILE="$HOME/Library/LaunchAgents/com.user.clipboard-updater.plist"
        launchctl unload "$PLIST_FILE" 2>/dev/null
        rm -f "$PLIST_FILE"
        echo "✅ Removed!"
        ;;

    "status")
        PLIST_FILE="$HOME/Library/LaunchAgents/com.user.clipboard-updater.plist"
        if [ -f "$PLIST_FILE" ]; then
            echo "✅ Scheduled updates: INSTALLED"
            echo "📅 Runs daily at: 11:30 PM"
            echo "📝 Log file: $LOG_FILE"
            if [ -f "$LOG_FILE" ]; then
                echo ""
                echo "Last 5 runs:"
                grep "^===" "$LOG_FILE" | tail -5
            fi
        else
            echo "❌ Scheduled updates: NOT INSTALLED"
            echo ""
            echo "Install with: ./schedule_updates.sh install"
        fi
        ;;

    "logs")
        if [ -f "$LOG_FILE" ]; then
            tail -50 "$LOG_FILE"
        else
            echo "No logs yet. Run update first."
        fi
        ;;

    *)
        echo "Clipboard Auto-Update Scheduler"
        echo ""
        echo "Usage:"
        echo "  ./schedule_updates.sh now      - Run update immediately"
        echo "  ./schedule_updates.sh test     - Test update script"
        echo "  ./schedule_updates.sh install  - Schedule daily updates (11:30 PM)"
        echo "  ./schedule_updates.sh remove   - Remove scheduled updates"
        echo "  ./schedule_updates.sh status   - Check installation status"
        echo "  ./schedule_updates.sh logs     - View recent logs"
        echo ""
        ;;
esac
