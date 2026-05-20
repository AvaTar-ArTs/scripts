#!/usr/bin/env bash
# Safe Cleanup Script
# Run with: bash cleanup_safe.sh

set -e  # Exit on error

echo "🧹 Starting Safe Cleanup..."
echo ""

# 1. Remove broken symlinks
echo "1️⃣  Removing broken symlinks..."
rm -f ~/update 2>/dev/null && echo "   ✅ Removed ~/update" || echo "   ℹ️  ~/update not found"
rm -f ~/.config/quick-refs/2T-Xx_API_QUICK_REFERENCE.md 2>/dev/null && echo "   ✅ Removed external drive reference" || echo "   ℹ️  External drive reference not found"
echo ""

# 2. Clean cache directories
echo "2️⃣  Cleaning cache directories..."
rm -rf ~/.cache/claude/staging 2>/dev/null && echo "   ✅ Cleaned Claude staging cache" || echo "   ℹ️  Claude cache not found"
find ~/.claude/session-env -type d -empty -mtime +7 -delete 2>/dev/null && echo "   ✅ Cleaned old session environments" || echo "   ℹ️  No old sessions to clean"
rm -rf ~/.npm/_cacache/tmp 2>/dev/null && echo "   ✅ Cleaned npm temp cache" || echo "   ℹ️  npm cache not found"
rm -rf ~/.rustup/downloads ~/.rustup/tmp 2>/dev/null && echo "   ✅ Cleaned Rust cache" || echo "   ℹ️  Rust cache not found"
echo ""

# 3. Archive old backups
echo "3️⃣  Archiving old backups..."
cd ~/.env.d/backups 2>/dev/null || { echo "   ⚠️  Backups directory not found"; exit 1; }
if [ -d "pruned_sources" ] && [ "$(ls -A pruned_sources/*.bak 2>/dev/null)" ]; then
    ARCHIVE_NAME="backups_archive_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$ARCHIVE_NAME" pruned_sources/*.bak 2>/dev/null
    if [ -f "$ARCHIVE_NAME" ]; then
        echo "   ✅ Backups archived to $ARCHIVE_NAME"
        echo "   📦 Archive size: $(du -h "$ARCHIVE_NAME" | cut -f1)"
        echo "   💡 Review archive, then remove originals with: rm pruned_sources/*.bak"
    else
        echo "   ⚠️  Archive creation failed"
    fi
else
    echo "   ℹ️  No backups to archive"
fi
echo ""

# 4. Remove empty cache directories
echo "4️⃣  Removing empty cache directories..."
find ~/.cache -type d -empty -delete 2>/dev/null && echo "   ✅ Removed empty cache directories" || echo "   ℹ️  No empty cache dirs"
find ~/.npm -type d -empty -delete 2>/dev/null && echo "   ✅ Removed empty npm directories" || echo "   ℹ️  No empty npm dirs"
find ~/.rustup -type d -empty -delete 2>/dev/null && echo "   ✅ Removed empty Rust directories" || echo "   ℹ️  No empty Rust dirs"
echo ""

# 5. Install missing Python packages
echo "5️⃣  Installing missing Python packages..."
pip install --quiet --upgrade PyQt5 IPython pytesseract python-docx pydub 2>/dev/null && echo "   ✅ High-priority packages installed" || echo "   ⚠️  Some packages may need manual installation"
echo ""

echo "✨ Cleanup Complete!"
echo ""
echo "📊 Next Steps:"
echo "   1. Review backup archive before removing originals"
echo "   2. Test Python scripts that needed missing packages"
echo "   3. Review empty project directories manually"
