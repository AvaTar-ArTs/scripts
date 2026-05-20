# Load API keys from ~/.env.d/ (best practice - handles export statements, quotes, comments)
import os
import sys
import argparse
from pathlib import Path as PathLib


def load_env_d():
    """Load all .env files from ~/.env.d directory (sophisticated pattern from youtube-load.py)"""
    env_d_path = PathLib.home() / ".env.d"
    if env_d_path.exists():
        for env_file in env_d_path.glob("*.env"):
            try:
                with open(env_file) as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#") and "=" in line:
                            # Handle export statements
                            if line.startswith("export "):
                                line = line[7:]
                            key, value = line.split("=", 1)
                            key = key.strip()
                            value = value.strip().strip('\'').strip("\'")
                            # Skip source statements
                            if not key.startswith("source"):
                                os.environ[key] = value
            except Exception as e:
                # Logger not initialized yet, use print
                print(f"Warning: Error loading {env_file}: {e}")


load_env_d()

# Also load from ~/.env as fallback using dotenv
try:
    from dotenv import load_dotenv
    load_dotenv(os.path.expanduser("~/.env"))
except ImportError:
    pass

# Import AutoTagger system
sys.path.insert(0, str(PathLib.home() / "AutoTagger" / "current"))
try:
    from autotagger import AutoTagger
    AUTOTAGGER_AVAILABLE = True
except ImportError:
    AUTOTAGGER_AVAILABLE = False
    print("Warning: AutoTagger not available - falling back to basic scanning")

# Set up logging
import logging
from typing import Optional, Tuple
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def get_creation_date(filepath: str) -> str:
    try:
        return datetime.fromtimestamp(os.path.getctime(filepath)).strftime("%m-%d-%y")
    except Exception as e:
        logging.error(f"Error getting creation date for {filepath}: {e}")
        return "Unknown"


def format_file_size(size_in_bytes: int) -> str:
    thresholds = [
        (1 << 40, "TB"),
        (1 << 30, "GB"),
        (1 << 20, "MB"),
        (1 << 10, "KB"),
        (1, "B"),
    ]
    for factor, suffix in thresholds:
        if size_in_bytes >= factor:
            return f"{size_in_bytes / factor:.2f} {suffix}"
    return "Unknown"


def format_duration(duration_in_seconds: Optional[float]) -> str:
    if duration_in_seconds is None:
        return "Unknown"
    try:
        hours = int(duration_in_seconds // 3600)
        minutes = int((duration_in_seconds % 3600) // 60)
        seconds = int(duration_in_seconds % 60)
        return (
            f"{hours}:{minutes:02d}:{seconds:02d}"
            if hours > 0
            else f"{minutes}:{seconds:02d}"
        )
    except Exception as e:
        logging.error(f"Error formatting duration: {e}")
        return "Unknown"


def write_csv(csv_path, rows, fieldnames):
    with open(csv_path, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def process_audio_file(filepath: str) -> Optional[Tuple[str, str, str, str, str]]:
    try:
        audio = MP3(filepath, ID3=EasyID3)
        duration = audio.info.length
        file_size = format_file_size(os.path.getsize(filepath))
        creation_date = get_creation_date(filepath)
        return filepath, format_duration(duration), file_size, creation_date, filepath
    except Exception as e:
        logging.error(f"Error processing audio file {filepath}: {e}")
    return None


def process_image_file(filepath: str) -> Optional[Tuple[str, str, str, str, str, str, str, str]]:
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            dpi_x, dpi_y = img.info.get("dpi", (None, None))
            file_size = os.path.getsize(filepath)
            formatted_size = format_file_size(file_size)
            creation_date = get_creation_date(filepath)
            return (
                filepath,
                formatted_size,
                creation_date,
                width,
                height,
                dpi_x,
                dpi_y,
                filepath,
            )
    except Exception as e:
        logging.error(f"Error getting image metadata for {filepath}: {e}")
    return None


def process_video_file(filepath: str) -> Optional[Tuple[str, str, str, str, str]]:
    try:
        file = MP4(filepath)
        duration = file.info.length
        file_size = format_file_size(os.path.getsize(filepath))
        creation_date = get_creation_date(filepath)
        return filepath, format_duration(duration), file_size, creation_date, filepath
    except Exception as e:
        logging.error(f"Error getting video metadata for {filepath}: {e}")
    return None


def process_files(file_types, process_function, directories):
    results = []
    for directory in directories:
        for root, _, files in os.walk(directory):
            for file in files:
                file_ext = os.path.splitext(file)[1].lower()
                if file_ext in file_types:
                    result = process_function(os.path.join(root, file))
                    if result:
                        results.append(result)
    return results


def categorize_script(content, file_name):
    # Similar categorization logic as before
    # Omitted for brevity...
    pass


def suggest_script_titles_batch(file_paths, batch_size=10):
    results = []
    for i in range(0, len(file_paths), batch_size):
        batch_paths = file_paths[i : i + batch_size]
        batch_contents = []
        for file_path in batch_paths:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                    batch_contents.append(content)
            except Exception as e:
                logging.warning(f"Could not read {file_path}: {e}")
                batch_contents.append("")

        if OPENAI_AVAILABLE:
            batch_titles = ["Untitled"] * len(batch_contents)  # Simplification - could use OpenAI here
        else:
            batch_titles = ["Untitled"] * len(batch_contents)

        for file_path, title, content in zip(batch_paths, batch_titles, batch_contents):
            category = categorize_script(content, os.path.basename(file_path)) if content else "Unknown"
            results.append(
                {
                    "File Name": os.path.basename(file_path),
                    "Categories": category,
                    "Suggested Title": title,
                    "Path": file_path,
                }
            )
    return results


def format_file_size(size_in_bytes: int) -> str:
    thresholds = [
        (1 << 40, "TB"),
        (1 << 30, "GB"),
        (1 << 20, "MB"),
        (1 << 10, "KB"),
        (1, "B"),
    ]
    for factor, suffix in thresholds:
        if size_in_bytes >= factor:
            return f"{size_in_bytes / factor:.2f} {suffix}"
    return "Unknown"


def format_duration(duration_in_seconds: Optional[float]) -> str:
    if duration_in_seconds is None:
        return "Unknown"
    try:
        hours = int(duration_in_seconds // 3600)
        minutes = int((duration_in_seconds % 3600) // 60)
        seconds = int(duration_in_seconds % 60)
        return (
            f"{hours}:{minutes:02d}:{seconds:02d}"
            if hours > 0
            else f"{minutes}:{seconds:02d}"
        )
    except Exception as e:
        logging.error(f"Error formatting duration: {e}")
        return "Unknown"


def write_csv(csv_path, rows, fieldnames):
    with open(csv_path, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def get_unique_file_path(base_path: str) -> str:
    if not os.path.exists(base_path):
        return base_path
    base, ext = os.path.splitext(base_path)
    counter = 1
    while True:
        new_path = f"{base}_{counter}{ext}"
        if not os.path.exists(new_path):
            return new_path
        counter += 1


def process_audio_file(filepath: str) -> Optional[Tuple[str, str, str, str, str]]:
    try:
        audio = MP3(filepath, ID3=EasyID3)
        duration = audio.info.length
        file_size = format_file_size(os.path.getsize(filepath))
        creation_date = get_creation_date(filepath)
        return filepath, format_duration(duration), file_size, creation_date, filepath
    except Exception as e:
        logging.error(f"Error processing audio file {filepath}: {e}")
    return None


def process_image_file(filepath: str) -> Optional[Tuple[str, str, str, str, str, str, str, str]]:
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            dpi_x, dpi_y = img.info.get("dpi", (None, None))
            file_size = os.path.getsize(filepath)
            formatted_size = format_file_size(file_size)
            creation_date = get_creation_date(filepath)
            return (
                filepath,
                formatted_size,
                creation_date,
                width,
                height,
                dpi_x,
                dpi_y,
                filepath,
            )
    except Exception as e:
        logging.error(f"Error getting image metadata for {filepath}: {e}")
    return None


def process_video_file(filepath: str) -> Optional[Tuple[str, str, str, str, str]]:
    try:
        file = MP4(filepath)
        duration = file.info.length
        file_size = format_file_size(os.path.getsize(filepath))
        creation_date = get_creation_date(filepath)
        return filepath, format_duration(duration), file_size, creation_date, filepath
    except Exception as e:
        logging.error(f"Error getting video metadata for {filepath}: {e}")
    return None


def process_files(file_types, process_function, directories):
    results = []
    for directory in directories:
        for root, _, files in os.walk(directory):
            for file in files:
                file_ext = os.path.splitext(file)[1].lower()
                if file_ext in file_types:
                    result = process_function(os.path.join(root, file))
                    if result:
                        results.append(result)
    return results


def categorize_script(content, file_name):
    # Similar categorization logic as before
    # Omitted for brevity...
    pass


def suggest_script_titles_batch(file_paths, batch_size=10):
    results = []
    for i in range(0, len(file_paths), batch_size):
        batch_paths = file_paths[i : i + batch_size]
        batch_contents = []
        for file_path in batch_paths:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                    batch_contents.append(content)
            except Exception as e:
                logging.warning(f"Could not read {file_path}: {e}")
                batch_contents.append("")

        if OPENAI_AVAILABLE:
            batch_titles = ["Untitled"] * len(batch_contents)  # Simplification - could use OpenAI here
        else:
            batch_titles = ["Untitled"] * len(batch_contents)

        for file_path, title, content in zip(batch_paths, batch_titles, batch_contents):
            category = categorize_script(content, os.path.basename(file_path)) if content else "Unknown"
            results.append(
                {
                    "File Name": os.path.basename(file_path),
                    "Categories": category,
                    "Suggested Title": title,
                    "Path": file_path,
                }
            )
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Advanced AutoTagger Directory Scanner")
    parser.add_argument("directories", nargs="*", default=["."],
                       help="Directories to scan (default: current directory)")
    parser.add_argument("--prefix", default="all_scan",
                       help="Prefix for output files (default: all_scan)")
    parser.add_argument("--formats", default="csv,md,html",
                       help="Output formats (default: csv,md,html)")
    parser.add_argument("--basic", action="store_true",
                       help="Use basic scanning instead of AutoTagger")

    args = parser.parse_args()

    print(f"🔍 Scanning directories: {args.directories}")
    print(f"📁 Output prefix: {args.prefix}")
    print(f"📄 Output formats: {args.formats}")

    if AUTOTAGGER_AVAILABLE and not args.basic:
        print("🚀 Using Advanced AutoTagger System")
        # Use the advanced AutoTagger system
        tagger = AutoTagger()
        for directory in args.directories:
            if os.path.isdir(directory):
                print(f"📂 Processing: {directory}")
                tagger.run(directory, args.prefix, args.formats.split(','))
            else:
                print(f"⚠️  Skipping invalid directory: {directory}")
        print("✅ AutoTagger scanning complete!")
    else:
        print("📊 Using Basic File Scanner (AutoTagger not available)")
        # Fall back to basic scanning logic
        try:
            from mutagen.easyid3 import EasyID3
            from mutagen.mp3 import MP3
            from PIL import Image
            from mutagen.mp4 import MP4
            import csv
            from typing import Optional, Tuple
            from datetime import datetime
        except ImportError as e:
            print(f"⚠️  Missing dependencies for basic scanning: {e}")
            sys.exit(1)

        # Process different file types with basic scanner
        audio_results = process_files(
            {".mp3", ".wav", ".flac", ".aac", ".m4a"}, process_audio_file, args.directories
        )
        image_results = process_files(
            {".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff"},
            process_image_file,
            args.directories,
        )
        video_results = process_files(
            {".mp4", ".mkv", ".mov", ".avi", ".wmv", ".webm"},
            process_video_file,
            args.directories,
        )

        # Convert tuples to dictionaries for CSV writing
        def tuples_to_dicts(results, fieldnames):
            return [dict(zip(fieldnames, result)) for result in results]

        if audio_results:
            audio_dicts = tuples_to_dicts(audio_results, ["Filename", "Duration", "File Size", "Creation Date", "Original Path"])
            write_csv("audio_output.csv", audio_dicts, ["Filename", "Duration", "File Size", "Creation Date", "Original Path"])
            print(f"Processed {len(audio_results)} audio files")

        if image_results:
            image_dicts = tuples_to_dicts(image_results, ["Filename", "File Size", "Creation Date", "Width", "Height", "DPI_X", "DPI_Y", "Original Path"])
            write_csv("image_output.csv", image_dicts, ["Filename", "File Size", "Creation Date", "Width", "Height", "DPI_X", "DPI_Y", "Original Path"])
            print(f"Processed {len(image_results)} image files")

        if video_results:
            video_dicts = tuples_to_dicts(video_results, ["Filename", "Duration", "File Size", "Creation Date", "Original Path"])
            write_csv("video_output.csv", video_dicts, ["Filename", "Duration", "File Size", "Creation Date", "Original Path"])
            print(f"Processed {len(video_results)} video files")

        # Process Python scripts in batch (scan all directories for .py files)
        script_paths = []
        for directory in args.directories:
            for root, _, files in os.walk(directory):
                for file in files:
                    if file.endswith(".py"):
                        script_paths.append(os.path.join(root, file))

        if script_paths:
            script_results = suggest_script_titles_batch(script_paths)
            # Write script results to CSV in current directory
            output_csv_path = "script_output.csv"
            write_csv(
                output_csv_path,
                script_results,
                ["File Name", "Categories", "Suggested Title", "Path"],
            )
            print(f"Processed {len(script_results)} Python scripts -> {output_csv_path}")
        else:
            print("No Python scripts found")
