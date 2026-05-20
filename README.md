# Scripts Organization

This directory contains all organized utility scripts for home directory management, analysis, and data processing.

## 📁 Directory Structure

```
scripts/
├── analysis/              # Analysis and scanning scripts
│   ├── analysis_launcher.sh         # Launch analysis scripts with options
│   ├── RUN_ULTRA_DEEP_ANALYSIS.sh   # Ultra deep intelligence analysis
│   ├── analyze_local_dirs.sh        # Analyze local directories
│   └── other analysis scripts...
│
├── merge/                 # Data merging and consolidation
│   ├── merge_diff.sh                 # Merge differences between files
│   ├── merge_similar_markdown.sh     # Merge similar markdown files
│   ├── consolidate_images.sh         # Consolidate image files
│   └── other merge scripts...
│
├── organize/              # File organization utilities
│   ├── rename_files.sh               # Rename files according to plan
│   ├── sortD.sh                      # Sort directory files
│   └── other organization scripts...
│
├── utils/                 # General utilities
│   ├── trans.sh                       # Translation utilities
│   ├── search_helpers.sh              # Search helper functions
│   └── other utility scripts...
│
├── run_all.py             # Master script to run all analyses
└── README.md              # This file
```

## 📚 Categories

### Analysis (`analysis/`)

Scripts for analyzing and scanning directories, files, and content.

#### Analysis Scripts
The analysis category contains various scripts for analyzing directories, files, and content:

- **analysis_launcher.sh**: Interactive launcher for analysis tasks
- **RUN_ULTRA_DEEP_ANALYSIS.sh**: Comprehensive deep analysis orchestrator
- **analyze_local_dirs.sh**: Local directory scanning and analysis
- **analyze-prompt.sh**: AI prompt analysis using OpenAI API

**Usage Examples**:
```bash
bash scripts/analysis/analysis_launcher.sh
bash scripts/analysis/RUN_ULTRA_DEEP_ANALYSIS.sh
```

### Merge (`merge/`)

Scripts for merging, consolidating, and combining data from multiple sources.

#### Merge Scripts
The merge category contains scripts for merging and consolidating data:

- **merge_diff.sh**: Compare and merge file differences
- **merge_similar_markdown.sh**: Merge similar markdown documents
- **consolidate_images.sh**: Consolidate scattered image files

**Usage Examples**:
```bash
bash scripts/merge/merge_diff.sh
bash scripts/merge/consolidate_images.sh
```

### Organize (`organize/`)

Scripts for organizing files by type, content, and purpose.

#### Organization Scripts
- **rename_files.sh**: Rename files according to predefined plans
- **sortD.sh**: Sort and organize directory contents
- **duplicates-to-csv.sh**: Identify and catalog duplicate files

**Usage Examples**:
```bash
bash scripts/organize/rename_files.sh
bash scripts/organize/sortD.sh
```

## 🚀 Usage

### Run All Analyses

Execute all scripts in proper order:
```bash
python scripts/run_all.py
```

### Run Specific Category

Run only scripts from a specific category:
```bash
python scripts/run_all.py --category analysis
python scripts/run_all.py --category merge
python scripts/run_all.py --category organize
```

### Export Results

Export execution summary to JSON:
```bash
python scripts/run_all.py --export
python scripts/run_all.py --category analysis --export
```

### List Available Scripts

View all available scripts:
```bash
python scripts/run_all.py --list
```

### Run Individual Scripts

Run scripts directly:
```bash
python scripts/analysis/analyze_chat_history.py
python scripts/merge/merge_all_data.py
```

## 📊 Output Files

Scripts generate various output files in your home directory:

- `chat_history_analysis_*.json` - Chat history analysis results
- `home_directory_analysis.json` - Home directory analysis
- `scripts_execution_summary_*.json` - Execution summary
- `MERGED_ANALYSIS.csv` - Merged data analysis
- `MASTER_MERGED_DATA.csv` - Master merged data

## 🔧 Configuration

Scripts use sensible defaults but can be customized:

- **Chat History Locations**: `~/.claude`, `~/.codex`
- **Output Directory**: Home directory (`~`)
- **File Patterns**: Defined in each script's constants

## 📝 Code Quality

All scripts follow best practices:

- ✅ Type hints for better IDE support
- ✅ Comprehensive docstrings
- ✅ Error handling and validation
- ✅ Consistent code structure
- ✅ Detailed logging and output
- ✅ Export capabilities

## 🎯 Best Practices

1. **Run Analysis First**: Always run analysis scripts before merge/organize
2. **Review Results**: Check output files before running consolidation
3. **Backup First**: Create backups before running file-moving scripts
4. **Use Categories**: Run specific categories when you only need certain analyses
5. **Export Results**: Use `--export` to save execution summaries

## 🔄 Workflow

Recommended workflow:

1. **Analysis Phase**:
   ```bash
   python scripts/run_all.py --category analysis --export
   ```

2. **Review Results**: Check generated JSON/CSV files

3. **Merge Phase** (if needed):
   ```bash
   python scripts/run_all.py --category merge
   ```

4. **Organize Phase** (if needed):
   ```bash
   python scripts/run_all.py --category organize
   ```

## 📖 Additional Documentation

- Each script contains detailed docstrings
- Use `--help` flag for command-line options
- Check script headers for specific usage examples

## 🐛 Troubleshooting

**Script not found**: Ensure you're running from the correct directory
```bash
cd /Users/steven
python scripts/run_all.py
```

**Permission errors**: Make scripts executable
```bash
chmod +x scripts/**/*.py
```

**Import errors**: Ensure Python path includes scripts directory
```bash
export PYTHONPATH="${PYTHONPATH}:/Users/steven/scripts"
```

## 📅 Version History

- **v1.0.0** (2025-11-25): Initial organization and improvement
  - Organized scripts into categories
  - Added comprehensive documentation
  - Improved code quality
  - Created master run_all.py script
# scripts
