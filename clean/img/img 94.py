import os
import csv
import re
from datetime import datetime
from PIL import Image

# Constants
LAST_DIRECTORY_FILE = 'image_data.txt'

# Function to get the creation date of a file
def get_creation_date(filepath):
    try:
        return datetime.fromtimestamp(os.path.getctime(filepath)).strftime('%m-%d-%y')
    except Exception as e:
        print(f"Error getting creation date for {filepath}: {e}")
        return 'Unknown'

# Function to extract metadata from an image file using PIL
def get_image_metadata(filepath):
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            dpi = img.info.get('dpi', (None, None))  # Extract DPI if available
            dpi_x = dpi[0] if dpi and len(dpi) > 0 else None
            dpi_y = dpi[1] if dpi and len(dpi) > 1 else None
            file_size = os.path.getsize(filepath)
            return width, height, dpi_x, dpi_y, file_size
    except Exception as e:
        print(f"Error getting image metadata for {filepath}: {e}")
        return None, None, None, None, None

# Function to format file size
def format_file_size(size_in_bytes):
    thresholds = [
        (1024 ** 4, 'TB'),
        (1024 ** 3, 'GB'),
        (1024 ** 2, 'MB'),
        (1024 ** 1, 'KB'),
        (1024 ** 0, 'B'),
    ]
    for factor, suffix in thresholds:
        if size_in_bytes >= factor:
            return f"{size_in_bytes / factor:.2f} {suffix}"
    return '0 B'

# Function to generate a CSV for organizing image files
def generate_csv(directories, csv_path):
    rows = []

    # Regex patterns for exclusions
    excluded_patterns = [
        r'^\..*',  # Hidden files and directories
        r'.*\/(venv|\.venv|env|\.env)\/.*',  # Virtual environment directories
        r'.*\/Library\/.*',  # System directories
        r'^.*\/\..*',  # Any file or directory starting with a dot
    ]

    file_types = {
        '.jpg': 'Image',
        '.jpeg': 'Image',
        '.png': 'Image',
        '.bmp': 'Image',
        '.gif': 'Image',
        '.tiff': 'Image',
        '.ai': 'Vector',
        '.dxf': 'Vector',
        '.eps': 'Vector',
        '.pdf': 'Document',
        '.svg': 'Vector',
    }

    for directory in directories:
        for root, dirs, files in os.walk(directory):
            # Skip unwanted directories using regex
            dirs[:] = [d for d in dirs if not any(re.match(pattern, os.path.join(root, d)) for pattern in excluded_patterns)]

            for file in files:
                file_path = os.path.join(root, file)

                # Skip files matching exclusion patterns
                if any(re.match(pattern, file_path) for pattern in excluded_patterns):
                    continue

                file_ext = os.path.splitext(file)[1].lower()

                # Add file to rows if it matches allowed file types
                if file_ext in file_types:
                    creation_date = get_creation_date(file_path)
                    width, height, dpi_x, dpi_y, file_size = get_image_metadata(file_path)
                    formatted_size = format_file_size(file_size)
                    rows.append([file, formatted_size, creation_date, width, height, dpi_x, dpi_y, file_path])

    write_csv(csv_path, rows)

def write_csv(csv_path, rows):
    with open(csv_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Filename', 'File Size', 'Creation Date', 'Width', 'Height', 'DPI_X', 'DPI_Y', 'Original Path'])
        writer.writerows(rows)

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
    with open(LAST_DIRECTORY_FILE, 'w') as file:
        file.write(directory)

def load_last_directory():
    if os.path.exists(LAST_DIRECTORY_FILE):
        with open(LAST_DIRECTORY_FILE, 'r') as file:
            return file.read().strip()
    return None

if __name__ == "__main__":
    last_directory = load_last_directory()

    if last_directory:
        directories = [last_directory]
    else:
        print("No last directory found. Please enter a source directory to scan for image files.")
        source_directory = input("Please enter a source directory to scan for image files: ").strip()
        if os.path.isdir(source_directory):
            directories = [source_directory]
            save_last_directory(source_directory)
        else:
            print(f"'{source_directory}' is not a valid directory. Exiting.")
            exit(1)

    if directories:
        current_date = datetime.now().strftime('%m-%d-%H-%M')
        csv_output_path = os.path.join(os.getcwd(), f'image_data-{current_date}.csv')
        csv_output_path = get_unique_file_path(csv_output_path)

        generate_csv(directories, csv_output_path)
        print(f'Output saved to {csv_output_path}')
    else:
        print("No directories were provided to scan.")
