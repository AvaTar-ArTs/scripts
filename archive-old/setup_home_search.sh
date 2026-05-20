#!/usr/bin/env bash
# home-search-index/setup_home_search.sh

set -e  # Exit on any error

echo "Setting up Home Directory Search System..."

# Create the index directory
mkdir -p /Users/steven/home-search-index

# Copy the scripts to the home-search-index directory
cp /Users/steven/Documents/index_home_directory.py /Users/steven/home-search-index/
cp /Users/steven/Documents/search_home_directory.py /Users/steven/home-search-index/
cp /Users/steven/Documents/requirements_home_search.txt /Users/steven/home-search-index/
cp /Users/steven/Documents/README_HOME_SEARCH.md /Users/steven/home-search-index/

# Change to the home-search-index directory
cd /Users/steven/home-search-index

# Create a virtual environment
python3 -m venv home-search-env
source home-search-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements_home_search.txt

# Make scripts executable
chmod +x index_home_directory.py
chmod +x search_home_directory.py

echo "Setup complete!"
echo "To index your home directory, run:"
echo "  source home-search-env/bin/activate"
echo "  python index_home_directory.py"
echo ""
echo "To search your indexed documents, run:"
echo "  source home-search-env/bin/activate"
echo "  python search_home_directory.py 'your search query'"
echo ""
echo "For interactive search, run:"
echo "  source home-search-env/bin/activate"
echo "  python search_home_directory.py"