#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail

# Initialize conda
eval "$(conda shell.bash hook)"

# Activate environment
conda activate suno-analytics || {
    echo "Failed to activate suno-analytics environment"
    exit 1
}

# Set project directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTEBOOKS_DIR="${PROJECT_ROOT}/notebooks"
LOGS_DIR="${PROJECT_ROOT}/logs"
DATA_DIR="${PROJECT_ROOT}/data"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

# Initialize PYTHONPATH safely
export PYTHONPATH="${PYTHONPATH:-}:${SCRIPTS_DIR}"

# Create required directories
mkdir -p "${NOTEBOOKS_DIR}" "${LOGS_DIR}" "${DATA_DIR}" "${SCRIPTS_DIR}"

# Generate default Jupyter config if missing
JUPYTER_CONFIG_DIR="${PROJECT_ROOT}/.jupyter"
mkdir -p "${JUPYTER_CONFIG_DIR}"

if [ ! -f "${JUPYTER_CONFIG_DIR}/jupyter_server_config.py" ]; then
    jupyter server --generate-config
fi

# Verify port availability
PORT=8888
if lsof -Pi :${PORT} -sTCP:LISTEN -t >/dev/null ; then
    echo "Port ${PORT} is already in use"
    exit 1
fi

# Start Jupyter Lab
echo "Starting Jupyter Lab..."
echo "Project Root: ${PROJECT_ROOT}"
echo "Notebooks Directory: ${NOTEBOOKS_DIR}"
echo "Logs Directory: ${LOGS_DIR}"
echo "Python Path: ${PYTHONPATH}"

jupyter lab \
    --notebook-dir="${NOTEBOOKS_DIR}" \
    --no-browser \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --ServerApp.ip='0.0.0.0' \
    --ServerApp.port=${PORT} \
    >> "${LOGS_DIR}/jupyter.log" 2>&1 &

# Get process ID
JUPYTER_PID=$!

# Wait for server to start
sleep 2

# Verify server is running
if ! ps -p ${JUPYTER_PID} > /dev/null; then
    echo "Failed to start Jupyter Lab"
    exit 1
fi

# Open browser (macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    open "http://localhost:${PORT}/lab"
fi

echo "Jupyter Lab started successfully!"
echo "Process ID: ${JUPYTER_PID}"
echo "Access at: http://localhost:${PORT}/lab"

# Cleanup function
cleanup() {
    echo "Stopping Jupyter Lab..."
    kill ${JUPYTER_PID} 2>/dev/null || true
    echo "Cleanup complete"
}

# Trap exit signals
trap cleanup EXIT

# Keep script running
wait ${JUPYTER_PID}
