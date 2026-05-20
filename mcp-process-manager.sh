#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MCP Process Manager - Handle runaway and problematic MCP processes

# Function to identify problematic MCP processes
identify_problematic_mcp() {
    echo "🔍 Identifying problematic MCP processes..."
    
    # Find MCP processes with high CPU usage (>80%)
    echo "Checking for high CPU MCP processes..."
    
    # Get all MCP processes
    mcp_processes=$(ps aux | grep -i mcp | grep -v grep)
    
    if [ -z "$mcp_processes" ]; then
        echo "No MCP processes found"
        return 0
    fi
    
    problematic_pids=()
    
    # Process each MCP line
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # Extract PID and CPU percentage
            pid=$(echo "$line" | awk '{print $2}')
            cpu_str=$(echo "$line" | awk '{print $3}')
            
            # Remove % if present and convert to number
            cpu_clean=$(echo "$cpu_str" | sed 's/%//')
            
            # Check if CPU is high (>80%)
            if [ -n "$cpu_clean" ] && [ "$(echo "$cpu_clean > 80" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
                echo "🚨 High CPU MCP process found: PID $pid (${cpu_str}% CPU)"
                problematic_pids+=("$pid")
            fi
        fi
    done <<< "$mcp_processes"
    
    echo "Found ${#problematic_pids[@]} potentially problematic MCP processes"
    for pid in "${problematic_pids[@]}"; do
        echo "$pid"
    done
}

# Function to safely terminate MCP processes
terminate_mcp_process() {
    local pid=$1
    local reason=$2
    
    echo "Attempting to terminate PID $pid ($reason)..."
    
    # First, try graceful termination
    kill -TERM $pid 2>/dev/null
    sleep 3
    
    # Check if process is still running
    if kill -0 $pid 2>/dev/null; then
        echo "Process $pid still running after SIGTERM, waiting..."
        sleep 10
    fi
    
    # Check again
    if kill -0 $pid 2>/dev/null; then
        echo "Forcefully terminating PID $pid..."
        kill -KILL $pid 2>/dev/null
        sleep 2
    fi
    
    # Verify termination
    if kill -0 $pid 2>/dev/null; then
        echo "❌ Failed to terminate PID $pid"
        return 1
    else
        echo "✅ Successfully terminated PID $pid"
        return 0
    fi
}

# Function to restart MCP services
restart_mcp_services() {
    echo "🔄 Restarting MCP services..."
    
    # Stop any existing MCP processes
    pkill -f "notebooklm-mcp" 2>/dev/null
    pkill -f "mcp" 2>/dev/null
    sleep 3
    
    # Clean up any remaining processes
    pkill -9 -f "notebooklm-mcp" 2>/dev/null
    sleep 2
    
    echo "MCP services restarted"
}

# Function to check MCP status
check_mcp_status() {
    echo "📊 Current MCP processes:"
    ps aux | grep -i mcp | grep -v grep | \
    awk '{print "PID: " $2 ", CPU: " $3 "%, MEM: " $4 "%, CMD: " substr($0, index($0, $11))}'
    
    if [ $? -eq 0 ]; then
        echo "✅ MCP status check completed"
    else
        echo "ℹ️  No MCP processes found"
    fi
}

# Main execution
case "${1:-status}" in
    identify)
        identify_problematic_mcp
        ;;
    terminate-high-cpu)
        pids_to_kill=($(identify_problematic_mcp))
        for pid in "${pids_to_kill[@]}"; do
            if [ -n "$pid" ] && [[ "$pid" =~ ^[0-9]+$ ]]; then
                terminate_mcp_process "$pid" "high CPU or long runtime"
            fi
        done
        ;;
    restart)
        restart_mcp_services
        ;;
    status)
        check_mcp_status
        ;;
    cleanup-all)
        echo "🧹 Cleaning up all MCP processes..."
        pkill -f "notebooklm-mcp" 2>/dev/null
        pkill -f "mcp" 2>/dev/null
        sleep 3
        pkill -9 -f "notebooklm-mcp" 2>/dev/null
        pkill -9 -f "mcp" 2>/dev/null
        echo "All MCP processes terminated"
        ;;
    *)
        echo "Usage: $0 {identify|terminate-high-cpu|restart|status|cleanup-all}"
        echo "  identify: Identify problematic MCP processes"
        echo "  terminate-high-cpu: Terminate high CPU MCP processes"
        echo "  restart: Restart MCP services"
        echo "  status: Check current MCP processes"
        echo "  cleanup-all: Terminate all MCP processes"
        ;;
esac
