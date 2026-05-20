import os
import csv
import hashlib
from collections import defaultdict
import pandas as pd
import re
from datetime import datetime
from PIL import Image


def is_excluded(path, patterns):
    """
    Check if a given path matches any of the exclusion patterns.

    Parameters:
    path (str): The path to check.
    patterns (list): A list of regex patterns for exclusion.

    Returns:
    bool: True if path matches any pattern, False otherwise.
    """
    for pattern in patterns:
        if re.search(pattern, path):
            return True
    return False


def compute_md5(file_path):
    """
    Compute the MD5 hash of a file.

    Parameters:
    file_path (str): The path to the file.

    Returns:
    str: The MD5 hash of the file.
    """
    hash_md5 = hashlib.md5()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except Exception as e:
        print(f"Error computing hash for {file_path}: {e}")
        return None


def normalize_file_size(size_str):
    '\''
    Convert file size strings to kilobytes.

    Parameters:
    size_str (str): The file size string, e.g., '110.00 B', '5.70 KB'.

    Returns:
    float: The file size in kilobytes.
    """
    size, unit = size_str.split()
    size = float(size)
    if unit == "B":
        return size / 1024  # Convert bytes to kilobytes
    elif unit == "KB":
        return size
    elif unit == "MB":
        return size * 1024  # Convert megabytes to kilobytes
    elif unit == "GB":
        return size * 1024 * 1024  # Convert gigabytes to kilobytes
    elif unit == "TB":
        return size * 1024 * 1024 * 1024  # Convert terabytes to kilobytes
    else:
        return size  # In case of unexpected unit, return size as is


def get_creation_date(filepath):
    """
    Get the creation date of a file.

    Parameters:
    filepath (str): The path to the file.

    Returns:
    str: The creation date of the file in MM-DD-YY format.
    """
    try:
        return datetime.fromtimestamp(os.path.getctime(filepath)).strftime("%m-%d-%y")
    except Exception as e:
        print(f"Error getting creation date for {filepath}: {e}")
        return "Unknown"


def get_image_metadata(filepath):
    """
    Extract metadata from an image file using PIL.

    Parameters:
    filepath (str): The path to the image file.

    Returns:
    tuple: The width, height, DPI X, DPI Y, and file size of the image.
    """
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            dpi = img.info.get("dpi", (None, None))  # Extract DPI if available
            dpi_x = dpi[0] if dpi and len(dpi) > 0 else None
            dpi_y = dpi[1] if dpi and len(dpi) > 1 else None
            file_size = os.path.getsize(filepath)
            return width, height, dpi_x, dpi_y, file_size
    except Exception as e:
        print(f"Error getting image metadata for {filepath}: {e}")
        return None, None, None, None, None


def format_file_size(size_in_bytes):
    """
    Format file size in bytes to a human-readable string.

    Parameters:
    size_in_bytes (int): The file size in bytes.

    Returns:
    str: The formatted file size.
    """
    try:
        thresholds = [
            (1024**4, "TB"),
            (1024**3, "GB"),
            (1024**2, "MB"),
            (1024**1, "KB"),
            (1024**0, "B"),
        ]
        for factor, suffix in thresholds:
            if size_in_bytes >= factor:
                break
        return f"{size_in_bytes / factor:.2f} {suffix}"
    except Exception as e:
        print(f"Error formatting file size: {e}")
        return "Unknown"


def generate_detailed_duplicate_report(csv_files, output_csv_path, excluded_patterns):
    """
    Generate a detailed duplicate report containing all file paths,
    their MD5 hashes, and duplicate counts from the specified CSV files.

    Parameters:
    csv_files (list): List of CSV file paths to process.
    output_csv_path (str): Path to the output CSV file.
    excluded_patterns (list): List of regex patterns for exclusion.
    """
    file_hash_map = defaultdict(list)

    for csv_file in csv_files:
        df = pd.read_csv(csv_file)
        for index, row in df.iterrows():
            file_path = row["Original Path"]
            if not is_excluded(file_path, excluded_patterns):
                file_hash = compute_md5(file_path)
                if file_hash:
                    file_hash_map[file_hash].append(
                        {
                            "file_path": file_path,
                            "file_name": row["Filename"],
                            "file_size": row["File Size"],
                            "creation_date": row["Creation Date"],
                            "width": row["Width"],
                            "height": row["Height"],
                            "dpi_x": row["DPI_X"],
                            "dpi_y": row["DPI_Y"],
                        }
                    )

    rows = []
    for file_hash, details in file_hash_map.items():
        for detail in details:
            rows.append(
                [
                    detail["file_path"],
                    detail["file_name"],
                    detail["file_size"],
                    detail["creation_date"],
                    detail["width"],
                    detail["height"],
                    detail["dpi_x"],
                    detail["dpi_y"],
                    file_hash,
                    len(details),
                ]
            )

    with open(output_csv_path, "w", newline="") as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(
            [
                "File Path",
                "Filename",
                "File Size",
                "Creation Date",
                "Width",
                "Height",
                "DPI_X",
                "DPI_Y",
                "MD5 Hash",
                "Duplicate Count",
            ]
        )
        csv_writer.writerows(rows)

    print(f"CSV output written to {output_csv_path}")


def prompt_for_csv_files():
    """
    Prompt user for CSV file paths until they are done.

    Returns:
    list: A list of CSV file paths provided by the user.
    '\''
    csv_files = []
    while True:
        csv_input = input("Enter a CSV file path (or 'N' to finish): ").strip()
        if csv_input.lower() == "n":
            if csv_files:
                verify = (
                    input(
                        f"Do you want to add '{csv_files[-1]}' as the last CSV file? (Y/N): "
                    )
                    .strip()
                    .lower()
                )
                if verify == "y":
                    print("CSV file list completed.")
                    break
                else:
                    csv_files.pop()
                    print(f"Removed last CSV file. Current list: {csv_files}")
            else:
                print("No CSV files were added. Exiting setup.")
                break
        else:
            csv_files.append(csv_input)
            print(f"Added: {csv_input}")
            print(f"Current list: {csv_files}")
    return csv_files


# Regex patterns for exclusions
excluded_patterns = [
    r"^\..*",  # Hidden files and directories
    r".*/venv/.*",  # venv directories
    r".*/\.venv/.*",  # .venv directories
    r".*/my_global_venv/.*",  # Specific venv directory
    r".*/simplegallery/.*",  # Simplegallery directories
    r".*/avatararts/.*",  # Avatararts directories
    r".*/github/.*",  # General github directories
    r".*/Documents/gitHub/.*",  # Specific gitHub directory in Documents
    r".*/\.my_global_venv/.*",  # .my_global_venv directories
    r".*/node/.*",  # Any directory named node
    r".*/Movies/CapCut/.*",  # CapCut directories in Movies
    r".*/miniconda3/.*",  # Miniconda3 directories
    r".*/miniconda3.bak/.*",  # Miniconda3 backup directories
    r".*/Movies/movavi/.*",  # Movavi directories in Movies
    r".*/env/.*",  # env directories
    r".*/\.env/.*",  # .env directories
    r".*/Library/.*",  # Library directories
    r".*/\.config/.*",  # .config directories
    r".*/\.spicetify/.*",  # .spicetify directories
    r".*/\.gem/.*",  # .gem directories
    r".*/\.zprofile/.*",  # .zprofile directories
    r"^.*\/\..*",  # Any file or directory starting with a dot (hidden files)
    r".*/Desktop/.*",  # Desktop directories
    r".*/Downloads/.*",  # Downloads directories
    r".*/Documents/.*",  # Documents directories
    r".*/Pictures/.*",  # Pictures directories
    r".*/Music/.*",  # Music directories
]

# Prompt user for CSV files until they are done
csv_files = prompt_for_csv_files()

# Check if CSV files list is non-empty before generating the report
if csv_files:
    output_csv_path = "detailed_duplicate_report.csv"
    generate_detailed_duplicate_report(csv_files, output_csv_path, excluded_patterns)
else:
    print("No CSV files provided. Exiting.")
