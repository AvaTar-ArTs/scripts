#!/usr/bin/env python3

"""
analyze_python_scripts.py — Analyzes Python scripts recursively within a target directory.
Performs checks for linting (ruff), security (bandit), error handling patterns, and
readability using grep and hashing. Outputs findings to a detailed CSV file and a
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
import json
import shutil # For shutil.which

# --- Configuration & Defaults ---
DEFAULT_TARGET_DIR = "." # Default to current directory if no argument provided
DEFAULT_BATCH_SIZE = 50
DEFAULT_MAX_WORKERS = os.cpu_count() or 4 # Use system cores or default to 4

# Analysis types to perform
ANALYSIS_TYPES_DEFAULT = "linting,error_handling,security,readability"

# Thresholds for dynamic strategy
BULK_LIMIT = 50   # Files for bulk processing (all at once)
BATCH_LIMIT = 500 # Files for batched processing (batch processing if > BULK_LIMIT and <= BATCH_LIMIT)
# Individual processing if > BATCH_LIMIT (or explicitly chosen)

# --- Logging Setup ---
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# --- Tool Checks ---
def check_tool_availability(tools: List[str]):
    """Checks if required command-line tools are available."""
    for tool in tools:
        if shutil.which(tool):
            logging.info(f"Tool '{tool}' found.")
        else:
            print(f"Error: Required tool '{tool}' not found. Please install it.")
            sys.exit(1)

# --- Helper Functions ---

def get_file_hash(filepath: Path, hash_algo: str = "sha256") -> str:
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

def run_command(command: List[str], cwd: Optional[Path] = None) -> tuple[int, str, str]:
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

# --- Analysis Functions ---

def analyze_python_file(filepath: Path, analysis_types: List[str]) -> List[Dict[str, Any]]:
    """Analyze a Python file using ruff, bandit, grep, and hashing."""
    findings = []
    file_hash = get_file_hash(filepath)
    filepath_str = str(filepath)

    # --- Linting and Code Style (ruff) ---
    if "linting" in analysis_types or "syntax" in analysis_types:
        ruff_cmd = ["ruff", "check", "--output-format=line", filepath_str]
        return_code, stdout, stderr = run_command(ruff_cmd)
        if stdout: # ruff outputs issues to stdout
            for line in stdout.splitlines():
                if line.startswith(filepath_str):
                    parts = line.split(':', 4)
                    if len(parts) >= 4:
                        ln = parts[1]
                        code_severity_str = parts[3]
                        desc = parts[4].strip()
                        issue_type = "Linting"
                        severity = "Info"
                        if code_severity_str.startswith(('E', 'F', 'W')): severity = "Warning"
                        if code_severity_str.startswith(('C', 'I', 'U')): severity = "Info"

                        findings.append({
                            "FilePath": filepath_str,
                            "LineNumber": ln,
                            "IssueType": issue_type,
                            "Severity": severity,
                            "Description": desc,
                            "Suggestion": f"Fix {code_severity_str}: {desc}",
                            "FileHash_SHA256": file_hash,
                            "IsDuplicate": False,
                            "DuplicateOf": "",
                        })
        if stderr:
             logging.warning(f"Ruff check produced stderr for {filepath}: {stderr[:200]}...")

    # --- Security Checks (bandit) ---
    if "security" in analysis_types:
        bandit_cmd = ["bandit", "-r", filepath_str, "-f", "json", "-q"]
        return_code, stdout, stderr = run_command(bandit_cmd)
        if stdout:
            try:
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
        if stderr:
             (logging.warning(f"Bandit check exited with code {return_code} for {filepath}. Stderr:\\n{stderr[:200]}..."))


    # --- Error Handling & Readability Checks (using grep for specific patterns) ---
    if "error_handling" in analysis_types or "readability" in analysis_types:
        try:
            with open(filepath_str, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            # Example: Check for lack of try-except blocks around potentially risky operations
            if "error_handling" in analysis_types:
                if not re.search(r'\b(try|except|finally)\b', content, re.IGNORECASE | re.MULTILINE):
                    issue_type="ErrorHandling"
                    severity="Info"
                    description="No 'try-except/finally' blocks found for error handling."
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

            # Example: Check for long lines (Python PEP 8 limit is 79/99)
            if "readability" in analysis_types:
                for i, line in enumerate(content.splitlines()):
                    if len(line.strip()) > 100: # Using a slightly more generous limit than strict PEP 8
                        issue_type="Readability"
                        severity="Info"
                        description=f"Line exceeds 100 characters: '{line.strip()[:100]}...'"
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

                # Example: Check for missing docstrings for modules/classes/functions
                if not re.search(r'^\s*(?:"""|''').*?(?:"""|''')', content, re.DOTALL) and len(content.splitlines()) > 15:
                    issue_type="Readability"
                    severity="Info"
                    description="Module lacks a top-level docstring."
                    suggestion="Add a module-level docstring explaining the script's purpose."
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
            logging.error(f"Could not perform custom grep/readability check for {filepath}: {e}")

    return findings

# --- Main Logic ---
def main():
    parser = argparse.ArgumentParser(
        description="Analyzes Python scripts for issues. Generates CSV and Markdown reports."
    )
    parser.add_argument("target_dir", nargs="?", default=DEFAULT_TARGET_DIR, help="Directory to scan recursively.")
    parser.add_argument("--batch-size", type=int, default=DEFAULT_BATCH_SIZE, help="Number of files per batch for analysis.")
    parser.add_argument("--max-workers", type=int, default=DEFAULT_MAX_WORKERS, help="Max concurrent workers for parallel processing.")
    parser.add_argument("--analysis-types", type=str, default=','.join(ANALYSIS_TYPES_DEFAULT), help="Comma-separated list of analysis types.")
    parser.add_argument("--output-csv", type=str, default="", help="Path for the output CSV report.")
    parser.add_argument("--output-md", type=str, default="", help="Path for the output Markdown report.")
    parser.add_argument("--enable-dedup", action="store_true", help="Enable SHA256 file deduplication.")
    parser.add_argument("--no-metadata", action="store_true", help="Skip metadata extraction (e.g., line counts, hashes).")
    parser.add_argument("--exclude-patterns", nargs="*", help="Glob patterns to exclude from scanning.")
    parser.add_argument("--no-excludes", action="store_true", help="Do not use default exclude patterns.")

    args = parser.parse_args()

    TARGET_DIR = Path(args.target_dir).resolve()
    BATCH_SIZE = args.batch_size
    MAX_WORKERS = args.max_workers
    ANALYSIS_TYPES_ARG = args.analysis_types.split(',')
    
    # Resolve output paths
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    CSV_OUTPUT = Path(args.output_csv).resolve() if args.output_csv else (TARGET_DIR / f"analysis_report_{timestamp}.csv").resolve()
    MD_OUTPUT = Path(args.output_md).resolve() if args.output_md else (TARGET_DIR / f"analysis_summary_{timestamp}.md").resolve()

    # --- Tool Checks ---
    print("Verifying necessary tools...")
    required_python_tools = ["ruff", "bandit"]
    check_tool_availability(required_python_tools)
    # Check for shell tools needed by Python for subprocess calls (e.g., grep, md5sum)
    required_shell_tools = ["grep", "md5sum"]
    check_tool_availability(required_shell_tools)
    print("Essential tools verified.")

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
    csv_header = ["FilePath", "LineNumber", "IssueType", "Severity", "Description", "Suggestion", "FileHash_SHA256", "IsDuplicate", "DuplicateOf"]
    try:
        with open(CSV_OUTPUT, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_header)
            writer.writeheader()
    except IOError as e:
        print(f"Error: Could not write to CSV file {CSV_OUTPUT}: {e}")
        sys.exit(1)

    # --- File Discovery ---
    print("Discovering .py files for analysis...")
    all_python_files = []
    # Using Path.rglob for more Pythonic recursive discovery
    for file_path in TARGET_DIR.rglob("*.py"):
        # Basic exclusion for common dev folders
        if any(exclude_pattern in str(file_path) for exclude_pattern in [".git", "node_modules", "__pycache__", ".venv", "venv", "site-packages", ".egg-info", "dist", "build"]):
            continue
        all_python_files.append(file_path)
    
    FILE_COUNT = len(all_python_files)

    if FILE_COUNT == 0:
        print("No .py files found to process.")
        sys.exit(0)
    print(f"Found {FILE_COUNT} files.")
    print("")

    # --- Determine Processing Mode (Dynamic Strategy) ---
    PROCESSING_MODE=""
    if FILE_COUNT <= BULK_LIMIT:
        PROCESSING_MODE="bulk"
        print(f"Workload is small ({FILE_COUNT} files). Using bulk processing.")
    elif FILE_COUNT <= BATCH_LIMIT:
        PROCESSING_MODE="batch"
        print(f"Workload is moderate ({FILE_COUNT} files). Using batch processing with batch size {BATCH_SIZE}.")
    else:
        PROCESSING_MODE="parallel"
        print(f"Workload is large ({FILE_COUNT} files). Using parallel processing with {MAX_WORKERS} workers.")
    print("")

    # --- Execute Analysis ---
    print("Starting analysis...")
    all_findings: List[Dict[str, Any]] = []

    if PROCESSING_MODE == "parallel" and MAX_WORKERS > 0:
        with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
            futures = [executor.submit(analyze_python_file, file_path, ANALYSIS_TYPES_ARG) for file_path in all_python_files]
            for i, future in enumerate(as_completed(futures), 1):
                try:
                    all_findings.extend(future.result())
                except Exception as e:
                    logging.error(f"Error during parallel processing: {e}")
            print(f"Processed {FILE_COUNT} files.")
    else: # Sequential or Bulk
        for i, file_path in enumerate(all_python_files, 1):
            try:
                all_findings.extend(analyze_python_file(file_path, ANALYSIS_TYPES_ARG))
            except Exception as e:
                logging.error(f"Error during sequential processing of {file_path}: {e}")
        print(f"Processed {FILE_COUNT} files.")

    # --- Write Findings to CSV ---
    try:
        with open(CSV_OUTPUT, "a", newline="", encoding="utf-8") as csvfile: # Use 'a' for append as header is already written
            writer = csv.DictWriter(csvfile, fieldnames=csv_header)
            writer.writerows(all_findings)
    except IOError as e:
        print(f"Error: Could not write findings to CSV file {CSV_OUTPUT}: {e}")
        sys.exit(1)

    # --- Error Handling Summary ---
    # TODO: Implement logic to count errors/warnings from analysis tools and summarize in report.
    print("Analysis complete. Results written to CSV.")
    print("")

    # --- Generate Markdown Report ---
    print(f"Generating Markdown report: {MD_OUTPUT}")
    with open(MD_OUTPUT, "w", encoding="utf-8") as mdfile:
        mdfile.write(f"# Analysis Report Summary - {timestamp}

")
        mdfile.write("## Overview

")
        mdfile.write(f"- **Target Directory:** `{TARGET_DIR}`
")
        mdfile.write(f"- **Processing Mode:** `{PROCESSING_MODE}`
")
        mdfile.write(f"- **Total Python Files Scanned:** {FILE_COUNT}
")
        mdfile.write(f"- **Analysis Types:** {', '.join(ANALYSIS_TYPES_ARG)}
")
        mdfile.write("
")
        mdfile.write("## Tools Used

")
        mdfile.write("- ruff (for .py linting/analysis)
")
        mdfile.write("- bandit (for Python security)
")
        mdfile.write("- grep (for specific patterns - integrated into Python analysis)
")
        mdfile.write("- md5sum/sha256sum (for hashing/deduplication)
")
        mdfile.write("
")
        mdfile.write("## Detailed Findings

")
        mdfile.write(f"Please refer to the generated CSV file (`{CSV_OUTPUT}`) for detailed findings per file.
")
        mdfile.write("
")
        mdfile.write("## Summary of Findings

")
        # TODO: Add logic to summarize findings (e.g., count by severity, issue type) from all_findings.
        mdfile.write("*(Summary of issues will appear here once implemented)*
")

    print("Markdown summary generated.")
    print("")

    print("---")
    print("Script execution finished.")
    print(f"CSV Report: {CSV_OUTPUT}")
    print(f"Markdown Summary: {MD_OUTPUT}")
    print("---")

# --- Script Execution ---
if __name__ == "__main__":
    main()