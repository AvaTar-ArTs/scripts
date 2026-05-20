#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# 1. Install all packages using pip
echo "🚀 Installing packages..."
pip install black flake8 isort pylint radon python-dotenv mypy pdoc

# 2. Verify installations
echo "🔍 Verifying installations..."
echo "Black version: $(black --version)"          # Code formatter
echo "Flake8 version: $(flake8 --version)"        # Linter
echo "Isort version: $(isort --version)"          # Import sorter
echo "Pylint version: $(pylint --version)"        # Code analysis
echo "Radon version: $(radon --version)"          # Complexity metrics
echo "Dotenv version: $(python -c 'import dotenv; print(dotenv.__version__)')"  # Environment variables
echo "Mypy version: $(mypy --version)"            # Static typing
echo "Pdoc version: $(pdoc --version)"            # Documentation generator

# 3. Create a test script to validate functionality
echo "📝 Creating test script..."
cat << EOF > test_script.py
import os
from typing import Optional

def greet(name: Optional[str] = None) -> str:
    """
    Greet someone with proper type hints
    """
    return f"Hello, {name or 'World'}!"

if __name__ == "__main__":
    print(greet())
EOF

# 4. Run validation checks
echo "🔧 Running validation checks..."
black_output=$(black test_script.py)
echo "Black formatting: $black_output"
isort_output=$(isort test_script.py)
echo "Isort import sorting: $isort_output"
flake8_output=$(flake8 test_script.py)
echo "Flake8 style check: $flake8_output"
pylint_output=$(pylint test_script.py)
echo "Pylint analysis: $pylint_output"
mypy_output=$(mypy test_script.py)
echo "Mypy type check: $mypy_output"
radon_output=$(radon cc test_script.py)
echo "Radon complexity: $radon_output"
pdoc_output=$(pdoc --html test_script.py)
echo "Pdoc documentation: $pdoc_output"
python_output=$(python test_script.py)
echo "Script execution: $python_output"

# 5. Cleanup test files
echo "🧹 Cleaning up test files..."
rm test_script.py
rm -rf html/

echo "✅ All tasks completed successfully!"
