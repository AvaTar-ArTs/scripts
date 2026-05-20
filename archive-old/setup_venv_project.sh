#!/usr/bin/env bash

# Python venv Project Setup Script
# Creates a new Python project with venv (your preferred approach)

set -e

if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 <project-name> [python-version]"
    echo "Example: $0 my-project        # Uses python3 (3.12)"
    echo "Example: $0 my-project 3.11   # Uses python3.11"
    echo ""
    echo "Creates a new Python project with venv virtual environment."
    exit 1
fi

PROJECT_NAME="$1"
PYTHON_VERSION="${2:-3.12}"
PROJECT_DIR="$HOME/$PROJECT_NAME"

echo "🚀 Setting up venv project: $PROJECT_NAME (Python $PYTHON_VERSION)"
echo "================================================================="

# Check if Python version is available
if ! command -v "python$PYTHON_VERSION" &> /dev/null; then
    echo "❌ Python $PYTHON_VERSION is not available"
    echo "Available versions:"
    command -v python3.12 &> /dev/null && echo "  • python3.12"
    command -v python3.11 &> /dev/null && echo "  • python3.11"
    exit 1
fi

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "❌ Directory $PROJECT_DIR already exists!"
    exit 1
fi

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create virtual environment
echo "🐍 Creating virtual environment with Python $PYTHON_VERSION..."
"python$PYTHON_VERSION" -m venv .venv

# Activate and upgrade pip
echo "📦 Upgrading pip in virtual environment..."
source .venv/bin/activate
pip install --upgrade pip

# Install common development dependencies
echo "📚 Installing development dependencies..."
pip install pytest black isort flake8 mypy

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.venv/
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

# Create example script
cat > main.py << EOF
#!/usr/bin/env python3
"""
Example script for $PROJECT_NAME
"""

def main():
    print(f"Hello from {__name__}!")
    print("This is a venv-managed project.")

if __name__ == "__main__":
    main()
EOF

# Create requirements.txt template
cat > requirements.txt << 'EOF'
# Runtime dependencies
# requests>=2.31.0
# pandas>=2.0.0

# Development dependencies (installed above)
# pytest>=7.0.0
# black>=23.0.0
# isort>=5.12.0
# flake8>=6.0.0
# mypy>=1.5.0
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

A Python project using venv virtual environment.

## Setup

\`\`\`bash
# Create virtual environment (already done)
python3.12 -m venv .venv

# Activate environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
\`\`\`

## Development

Run the project:
\`\`\`bash
source .venv/bin/activate
python main.py
\`\`\`

Run tests:
\`\`\`bash
source .venv/bin/activate
pytest
\`\`\`

Format code:
\`\`\`bash
source .venv/bin/activate
black .
isort .
\`\`\`

## Adding Dependencies

\`\`\`bash
source .venv/bin/activate
pip install package-name
pip freeze > requirements.txt  # Update requirements
\`\`\`
EOF

# Deactivate virtual environment
deactivate

echo "✅ venv project '$PROJECT_NAME' created successfully!"
echo ""
echo "🚀 Quick start:"
echo "   cd $PROJECT_NAME"
echo "   source .venv/bin/activate"
echo "   python main.py"
echo ""
echo "📦 Project structure:"
echo "   ├── .venv/           # Virtual environment"
echo "   ├── main.py          # Example script"
echo "   ├── requirements.txt # Dependencies"
echo "   └── README.md        # Documentation"
