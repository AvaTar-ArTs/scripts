#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MCP & AI Tool Watchdog - Prevents resource sinks and hanging processes
WATCHDOG_LOG="/tmp/ai-watchdog.log"
MAX_CPU_THRESHOLD=90
MAX_RUNTIME_HOURS=2
CHECK_INTERVAL=60  # seconds

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$WATCHDOG_LOG"
}

# Function to check for problematic processes
check_problematic_processes() {
    log_message "Checking for problematic AI/MCP processes..."
    
    # Check for high CPU processes
    ps aux | grep -i -E "(cursor|claude|qwen|gemini|grok|notebooklm|mcp)" | grep -v grep | while read -r line; do
        pid=$(echo "$line" | awk '{print $2}')
        cpu=$(echo "$line" | awk '{print $3}')
        cmd=$(echo "$line" | cut -d' ' -f11-)
        
        # Skip the watchdog process itself
        if [[ "$cmd" == *"$0"* ]]; then
            continue
        fi
        
        # Check if CPU usage is too high
        if [ -n "$cpu" ] && [ "$(echo "$cpu > $MAX_CPU_THRESHOLD" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
            log_message "HIGH CPU PROCESS DETECTED: PID $pid (${cpu}% CPU) - Command: $cmd"
            
            # Get runtime
            runtime_seconds=$(ps -o etimes= -p $pid 2>/dev/null)
            if [ -n "$runtime_seconds" ]; then
                runtime_hours=$((runtime_seconds / 3600))
                log_message "Process has been running for $runtime_hours hours"
                
                if [ $runtime_hours -gt $MAX_RUNTIME_HOURS ]; then
                    log_message "Terminating high CPU, long-running process: PID $pid"
                    
                    # Attempt graceful termination
                    kill -TERM $pid 2>/dev/null
                    sleep 5
                    
                    # Check if process is still running
                    if kill -0 $pid 2>/dev/null; then
                        log_message "Process $pid still running after SIGTERM, waiting..."
                        sleep 10
                        
                        # Force kill if still running
                        if kill -0 $pid 2>/dev/null; then
                            log_message "Force killing process: PID $pid"
                            kill -KILL $pid 2>/dev/null
                        fi
                    fi
                fi
            fi
        fi
    done
}

# Function to monitor system resources
monitor_system_resources() {
    # Get system-wide metrics
    cpu_usage=$(top -l 1 | awk '/CPU usage/ { print $7 }' | sed 's/%//' | cut -d. -f1)
    mem_usage=$(python3 -c "
import psutil
total = psutil.virtual_memory().total
available = psutil.virtual_memory().available
used_percent = (total - available) / total * 100
print(int(used_percent))
" 2>/dev/null || echo 0)

    log_message "System resources - CPU: ${cpu_usage}%, Memory: ${mem_usage}%"
    
    # If system resources are critically high, check for specific culprits
    if [ $cpu_usage -gt 90 ] || [ $mem_usage -gt 90 ]; then
        log_message "CRITICAL SYSTEM RESOURCE USAGE DETECTED"
        ps aux | grep -i -E "(cursor|claude|qwen|gemini|grok|notebooklm|mcp)" | grep -v grep | sort -nrk3 | head -5 | while read -r line; do
            log_message "TOP RESOURCE CONSUMER: $line"
        done
    fi
}

# Main watchdog loop
log_message "AI/MCP Watchdog started"

case "${1:-run}" in
    run)
        # Run in continuous mode
        log_message "Starting continuous monitoring..."
        while true; do
            check_problematic_processes
            monitor_system_resources
            sleep $CHECK_INTERVAL
        done
        ;;
    once)
        # Run once and exit
        check_problematic_processes
        monitor_system_resources
        ;;
    status)
        # Show status
        echo "AI/MCP Watchdog Status:"
        echo "Log file: $WATCHDOG_LOG"
        echo "Current AI/MCP processes:"
        ps aux | grep -i -E "(cursor|claude|qwen|gemini|grok|notebooklm|mcp)" | grep -v grep
        echo "Recent watchdog logs:"
        tail -20 "$WATCHDOG_LOG" 2>/dev/null || echo "No logs yet"
        ;;
    *)
        echo "Usage: $0 {run|once|status}"
        echo "  run:    Start continuous monitoring"
        echo "  once:   Run one check cycle"
        echo "  status: Show current status"
        ;;
esac
