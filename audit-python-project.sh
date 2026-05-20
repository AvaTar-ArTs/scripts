#!/usr/bin/env bash

# Usage: ./audit_python_project.sh /path/to/your/project
# Example: ./audit_python_project.sh ~/projects/my-python-app

set -e

PROJECT_DIR="$1"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_DIR="$PROJECT_DIR/audit_report_$TIMESTAMP"

mkdir -p "$REPORT_DIR"

echo "🔍 Starting audit for: $PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

### 1. Setup Python environment ###
echo "📦 Creating virtual environment..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip

### 2. Install tools ###
echo "🛠 Installing audit tools..."
pip install black flake8 mypy pytest isort pipreqs > /dev/null

### 3. Generate requirements.txt if missing ###
if [ ! -f requirements.txt ]; then
  echo "📄 Generating requirements.txt..."
  pipreqs . --force
fi

### 4. Lint with flake8 ###
echo "🧹 Running flake8..."
flake8 . > "$REPORT_DIR/flake8_report.txt" || true

### 5. Format check with black ###
echo "🎨 Checking formatting with black..."
black . --check > "$REPORT_DIR/black_report.txt" || true

### 6. Type check with mypy ###
echo "📘 Running mypy..."
mypy . > "$REPORT_DIR/mypy_report.txt" || true

### 7. Import sorting with isort ###
echo "📚 Checking import order..."
isort . --check-only > "$REPORT_DIR/isort_report.txt" || true

### 8. Run tests ###
echo "🧪 Running pytest..."
pytest --maxfail=3 --disable-warnings > "$REPORT_DIR/pytest_report.txt" || true

### 9. Check for key project files ###
echo "📁 Checking key files..."
for file in README.md LICENSE pyproject.toml setup.py; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing: $file" >> "$REPORT_DIR/missing_files.txt"
  else
    echo "✅ Found: $file" >> "$REPORT_DIR/missing_files.txt"
  fi
done

### 10. Summary ###
echo "✅ Audit complete. Results saved in:"
echo "$REPORT_DIR"

### 11. Create zip file ###
ZIP_NAME="audit_$(basename "$PROJECT_DIR")_$TIMESTAMP.zip"
zip -r "$ZIP_NAME" "$REPORT_DIR" > /dev/null
echo "📦 Zipped report available at: $ZIP_NAME"
