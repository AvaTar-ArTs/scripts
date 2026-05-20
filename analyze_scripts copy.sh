#!/usr/bin/env python3
set -euo pipefail
"""
analyze_python_scripts.py — Analyzes Python scripts recursively within a target directory.
Performs checks for linting, security, error handling patterns, and readability using
ruff, bandit, grep, and hashing. Outputs findings to a detailed CSV file and a
summary Markdown report.

Author: Gemini AI Agent (based on user plan)
Date: $(date +"%Y-%m-%d_%H-%M-%S")
"""

import os
import sys
import csv
import re
import subprocess
import hashlib
import logging
import argparse
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, List, Any
from concurrent.futures import ThreadPoolExecutor, as_completed

# --- Configuration & Defaults ---
DEFAULT_TARGET_DIR = "." # Default to current directory if no argument provided
DEFAULT_BATCH_SIZE = 50
DEFAULT_MAX_WORKERS = os.cpu_count() or 4 # Use system cores or default to 4

# Analysis types to perform
ANALYSIS_TYPES = ["linting", "error_handling", "security", "readability"]

# Thresholds for dynamic strategy
BULK_LIMIT = 50   # Files for bulk processing (all at once)
BATCH_LIMIT = 500 # Files for batched processing (batch processing if > BULK_LIMIT and <= BATCH_LIMIT)
# Individual processing if > BATCH_LIMIT (or explicitly chosen)

# Output files
TIMESTAMP = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
CSV_OUTPUT_TEMPLATE = "{target_dir}/analysis_report_{timestamp}.csv"
MD_OUTPUT_TEMPLATE = "{target_dir}/analysis_summary_{timestamp}.md"

# --- Tool Checks ---
def check_tool_availability(tools):
    """Checks if required command-line tools are available."""
    for tool in tools:
        try:
            subprocess.run([tool, "--version"], check=True, capture_output=True)
            logging.info(f"Tool '{tool}' found.")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print(f"Error: Required tool '{tool}' not found. Please install it.")
            sys.exit(1)

# --- Helper Functions ---

def get_file_hash(filepath: str, hash_algo: str = "sha256") -> str:
    """Compute hash of a file."""
    hasher = hashlib.new(hash_algo)
    try:
        with open(filepath, 'rb') as f:
            while True:
                chunk = f.read(65536) # Read in chunks
                if not chunk:
                    break
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as e:
        logging.error(f"Error computing hash for {filepath}: {e}")
        return ""

def format_file_size(size_in_bytes: int) -> str:
    """Human-friendly file size."""
    for factor, suffix in [(1 << 40, "TB"), (1 << 30, "GB"), (1 << 20, "MB"), (1 << 10, "KB"), (1, "B")]:
        if size_in_bytes >= factor:
            return f"{size_in_bytes / factor:.2f} {suffix}"
    return f"{size_in_bytes} B"

# --- Analysis Functions ---

def run_command(command: List[str], cwd: str = None) -> tuple[int, str, str]:
    """Runs a command and returns exit code, stdout, stderr."""
    try:
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            cwd=cwd,
            encoding='utf-8',
            errors='replace'
        )
        return process.returncode, process.stdout, process.stderr
    except Exception as e:
        return 1, "", str(e)

def analyze_python_file(filepath: str, analysis_types: List[str]) -> List[Dict[str, Any]]:
    """Analyze a Python file using ruff, bandit, grep, and hashing."""
    findings = []
    file_hash = get_file_hash(filepath)
    filepath_str = str(filepath) # Ensure string for consistency

    # --- Linting and Code Style (ruff) ---
    if "linting" in analysis_types or "syntax" in analysis_types:
        # Ruff check command - output format needs to be machine-readable for parsing
        # Example format: path/to/file.py:10:1: E501 Line too long (80 > 79 characters)
        # We'll use a simple grep for now, but proper JSON output is better if available.
        ruff_cmd = ["ruff", "check", "--output-format=line", str(filepath)]
        return_code, stdout, stderr = run_command(ruff_cmd)
        if return_code == 0 and stdout:
            for line in stdout.splitlines():
                if line.startswith(str(filepath)): # Ensure it's relevant to the file
                    parts = line.split(':', 4) # Split into path, line, col, code, message
                    if len(parts) >= 4:
                        ln, col = parts[1], parts[2]
                        code_severity = parts[3]
                        desc = parts[4].strip()
                        issue_type = "Linting"
                        severity = "Info" # Ruff codes often indicate severity
                        if code_severity.startswith(("E", "F", "W")): severity = "Warning"
                        if code_severity.startswith(("C", "I", "U")): severity = "Info" # e.g., C9000 for complexity

                        findings.append({
                            "FilePath": filepath_str,
                            "LineNumber": ln,
                            "IssueType": issue_type,
                            "Severity": severity,
                            "Description": desc,
                            "Suggestion": f"Fix {code_severity}: {desc}",
                            "FileHash_SHA256": file_hash,
                            "IsDuplicate": False,
                            "DuplicateOf": "",
                        })
        elif return_code != 0: # Ruff might exit with non-zero for found issues
             # Ruff might output errors to stderr as well, or just issues to stdout
             if stderr:
                 logging.warning(f"Ruff check produced stderr for {filepath}:
{stderr}")

    # --- Security Checks (bandit) ---
    if "security" in analysis_types:
        # Bandit command to output JSON for easier parsing
        bandit_cmd = ["bandit", "-r", str(filepath), "-f", "json", "-q"] # -q for quiet
        return_code, stdout, stderr = run_command(bandit_cmd)
        if return_code == 0 and stdout:
            try:
                # Parse JSON output from bandit
                import json
                data = json.loads(stdout)
                for finding in data.get("results", []):
                    issue_type = "Security"
                    severity = finding.get("issue_severity", "Info").capitalize()
                    line_num = finding.get("line_number", "N/A")
                    description = finding.get("issue_text", "No description")
                    suggestion = finding.get("more_info", "")
                    findings.append({
                        "FilePath": filepath_str,
                        "LineNumber": line_num,
                        "IssueType": issue_type,
                        "Severity": severity,
                        "Description": description,
                        "Suggestion": suggestion,
                        "FileHash_SHA256": file_hash,
                        "IsDuplicate": False,
                        "DuplicateOf": "",
                    })
            except json.JSONDecodeError:
                logging.error(f"Failed to parse Bandit JSON output for {filepath}: {stdout[:200]}...")
            except Exception as e:
                logging.error(f"Error processing Bandit findings for {filepath}: {e}")
        elif return_code != 0:
             logging.warning(f"Bandit check exited with code {return_code} for {filepath}. Stderr:
{stderr[:200]}...")


    # --- Error Handling & Readability Checks (using grep for specific patterns) ---
    if "error_handling" in analysis_types or "readability" in analysis_types:
        # Example: Check for lack of try-except blocks around potentially risky operations
        # This is a heuristic and might require custom logic for better accuracy.
        if "try" not in subprocess.getoutput(f"grep -i 'try\|except\|finally' {filepath}"):
             # Basic check - might be too noisy
             issue_type="ErrorHandling"
             severity="Info"
             description="No try-except/finally blocks found."
             suggestion="Consider adding error handling for critical operations."
             findings.append({
                 "FilePath": filepath_str,
                 "LineNumber": "N/A",
                 "IssueType": issue_type,
                 "Severity": severity,
                 "Description": description,
                 "Suggestion": suggestion,
                 "FileHash_SHA256": file_hash,
                 "IsDuplicate": False,
                 "DuplicateOf": "",
             })

        # Example: Check for long lines (similar to shell script, but Python conventions might differ)
        if "readability" in analysis_types:
             if awk -v filepath="$filepath_str" 'length > 88 {print filepath ":" NR ":" $0}' | head -n 1; then
                # Placeholder for actual awk/grep logic
                pass


    return findings


def analyze_shell_file(filepath: str, analysis_types: List[str]) -> List[Dict[str, Any]]:
    """Analyze a shell script file using shellcheck, grep, and hashing."""
    findings = []
    file_hash = get_file_hash(filepath)
    filepath_str = str(filepath)

    # --- Syntax/Linting (shellcheck) ---
    if "syntax" in analysis_types or "linting" in analysis_types:
        shellcheck_output=$(shellcheck -f gcc "$filepath" 2>&1)
        if [[ -n "$shellcheck_output" ]]; then
            while IFS= read -r line; do
                if [[ $line =~ ^([^:]+):([0-9]+):([0-9]+): (SC[0-9]+) (.*)$ ]]; then
                    local fpath="${BASH_REMATCH[1]}"
                    local line_num="${BASH_REMATCH[2]}"
                    local col_num="${BASH_REMATCH[3]}"
                    local code="${BASH_REMATCH[4]}"
                    local desc="${BASH_REMATCH[5]}"
                    local severity="Info"
                    case "$code" in
                        SC1*) severity="Info" ;;
                        SC2*) severity="Warning" ;;
                        SC3*) severity="Critical" ;;
                        SC4*) severity="Critical" ;;
                    esac
                    issue_type="Syntax/Linting"
                    suggestion="Refer to shellcheck documentation for $code."
                    findings.append({
                        "FilePath": filepath_str,
                        "LineNumber": line_num,
                        "IssueType": issue_type,
                        "Severity": severity,
                        "Description": desc,
                        "Suggestion": suggestion,
                        "FileHash_SHA256": file_hash,
                        "IsDuplicate": False,
                        "DuplicateOf": "",
                    })
                fi
            done <<< "$shellcheck_output"
        fi
    fi

    # --- Error Handling Check ---
    if "error_handling" in analysis_types:
        if not re.search(r'^\s*set\s+-e', open(filepath_str).read()) and 
           not re.search(r'^\s*set\s+\-o\s+errexit', open(filepath_str).read()):
            issue_type="ErrorHandling"
            severity="Warning"
            description="'set -e' or 'set -o errexit' is not enabled."
            suggestion="Add 'set -e' or 'set -o errexit' at the beginning of the script to exit immediately if a command exits with a non-zero status."
            findings.append({
                "FilePath": filepath_str,
                "LineNumber": 1, # Default to line 1 for file-level checks
                "IssueType": issue_type,
                "Severity": severity,
                "Description": description,
                "Suggestion": suggestion,
                "FileHash_SHA256": file_hash,
                "IsDuplicate": False,
                "DuplicateOf": "",
            })

    # --- Security Check ---
    if "security" in analysis_types:
        # Example: Search for common patterns indicating hardcoded secrets
        if re.search(r'export\s+.*(password|api_key|secret|token|pwd)\s*=', open(filepath_str).read()):
            issue_type="Security"
            severity="Critical"
            description="Potential hardcoded secret pattern found."
            suggestion="Avoid hardcoding secrets directly in scripts. Use environment variables or a secrets management system."
            findings.append({
                "FilePath": filepath_str,
                "LineNumber": "N/A",
                "IssueType": issue_type,
                "Severity": severity,
                "Description": description,
                "Suggestion": suggestion,
                "FileHash_SHA256": file_hash,
                "IsDuplicate": False,
                "DuplicateOf": "",
            })

    # --- Readability Check ---
    if "readability" in analysis_types:
        # Example: Find lines exceeding 120 characters
        try:
            with open(filepath_str, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
            for i, line in enumerate(lines):
                if len(line.strip()) > 120:
                    issue_type="Readability"
                    severity="Info"
                    description=f"Line exceeds 120 characters: '{line.strip()[:120]}...'"
                    suggestion="Break long lines for better readability and maintainability."
                    findings.append({
                        "FilePath": filepath_str,
                        "LineNumber": i + 1,
                        "IssueType": issue_type,
                        "Severity": severity,
                        "Description": description,
                        "Suggestion": suggestion,
                        "FileHash_SHA256": file_hash,
                        "IsDuplicate": False,
                        "DuplicateOf": "",
                    })
                    break # Report first long line found
        except Exception as e:
            logging.error(f"Could not read lines for readability check in {filepath}: {e}")

        # Example: Check for minimal comments (basic heuristic)
        try:
            with open(filepath_str, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            num_lines = len(content.splitlines())
            num_comments = len(re.findall(r'^\s*#', content, re.MULTILINE))
            if num_comments < 2 and num_lines > 10:
                issue_type="Readability"
                severity="Info"
                description="Minimal comments found in a non-trivial script."
                suggestion="Add comments to explain complex logic or script purpose."
                findings.append({
                    "FilePath": filepath_str,
                    "LineNumber": 1, # Placeholder for file-level check
                    "IssueType": issue_type,
                    "Severity": severity,
                    "Description": description,
                    "Suggestion": suggestion,
                    "FileHash_SHA256": file_hash,
                    "IsDuplicate": False,
                    "DuplicateOf": "",
                })
        except Exception as e:
            logging.error(f"Could not perform comment check for {filepath}: {e}")


    return findings

# --- Main Logic ---
def main():
    parser = argparse.ArgumentParser(
        description="Analyzes shell and Python scripts for issues. Generates CSV and Markdown reports."
    )
    parser.add_argument("target_dir", nargs="?", default=".", help="Directory to scan recursively.")
    parser.add_argument("--batch-size", type=int, default=50, help="Number of files per batch for analysis.")
    parser.add_argument("--max-workers", type=int, default=os.cpu_count() or 4, help="Max concurrent workers for parallel processing.")
    parser.add_argument("--analysis-types", type=str, default="syntax,error_handling,security,readability", help="Comma-separated list of analysis types (e.g., syntax,error_handling,security,readability).")
    parser.add_argument("--output-csv", type=str, default="", help="Path for the output CSV report.")
    parser.add_argument("--output-md", type=str, default="", help="Path for the output Markdown report.")
    parser.add_argument("--enable-dedup", action="store_true", help="Enable SHA256 file deduplication.")
    parser.add_argument("--no-metadata", action="store_true", help="Skip metadata extraction (e.g., line counts, hashes).")
    parser.add_argument("--exclude-patterns", nargs="*", help="Glob patterns to exclude from scanning.")
    parser.add_argument("--no-excludes", action="store_true", help="Do not use default exclude patterns.")

    args = parser.parse_args()

    TARGET_DIR = os.path.abspath(args.target_dir)
    BATCH_SIZE = args.batch_size
    MAX_WORKERS = args.max_workers
    ANALYSIS_TYPES_ARG = args.analysis_types.split(',')
    CSV_OUTPUT = args.output_csv if args.output_csv else f"{TARGET_DIR}/analysis_report_{TIMESTAMP}.csv"
    MD_OUTPUT = args.output_md if args.output_md else f"{TARGET_DIR}/analysis_summary_{TIMESTAMP}.md"

    # --- Tool Checks ---
    print("Verifying necessary tools...")
    required_tools = ["shellcheck", "grep", "md5sum", "find", "xargs", "du", "awk", "realpath"]
    # Python tools check is more complex, assume they are available if .py files are analyzed
    for cmd in required_tools:
        if not shutil.which(cmd):
            print(f"Error: Required tool '{cmd}' not found. Please install it.")
            sys.exit(1)
    print("Essential shell tools verified.")

    # Basic check for Python tools - a more robust check might be needed
    if any(t in ANALYSIS_TYPES_ARG for t in ["syntax", "linting", "security"]) and (any(f.endswith(".py") for f in Path(TARGET_DIR).rglob("*.py"))):
         for py_tool in ["ruff", "bandit"]:
             if not shutil.which(py_tool):
                 print(f"Warning: Python analysis requested, but '{py_tool}' might not be available. Install it via pip.")
                 # Decide if this should be a fatal error or a warning
                 # For now, let it proceed, but analysis for .py might fail/be incomplete.

    print("--- Configuration ---")
    print(f"Target Directory: {TARGET_DIR}")
    print(f"Analysis Types: {', '.join(ANALYSIS_TYPES_ARG)}")
    print(f"Batch Size: {BATCH_SIZE}")
    print(f"Max Workers: {MAX_WORKERS}")
    print(f"Thresholds: Bulk <= {BULK_LIMIT}, Batch <= {BATCH_LIMIT}, Parallel > {BATCH_LIMIT}")
    print("")

    # --- Output File Setup ---
    print(f"Output CSV: {CSV_OUTPUT}")
    print(f"Output Markdown: {MD_OUTPUT}")
    print("")

    # --- Prepare CSV Header ---
    # Confirmed CSV Columns: FilePath,LineNumber,IssueType,Severity,Description,Suggestion,FileHash_SHA256,IsDuplicate,DuplicateOf
    csv_header = ["FilePath", "LineNumber", "IssueType", "Severity", "Description", "Suggestion", "FileHash_SHA256", "IsDuplicate", "DuplicateOf"]
    try:
        with open(CSV_OUTPUT, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_header)
            writer.writeheader()
    except IOError as e:
        print(f"Error: Could not write to CSV file {CSV_OUTPUT}: {e}")
        sys.exit(1)


    # --- File Discovery ---
    print("Discovering .sh and .py files for analysis...")
    search_patterns = []
    if "syntax" in ANALYSIS_TYPES_ARG or "error_handling" in ANALYSIS_TYPES_ARG or "security" in ANALYSIS_TYPES_ARG or "readability" in ANALYSIS_TYPES_ARG:
        search_patterns.append("-name "*.sh"")
        search_patterns.append("-o -name "*.py"") # Add python analysis if requested

    if not search_patterns:
        print("No analysis types selected. Exiting.")
        sys.exit(0)

    find_cmd = ["find", TARGET_DIR, "-type", "f"]
    if len(search_patterns) > 0:
        find_cmd.append("(")
        find_cmd.append(" ".join(search_patterns))
        find_cmd.append(")")
    
    # Handle excludes
    find_exclude_args = []
    if not args.no_excludes:
        # Using default exclude patterns if not overridden and no-excludes is false
        try:
            from exclude_patterns import FULL_EXCLUDED_PATTERNS
            patterns_to_exclude = FULL_EXCLUDED_PATTERNS
        except ImportError:
            patterns_to_exclude = [
                r'.*\.git/.*', r'.*node_modules/.*', r'.*__pycache__/.*',
                r'.*\.venv/.*', r'.*venv/.*', r'.*site-packages/.*',
            ]
        
        for pattern in patterns_to_exclude:
            find_exclude_args.extend(["-not", "-path", f"*{pattern.strip('.*')}*/"]) # Simplistic exclusion, real glob patterns are better

    find_cmd.extend(find_exclude_args) # Add exclude arguments if any

    try:
        # Construct the find command carefully
        full_find_cmd_str = " ".join(find_cmd)
        FILE_LIST=$(eval "$full_find_cmd_str")
        FILE_COUNT=$(echo "$FILE_LIST" | wc -l | xargs)
    except Exception as e:
        print(f"Error during file discovery: {e}")
        sys.exit(1)

    if [[ "$FILE_COUNT" -eq 0 ]]; then
        print("No matching files found to process.")
        sys.exit(0)
    echo "Found $FILE_COUNT files."
    echo ""

    # --- Determine Processing Mode (Dynamic Strategy) ---
    PROCESSING_MODE=""
    if [[ "$FILE_COUNT" -le "$BULK_LIMIT" ]]; then
        PROCESSING_MODE="bulk"
        echo "Workload is small ($FILE_COUNT files). Using bulk processing."
    elif [[ "$FILE_COUNT" -le "$BATCH_LIMIT" ]]; then
        PROCESSING_MODE="batch"
        echo "Workload is moderate ($FILE_COUNT files). Using batch processing with batch size $BATCH_SIZE."
    else
        PROCESSING_MODE="parallel"
        echo "Workload is large ($FILE_COUNT files). Using parallel processing with $MAX_WORKERS workers."
    fi
    echo ""

    # --- Execute Analysis ---
    echo "Starting analysis..."
    # Define analysis types to be passed
    ANALYSIS_TYPES_PASS=$ANALYSIS_TYPES_ARG

    if [[ "$PROCESSING_MODE" == "parallel" ]]; then
        # Parallel processing using xargs
        # This structure needs refinement to correctly pass file extension logic to analyze functions
        # For simplicity now, it calls analyze_shell_file for all, will need modification
        echo "$FILE_LIST" | xargs -P "$MAX_WORKERS" -I {} bash -c '
            filepath="{}"
            if [[ "$filepath" == *.sh ]]; then
                analyze_shell_file "$filepath" "$ANALYSIS_TYPES_ARG" >> "$CSV_OUTPUT"
            elif [[ "$filepath" == *.py ]]; then
                analyze_python_file "$filepath" "$ANALYSIS_TYPES_ARG" >> "$CSV_OUTPUT"
            fi
        ' _ {} "$ANALYSIS_TYPES_ARG"

    else
        # Sequential processing
        echo "$FILE_LIST" | while IFS= read -r file; do
            if [[ "$file" == *.sh ]]; then
                analyze_shell_file "$file" "$ANALYSIS_TYPES_ARG" >> "$CSV_OUTPUT"
            elif [[ "$file" == *.py ]]; then
                # Placeholder for Python analysis - needs to call analyze_python_file
                # For now, just hash it and add a placeholder entry
                file_hash=$(get_file_hash "$file")
                echo "${file},N/A,Code,Info,Python file found,Review with Python tools,${file_hash},false," >> "$CSV_OUTPUT"
            fi
        done
    fi

    # --- Error Handling Summary ---
    # TODO: Implement logic to count errors/warnings from analysis tools and summarize in report.
    echo "Analysis complete. Results written to $CSV_OUTPUT"
    echo ""

    # --- Generate Markdown Report ---
    echo "# Analysis Report Summary - ${TIMESTAMP}" > "$MD_OUTPUT"
    echo "" >> "$MD_OUTPUT"
    echo "## Overview" >> "$MD_OUTPUT"
    echo "" >> "$MD_OUTPUT"
    echo "- **Target Directory:** `$TARGET_DIR`" >> "$MD_OUTPUT"
    echo "- **Processing Mode:** `$PROCESSING_MODE`" >> "$MD_OUTPUT"
    echo "- **Total Files Scanned:** $FILE_COUNT" >> "$MD_OUTPUT"
    echo "- **Analysis Types:** ${ANALYSIS_TYPES_ARG//,/ }" >> "$MD_OUTPUT"
    echo "" >> "$MD_OUTPUT"
    echo "## Tools Used" >> "$MD_OUTPUT"
    echo "- shellcheck (for .sh files)" >> "$MD_OUTPUT"
    echo "- ruff (for .py files - planned integration)" >> "$MD_OUTPUT"
    echo "- bandit (for Python security - planned integration)" >> "$MD_OUTPUT"
    echo "- grep (for specific patterns)" >> "$MD_OUTPUT"
    echo "- md5sum/sha256sum (for hashing/deduplication)" >> "$MD_OUTPUT"
    echo "" >> "$MD_OUTPUT"
    echo "## Detailed Findings" >> "$MD_OUTPUT"
    echo "" >> "$MD_OUTPUT"
    echo "Please refer to the generated CSV file (`$CSV_OUTPUT`) for detailed findings per file." >> "$MD_OUTPUT"

    echo "Markdown summary generated at $MD_OUTPUT"
    echo ""

    echo "---"
    echo "Script execution finished."
    echo "CSV Report: $CSV_OUTPUT"
    echo "Markdown Summary: $MD_OUTPUT"
    echo "---"
}

# Execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Basic argument parsing for demo purposes.
    # A real script might use getopt for more robust parsing.
    TARGET_DIR="${1:-.}"
    BATCH_SIZE="${2:-50}"
    MAX_WORKERS="${3:-$(nproc 2>/dev/null || echo 4)}"
    ANALYSIS_TYPES_ARG="${4:-syntax,error_handling,security,readability}"

    # Resolve target directory to absolute path
    TARGET_DIR=$(realpath "$TARGET_DIR")

    # Ensure target directory exists
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Error: Target directory '$TARGET_DIR' does not exist." >&2
        exit 1
    fi

    main "$TARGET_DIR" "$BATCH_SIZE" "$MAX_WORKERS" "$ANALYSIS_TYPES_ARG"
fi
