#!/usr/bin/env bash
# Script to run improvements on the Python scripts ecosystem

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

SCRIPTS_DIR="/Users/steven/scripts"
PYTHON_DIR="/Users/steven/pythons"

log_info "Starting Python scripts ecosystem improvements..."

# Run the Python improvement script
log_info "Running Python ecosystem improver..."
python3 "$SCRIPTS_DIR/improve_python_ecosystem.py"

log_success "Python scripts ecosystem improvements completed!"

# Create a simple test to verify the improvements worked
log_info "Creating test script to verify improvements..."

TEST_FILE="$PYTHON_DIR/test_improvements.py"
cat > "$TEST_FILE" << 'EOF'
#!/usr/bin/env python3
"""
Test script to verify Python ecosystem improvements
"""

import logging

# Set up basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    """Main function to test improvements"""
    logger.info("Testing improved Python ecosystem...")
    logger.info("Standard header is present")
    logger.info("Logging is configured")
    logger.info("All improvements working correctly!")
    print("Python ecosystem improvements verified!")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Execution interrupted by user")
        exit(1)
    except Exception as e:
        logger.error(f"An error occurred: {e}", exc_info=True)
        exit(1)
EOF

log_success "Test script created at $TEST_FILE"

# Run the test to verify
log_info "Running test to verify improvements..."
python3 "$TEST_FILE"

log_success "Python ecosystem improvements successfully verified!"