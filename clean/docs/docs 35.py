import os
import csv
import re
from datetime import datetime
import config  # Import the configuration

# Constants
LAST_DIRECTORY_FILE = "docs.txt"

# Function to get the creation date of a file


def get_creation_date(filepath):
    try:
        return datetime.fromtimestamp(
            os.path.getctime(filepath)).strftime("%m-%d-%y")
    except Exception as e:
        print(f"Error getting creation date for {filepath}: {e}")
        return "Unknown"


# Function to format file size


def format_file_size(size_in_bytes):
    try:
        if size_in_bytes < 1024:
            return f"{size_in_bytes:.2f} B"
        size_in_bytes /= 1024
        if size_in_bytes < 1024:
            return f"{size_in_bytes:.2f} KB"
        size_in_bytes /= 1024
        if size_in_bytes < 1024:
            return f"{size_in_bytes:.2f} MB"
        size_in_bytes /= 1024
        if size_in_bytes < 1024:
            return f"{size_in_bytes:.2f} GB"
        size_in_bytes /= 1024
        return f"{size_in_bytes:.2f} TB"
    except Exception as e:
        print(f"Error formatting file size: {e}")
        return "Unknown"


# Function to generate a dry run CSV for organizing document files


def generate_dry_run_csv(directories, csv_path):
    rows = []

    # Regex patterns for exclusions
    excluded_patterns = [
        r"^\..*",  # Hidden files and directories
        r".*\/venv\/.*",  # venv directories
        r".*\/\.venv\/.*",  # .venv directories
        r".*\/lib\/.*",  # venv directories
        r".*\/\.lib\/.*",  # .venv directories
        r".*\/my_global_venv\/.*",  # venv directories
        r".*\/simplegallery\/.*",
        r".*\/avatararts\/.*",
        r".*\/github\/.*",
        r".*\/Documents\/gitHub\/.*",  # Specific gitHub directory
        r".*\/\.my_global_venv\/.*",  # .venv directories
        r".*\/node\/.*",  # Any directory named node
        r".*\/miniconda3\/.*",
        r".*\/env\/.*",  # env directories
        r".*\/\.env\/.*",  # .env directories
        r".*\/Library\/.*",  # Library directories
        r".*\/\.config\/.*",  # .config directories
        r".*\/\.spicetify\/.*",  # .spicetify directories
        r".*\/\.gem\/.*",  # .gem directories
        r".*\/\.zprofile\/.*",  # .zprofile directories
        r"^.*\/\..*",  # Any file or directory starting with a dot
    ]

    file_types = {
        ".pdf": "Documents",
        ".csv": "Documents",
        ".html": "Documents",
        ".css": "Documents",
        ".js": "Documents",
        ".json": "Documents",
        ".sh": "Documents",
        ".md": "Documents",
        ".txt": "Documents",
        ".doc": "Documents",
        ".docx": "Documents",
        ".ppt": "Documents",
        ".pptx": "Documents",
        ".xlsx": "Documents",
        ".py": "Documents",
        ".xml": "Documents",
    }

    for directory in directories:
        for root, dirs, files in os.walk(directory):
            # Skip hidden directories and system directories using regex
            dirs[:] = [
                d
                for d in dirs
                if not any(
                    re.match(pattern, os.path.join(root, d))
                    for pattern in excluded_patterns
                )
            ]

            for file in files:
                file_path = os.path.join(root, file)

                # Skip files that match the excluded patterns
                if any(re.match(pattern, file_path)
                       for pattern in excluded_patterns):
                    continue

                file_ext = os.path.splitext(file)[1].lower()

                # Add file to rows if it matches the logical file types
                if file_ext in file_types:
                    file_size = format_file_size(os.path.getsize(file_path))
                    creation_date = get_creation_date(file_path)
                    rows.append([file, file_size, creation_date, root])

    write_csv(csv_path, rows)


def write_csv(csv_path, rows):
    with open(csv_path, "w", newline="") as csvfile:
        fieldnames = [
            "Filename",
            "File Size",
            "Creation Date",
            "Original Path"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "Filename": row[0],
                    "File Size": row[1],
                    "Creation Date": row[2],
                    "Original Path": row[3],
                }
            )


def get_unique_file_path(base_path):
    if not os.path.exists(base_path):
        return base_path

    base, ext = os.path.splitext(base_path)
    counter = 1
    while True:
        new_path = f"{base}_{counter}{ext}"
        if not os.path.exists(new_path):
            return new_path
        counter += 1


def save_last_directory(directory):
    with open(LAST_DIRECTORY_FILE, "w") as file:
        file.write(directory)


def load_last_directory():
    if os.path.exists(LAST_DIRECTORY_FILE):
        with open(LAST_DIRECTORY_FILE, "r") as file:
            return file.read().strip()
    return None


if __name__ == "__main__":
    directories = []
    last_directory = load_last_directory()

    while True:
        if last_directory:
            use_last = (
                input(
                    f"Do you want to use the last directory '{last_directory}'? (Y/N): "
                )
                .strip()
                .lower()
            )
            if use_last == "y":
                directories.append(last_directory)
                break
            else:
                source_directory = input(
                    "Please enter a new source directory to scan for document files: "
                ).strip()
        else:
            source_directory = input(
                "Please enter a source directory to scan for document files: "
            ).strip()

        if source_directory == "":
            break
        if os.path.isdir(source_directory):
            directories.append(source_directory)
            save_last_directory(source_directory)
        else:
            print(
                f"'{source_directory}' is not a valid directory. Please try again.")

    if directories:
        current_date = datetime.now().strftime("%m-%d-%H:%M")
        csv_output_path = os.path.join(os.getcwd(), f"docs-{current_date}.csv")
        csv_output_path = get_unique_file_path(csv_output_path)

        generate_dry_run_csv(directories, csv_output_path)
        print(f"Dry run completed. Output saved to {csv_output_path}")
    else:
        print("No directories were provided to scan.")
