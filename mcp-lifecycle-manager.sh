#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MCP Server Lifecycle Manager
MCP_CONFIG_DIR="$HOME/.mcp-central/configs"
MCP_LOG_DIR="$HOME/.mcp-central/logs"
MCP_PID_DIR="/tmp/mcp-pids"

mkdir -p "$MCP_PID_DIR" "$MCP_LOG_DIR"

# Function to start MCP server with resource limits
start_mcp_server() {
    local server_name=$1
    local server_cmd=$2

    # Check if server is already running
    if [ -f "$MCP_PID_DIR/$server_name.pid" ]; then
        local existing_pid=$(cat "$MCP_PID_DIR/$server_name.pid")
        if kill -0 $existing_pid 2>/dev/null; then
            echo "$server_name is already running (PID: $existing_pid)"
            return 0
        else
            rm "$MCP_PID_DIR/$server_name.pid"
        fi
    fi

    echo "Starting $server_name..."

    # Apply resource limits and start server
    (
        # Set memory limit (512MB in KB)
        ulimit -v $((512 * 1024))

        # Start the server with timeout
        timeout 3600 $server_cmd > "$MCP_LOG_DIR/${server_name}.log" 2>&1 &  # 1 hour timeout
        local pid=$!
        echo $pid > "$MCP_PID_DIR/$server_name.pid"

        # Monitor the process for both memory and CPU usage
        while kill -0 $pid 2>/dev/null; do
            sleep 30

            # Check memory usage
            mem_usage=$(ps -p $pid -o rss= 2>/dev/null || echo 0)
            max_mem=$((512 * 1024))  # 512MB in KB

            if [ $mem_usage -gt $max_mem ]; then
                echo "WARNING: $server_name memory usage ($mem_usage KB) exceeds limit ($max_mem KB)"
                kill -TERM $pid
                sleep 5
                if kill -0 $pid 2>/dev/null; then
                    kill -KILL $pid 2>/dev/null
                fi
                break
            fi

            # Check CPU usage (if it's excessively high for a long time)
            cpu_usage=$(ps -p $pid -o %cpu= 2>/dev/null || echo 0)
            cpu_num=$(echo "$cpu_usage" | sed 's/%//')

            if [ -n "$cpu_num" ] && [ "$(echo "$cpu_num > 95" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
                echo "WARNING: $server_name CPU usage ($cpu_usage%) is excessively high"
                kill -TERM $pid
                sleep 5
                if kill -0 $pid 2>/dev/null; then
                    kill -KILL $pid 2>/dev/null
                fi
                break
            fi
        done

        # Clean up PID file
        rm -f "$MCP_PID_DIR/$server_name.pid"
    ) &
}

# Function to stop MCP server
stop_mcp_server() {
    local server_name=$1
    
    if [ -f "$MCP_PID_DIR/$server_name.pid" ]; then
        local pid=$(cat "$MCP_PID_DIR/$server_name.pid")
        if kill -0 $pid 2>/dev/null; then
            echo "Stopping $server_name (PID: $pid)..."
            kill -TERM $pid
            sleep 3
            if kill -0 $pid 2>/dev/null; then
                kill -KILL $pid 2>/dev/null
            fi
        fi
        rm -f "$MCP_PID_DIR/$server_name.pid"
    else
        echo "$server_name is not running"
    fi
}

# Function to restart MCP server
restart_mcp_server() {
    stop_mcp_server $1
    sleep 2
    start_mcp_server $1 $2
}

# Function to check MCP server status
check_mcp_status() {
    echo "MCP Server Status:"
    for pid_file in "$MCP_PID_DIR"/*.pid; do
        if [ -f "$pid_file" ]; then
            local server_name=$(basename "$pid_file" .pid)
            local pid=$(cat "$pid_file")
            if kill -0 $pid 2>/dev/null; then
                local uptime=$(ps -o etime= -p $pid)
                local mem=$(ps -o rss= -p $pid 2>/dev/null || echo 0)
                echo "✓ $server_name (PID: $pid, Uptime: $uptime, Memory: $((mem / 1024))MB)"
            else
                echo "✗ $server_name (PID file exists but process not running)"
                rm "$pid_file"
            fi
        fi
    done
}

case "${1:-status}" in
    start)
        start_mcp_server "$2" "$3"
        ;;
    stop)
        stop_mcp_server "$2"
        ;;
    restart)
        restart_mcp_server "$2" "$3"
        ;;
    status)
        check_mcp_status
        ;;
    cleanup)
        echo "Cleaning up MCP servers..."
        for pid_file in "$MCP_PID_DIR"/*.pid; do
            if [ -f "$pid_file" ]; then
                server_name=$(basename "$pid_file" .pid)
                stop_mcp_server "$server_name"
            fi
        done
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|cleanup} [server_name] [command]"
        exit 1
        ;;
esac
