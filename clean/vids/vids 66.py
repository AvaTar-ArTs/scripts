import csv
import os
import re
from datetime import datetime

from mutagen.mp4 import MP4

LAST_DIRECTORY_FILE = "vids.txt"

# Function to get the creation date of a file


def get_creation_date(filepath):
    try:
        return datetime.fromtimestamp(os.path.getctime(filepath)).strftime("%m-%d-%y")
    except Exception as e:
        print(f"Error getting creation date for {filepath}: {e}")
        return "Unknown"


# Function to extract metadata from a video file using Mutagen


def get_video_metadata(filepath):
    try:
        file = MP4(filepath)
        duration = file.info.length
        return os.path.getsize(filepath), duration
    except Exception as e:
        print(f"Error getting video metadata for {filepath}: {e}")
    return None, None


# Function to format file size


def format_file_size(size_in_bytes):
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


# Function to format duration in H:M:S or M:S


def format_duration(duration_in_seconds):
    if duration_in_seconds is None:
        return "Unknown"
    try:
        hours = int(duration_in_seconds // 3600)
        minutes = int((duration_in_seconds % 3600) // 60)
        seconds = int(duration_in_seconds % 60)
        if hours > 0:
            return f"{hours}:{minutes:02d}:{seconds:02d}"
        else:
            return f"{minutes}:{seconds:02d}"
    except Exception as e:
        print(f"Error formatting duration: {e}")
        return "Unknown"


# Function to generate a dry run CSV for organizing video files


def generate_dry_run_csv(directories, csv_path):
    rows = []

    # Regex patterns for exclusions
    excluded_patterns = [
        r"^\..*",  # Hidden files and directories
        r".*\/venv\/.*",  # venv directories
        r".*\/\.venv\/.*",  # .venv directories
        r".*\/my_global_venv\/.*",  # venv directories
        r".*\/simplegallery\/.*",
        r".*\/avatararts\/.*",
        r".*\/github\/.*",
        r".*\/Documents\/gitHub\/.*",  # Specific gitHub directory
        r".*\/\.my_global_venv\/.*",  # .venv directories
        r".*\/node\/.*",  # Any directory named node
        r".*\/Movies\/capcut\/.*",
        r".*\/miniconda3\/.*",
        r".*\/Movies\/movavi\/.*",
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
        ".mp4": "Videos",
        ".mkv": "Videos",
        ".mov": "Videos",
        ".avi": "Videos",
        ".wmv": "Videos",
        ".webm": "Videos",
    }

    for directory in directories:
        for root, dirs, files in os.walk(directory):
            # Skip hidden directories and venv directories using regex
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
                if any(re.match(pattern, file_path) for pattern in excluded_patterns):
                    continue

                file_ext = os.path.splitext(file)[1].lower()

                # Add file to rows if it matches the logical file types
                if file_ext in file_types:
                    creation_date = get_creation_date(file_path)
                    file_size, duration = get_video_metadata(file_path)
                    if file_size is None:
                        file_size = "Unknown"
                    else:
                        file_size = format_file_size(file_size)
                    formatted_duration = format_duration(duration)
                    rows.append(
                        [file, formatted_duration, file_size, creation_date, file_path]
                    )

    write_csv(csv_path, rows)


def write_csv(csv_path, rows):
    with open(csv_path, "w", newline="") as csvfile:
        fieldnames = [
            "Filename",
            "Duration",
            "File Size",
            "Creation Date",
            "Original Path",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "Filename": row[0],
                    "Duration": row[1],
                    "File Size": row[2],
                    "Creation Date": row[3],
                    "Original Path": row[4],
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
                    "Please enter a new source directory to scan for video files: "
                ).strip()
        else:
            source_directory = input(
                "Please enter a source directory to scan for video files: "
            ).strip()

        if source_directory == "":
            break
        if os.path.isdir(source_directory):
            directories.append(source_directory)
            save_last_directory(source_directory)
        else:
            print(f"'{source_directory}' is not a valid directory. Please try again.")

    if directories:
        current_date = datetime.now().strftime("%m-%d-%H:%M")
        csv_output_path = os.path.join(os.getcwd(), f"vids-{current_date}.csv")
        csv_output_path = get_unique_file_path(csv_output_path)

        generate_dry_run_csv(directories, csv_output_path)
        print(f"Dry run completed. Output saved to {csv_output_path}")
    else:
        print("No directories were provided to scan.")
