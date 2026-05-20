#!/usr/bin/env bash

# UV Project Setup Script
# Creates a new Python project with uv for isolated development

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <project-name>"
    echo "Example: $0 my-ai-project"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="$HOME/$PROJECT_NAME"

echo "🚀 Setting up UV project: $PROJECT_NAME"
echo "======================================="

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv is not installed. Install it first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
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

# Initialize uv project
echo "📦 Initializing uv project..."
uv init --no-readme --no-workspace

# Add common development dependencies
echo "📚 Adding development dependencies..."
uv add --dev pytest black isort flake8 mypy

# Add example runtime dependencies (customize as needed)
echo "🔧 Adding example runtime dependencies..."
uv add requests python-dotenv

# Create .gitignore if not exists
if [ ! -f ".gitignore" ]; then
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
fi

# Create example script
cat > main.py << EOF
#!/usr/bin/env python3
"""
Example script for $PROJECT_NAME
"""

def main():
    print(f"Hello from {__name__}!")
    print("This is a uv-managed project with isolated dependencies.")

if __name__ == "__main__":
    main()
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

A Python project managed with uv.

## Setup

Make sure you have uv installed:
\`\`\`bash
curl -LsSf https://astral.sh/uv/install.sh | sh
\`\`\`

## Development

Run the project:
\`\`\`bash
uv run python main.py
\`\`\`

Run tests:
\`\`\`bash
uv run pytest
\`\`\`

Format code:
\`\`\`bash
uv run black .
uv run isort .
\`\`\`

## Adding Dependencies

\`\`\`bash
uv add package-name          # Runtime dependency
uv add --dev package-name    # Development dependency
\`\`\`
EOF

echo "✅ UV project '$PROJECT_NAME' created successfully!"
echo ""
echo "🚀 Quick start:"
echo "   cd $PROJECT_NAME"
echo "   uv run python main.py"
echo "   uv run pytest"
echo ""
echo "📦 Project structure:"
echo "   ├── pyproject.toml    # Project configuration"
echo "   ├── uv.lock          # Dependency lock file"
echo "   ├── main.py          # Example script"
echo "   ├── .venv/           # Virtual environment (auto-created)"
echo "   └── README.md        # Documentation"
