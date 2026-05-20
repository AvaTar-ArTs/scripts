#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# AI Tool Resource Manager
MAX_MEMORY_PER_TOOL=4096  # MB per tool
MAX_CPU_PER_TOOL=80       # Percentage per tool
MAX_CONCURRENT_TOOLS=3    # Maximum simultaneous tools

# Function to monitor and limit resources
limit_tool_resources() {
    local tool_name=$1
    local pid=$2

    # Set up cgroup for memory limits (Linux/macOS)
    if command -v cgcreate &>/dev/null; then
        sudo cgcreate -g memory:/ai_tools
        echo $((MAX_MEMORY_PER_TOOL * 1024 * 1024)) | sudo tee /sys/fs/cgroup/memory/ai_tools/memory.limit_in_bytes
        echo $pid | sudo tee /sys/fs/cgroup/memory/ai_tools/cgroup.procs
    fi

    # Monitor CPU usage and terminate if excessive
    while kill -0 $pid 2>/dev/null; do
        cpu_usage=$(ps -p $pid -o %cpu --no-headers | awk '{print $1}')
        if (( $(echo "$cpu_usage > $MAX_CPU_PER_TOOL" | bc -l) )); then
            echo "WARNING: $tool_name CPU usage ($cpu_usage%) exceeds limit ($MAX_CPU_PER_TOOL%)"
            # If CPU usage is extremely high for a sustained period, terminate the process
            if (( $(echo "$cpu_usage > 95" | bc -l) )); then
                echo "CRITICAL: Terminating $tool_name due to excessive CPU usage ($cpu_usage%)"
                kill -TERM $pid
                sleep 3
                if kill -0 $pid 2>/dev/null; then
                    kill -KILL $pid 2>/dev/null
                fi
                break
            fi
        fi
        sleep 5
    done
}

# Function to check system resources before launching tools
check_system_resources() {
    local required_memory=$1  # MB
    
    # Check available memory
    available_memory=$(($(vm_stat | awk '/free/ { print $3 }' | sed 's/\.//') * 4 / 1024))
    available_cpu=$(100 - $(top -l 1 | awk '/CPU usage/ { print $7 }' | sed 's/%//'))
    
    if [ $available_memory -lt $required_memory ]; then
        echo "ERROR: Insufficient memory. Available: ${available_memory}MB, Required: ${required_memory}MB"
        return 1
    fi
    
    if [ $available_cpu -lt 20 ]; then
        echo "ERROR: Insufficient CPU resources. Available: ${available_cpu}%"
        return 1
    fi
    
    return 0
}

# Function to manage tool lifecycle
manage_tool_launch() {
    local tool_cmd=$1
    local tool_name=$2
    local memory_req=$3  # MB
    
    if ! check_system_resources $memory_req; then
        return 1
    fi
    
    echo "Launching $tool_name with resource limits..."
    $tool_cmd &
    local pid=$!
    
    # Apply resource limits
    limit_tool_resources $tool_name $pid &
    
    # Add to active tools tracking
    echo "$tool_name:$pid" >> /tmp/active_ai_tools
    
    # Set timeout for the process
    (
        sleep 3600  # 1 hour timeout
        if kill -0 $pid 2>/dev/null; then
            echo "Timeout reached for $tool_name, terminating..."
            kill -TERM $pid
            sleep 5
            kill -KILL $pid 2>/dev/null
        fi
    ) &
    local timeout_pid=$!
    
    # Wait for process to complete
    wait $pid
    local exit_code=$?
    
    # Clean up timeout process
    kill $timeout_pid 2>/dev/null
    
    # Remove from active tools tracking
    sed -i.bak "/$tool_name:$pid/d" /tmp/active_ai_tools
    
    return $exit_code
}

case "${1:-status}" in
    launch)
        manage_tool_launch "$2" "$3" "${4:-1024}"
        ;;
    status)
        echo "Active AI tools:"
        if [ -f /tmp/active_ai_tools ]; then
            cat /tmp/active_ai_tools
        else
            echo "None"
        fi
        ;;
    cleanup)
        echo "Cleaning up AI tools..."
        if [ -f /tmp/active_ai_tools ]; then
            while IFS=: read -r name pid; do
                if kill -0 $pid 2>/dev/null; then
                    echo "Terminating $name (PID: $pid)"
                    kill -TERM $pid
                    sleep 2
                    kill -KILL $pid 2>/dev/null
                fi
            done < /tmp/active_ai_tools
            rm /tmp/active_ai_tools
        fi
        ;;
    *)
        echo "Usage: $0 {launch 'command' 'name' [memory_mb]|status|cleanup}"
        exit 1
        ;;
esac
