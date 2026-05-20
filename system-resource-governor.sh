#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# System Resource Governor for AI Tools
RESOURCE_LOG="/tmp/ai_resource_monitor.log"
ALERT_THRESHOLD_CPU=85
ALERT_THRESHOLD_MEM=85

# Function to check system resources
check_system_resources() {
    local cpu_usage=$(top -l 1 | awk '/CPU usage/ { print $7 }' | sed 's/%//' | cut -d. -f1)
    local mem_usage=$(python3 -c "
import psutil
total = psutil.virtual_memory().total
available = psutil.virtual_memory().available
used_percent = (total - available) / total * 100
print(int(used_percent))
" 2>/dev/null || echo 0)

    echo "$(date): CPU: ${cpu_usage}%, Memory: ${mem_usage}%" >> "$RESOURCE_LOG"

    # Alert if thresholds exceeded
    if [ $cpu_usage -gt $ALERT_THRESHOLD_CPU ] || [ $mem_usage -gt $ALERT_THRESHOLD_MEM ]; then
        echo "ALERT: High resource usage detected!" >> "$RESOURCE_LOG"
        echo "CPU: ${cpu_usage}%, Memory: ${mem_usage}%"
        
        # Show top resource consumers
        echo "Top AI processes:"
        ps aux | grep -E "(cursor|claude|qwen|gemini)" | grep -v grep | sort -nrk4 | head -5
    fi
}

# Function to auto-throttle AI tools under high load
throttle_ai_tools() {
    local cpu_usage=$(top -l 1 | awk '/CPU usage/ { print $7 }' | sed 's/%//' | cut -d. -f1)
    
    if [ $cpu_usage -gt 80 ]; then
        echo "High CPU usage detected, throttling AI tools..."
        
        # Reduce MCP server concurrency
        pkill -USR1 mcp-server 2>/dev/null || true
        
        # Pause non-critical AI processes
        for pid in $(pgrep -f "cursor\|claude" | head -2); do
            echo "Pausing process $pid due to high CPU usage"
            kill -STOP $pid 2>/dev/null || true
            sleep 2
            kill -CONT $pid 2>/dev/null || true
        done
    fi
}

# Main monitoring loop
while true; do
    check_system_resources
    throttle_ai_tools
    sleep 30
done
