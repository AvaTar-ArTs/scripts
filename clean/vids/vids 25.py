#!/usr/bin/env python3
"""
Video File Organizer and Metadata Extractor

This script scans directories for video files and generates a CSV report
with metadata including file size, duration, creation date, and file path.
It supports various video formats and excludes common system directories.

Features:
- Async processing support
- Caching for performance
- Comprehensive error handling
- Logging support
- Type hints
- Configuration management
"""

# =========================
# Imports
# =========================

import asyncio
import csv
import html
import json
import logging
import os
import re
import sys
import threading
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from functools import lru_cache, wraps
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple, Union

import aiohttp
from mutagen.easymp4 import EasyMP4
from mutagen.mp4 import MP4

# =========================
# Logging Configuration
# =========================

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# =========================
# Constants & Config
# =========================

DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
ERROR_MESSAGE = "An error occurred"
SUCCESS_MESSAGE = "Operation completed successfully"
LAST_DIRECTORY_FILE = "vids.txt"


@dataclass
class Config:
    """Global configuration variables."""

    DPI_300 = 300
    DPI_72 = 72
    KB_SIZE = 1024
    MB_SIZE = 1024 * 1024
    GB_SIZE = 1024 * 1024 * 1024
    DEFAULT_TIMEOUT = 30
    MAX_RETRIES = 3
    DEFAULT_BATCH_SIZE = 100
    MAX_FILE_SIZE = 9 * 1024 * 1024  # 9MB
    DEFAULT_QUALITY = 85
    DEFAULT_WIDTH = 1920
    DEFAULT_HEIGHT = 1080


# =========================
# Decorators
# =========================


def timing_decorator(func):
    """Decorator to measure function execution time."""

    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start_time
        logger.info(f"{func.__name__} executed in {elapsed:.2f} seconds")
        return result

    return wrapper


def retry_decorator(max_retries=3):
    """Decorator to retry function on failure."""

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    logger.warning(f"Attempt {attempt + 1} failed: {e}")
                    if attempt == max_retries - 1:
                        raise e
            return None

        return wrapper

    return decorator


def memoize(func):
    """Memoization decorator."""
    cache = {}

    @wraps(func)
    def wrapper(*args, **kwargs):
        key = str(args) + str(kwargs)
        if key not in cache:
            cache[key] = func(*args, **kwargs)
        return cache[key]

    return wrapper


# =========================
# Abstract Base Classes
# =========================


@dataclass
class BaseProcessor(ABC):
    """Abstract base class for processors."""

    @abstractmethod
    def process(self, data: Any) -> Any:
        pass

    @abstractmethod
    def validate(self, data: Any) -> bool:
        pass


# =========================
# Singleton Metaclass
# =========================


class SingletonMeta(type):
    """Thread-safe singleton metaclass."""

    _instances = {}
    _lock = threading.Lock()

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            with cls._lock:
                if cls not in cls._instances:
                    cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


# =========================
# Utility Functions
# =========================


def sanitize_html(html_content: str) -> str:
    """Sanitize HTML content to prevent XSS."""
    return html.escape(html_content)


def validate_input(data: Dict[str, Any], validators: Dict[str, Callable]) -> bool:
    """Validate input data."""
    for field, validator in validators.items():
        if field in data and not validator(data[field]):
            raise ValueError(f"Invalid {field}: {data[field]}")
    return True


# =========================
# Async HTTP Utilities
# =========================


async def async_request(url: str, session: aiohttp.ClientSession) -> Optional[str]:
    """Async HTTP request."""
    try:
        async with session.get(url) as response:
            return await response.text()
    except Exception as e:
        logger.error(f"Async request failed: {e}")
        return None


async def process_urls(urls: List[str]) -> List[Optional[str]]:
    """Process multiple URLs asynchronously."""
    async with aiohttp.ClientSession() as session:
        tasks = [async_request(url, session) for url in urls]
        return await asyncio.gather(*tasks)


# =========================
# File & Video Metadata Utilities
# =========================


@lru_cache(maxsize=128)
@timing_decorator
def get_creation_date(filepath: str) -> str:
    """Get the creation date of a file."""
    try:
        ts = os.path.getctime(filepath)
        return datetime.fromtimestamp(ts).strftime("%m-%d-%y")
    except (ValueError, TypeError, RuntimeError) as e:
        logger.error(f"Specific error occurred: {e}")
        raise
    except Exception as e:
        logger.info(f"Error getting creation date for {filepath}: {e}")
        return "Unknown"


@lru_cache(maxsize=128)
@timing_decorator
def get_video_metadata(filepath: str) -> Tuple[Optional[int], Optional[float]]:
    """Extract metadata from a video file using Mutagen."""
    try:
        file = MP4(filepath)
        duration = file.info.length
        size = os.path.getsize(filepath)
        return size, duration
    except (ValueError, TypeError, RuntimeError) as e:
        logger.error(f"Specific error occurred: {e}")
        raise
    except Exception as e:
        logger.info(f"Error getting video metadata for {filepath}: {e}")
        return None, None


@lru_cache(maxsize=128)
@timing_decorator
def format_file_size(size_in_bytes: int) -> str:
    """Format file size human-readably."""
    try:
        thresholds = [
            (Config.KB_SIZE**4, "TB"),
            (Config.KB_SIZE**3, "GB"),
            (Config.KB_SIZE**2, "MB"),
            (Config.KB_SIZE**1, "KB"),
            (Config.KB_SIZE**0, "B"),
        ]
        for factor, suffix in thresholds:
            if size_in_bytes >= factor:
                break
        return f"{size_in_bytes / factor:.2f} {suffix}"
    except (ValueError, TypeError, RuntimeError) as e:
        logger.error(f"Specific error occurred: {e}")
        raise
    except Exception as e:
        logger.info(f"Error formatting file size: {e}")
        return "Unknown"


@lru_cache(maxsize=128)
@timing_decorator
def format_duration(duration_in_seconds: Optional[float]) -> str:
    """Format duration in H:M:S or M:S format."""
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
    except (ValueError, TypeError, RuntimeError) as e:
        logger.error(f"Specific error occurred: {e}")
        raise
    except Exception as e:
        logger.info(f"Error formatting duration: {e}")
        return "Unknown"


# =========================
# Core: CSV/Gather/Scan
# =========================


@retry_decorator(max_retries=3)
def generate_dry_run_csv(directories: List[str], csv_path: str) -> None:
    """Generate a dry run CSV report for organizing video files."""
    rows = []

    # Patterns to exclude
    excluded_patterns = [
        r"^\..*",
        r".*\/venv\/.*",
        r".*\/\.venv\/.*",
        r".*\/my_global_venv\/.*",
        r".*\/\.my_global_venv\/.*",
        r".*\/env\/.*",
        r".*\/\.env\/.*",
        r".*\/node\/.*",
        r".*\/simplegallery\/.*",
        r".*\/avatararts\/.*",
        r".*\/github\/.*",
        r".*\/Documents\/gitHub\/.*",
        r".*\/Movies\/capcut\/.*",
        r".*\/miniconda3\/.*",
        r".*\/Movies\/movavi\/.*",
        r".*\/Library\/.*",
        r".*\/\.config\/.*",
        r".*\/\.spicetify\/.*",
        r".*\/\.gem\/.*",
        r".*\/\.zprofile\/.*",
        r"^.*\/\..*",
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
        logger.info(f"Scanning directory: {directory}")
        for root, dirs, files in os.walk(directory):
            # Filter hidden/system directories out
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
                if any(re.match(pattern, file_path) for pattern in excluded_patterns):
                    continue
                file_ext = os.path.splitext(file)[1].lower()
                if file_ext in file_types:
                    creation_date = get_creation_date(file_path)
                    file_size, duration = get_video_metadata(file_path)
                    file_size_display = (
                        format_file_size(file_size)
                        if file_size is not None
                        else "Unknown"
                    )
                    formatted_duration = format_duration(duration)
                    rows.append(
                        [
                            file,
                            formatted_duration,
                            file_size_display,
                            creation_date,
                            file_path,
                        ]
                    )

    write_csv(csv_path, rows)


def write_csv(csv_path: str, rows: List[List[str]]) -> None:
    """Write data to CSV file."""
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


def get_unique_file_path(base_path: str) -> str:
    """Get a unique file path by appending a counter if file exists."""
    if not os.path.exists(base_path):
        return base_path
    base, ext = os.path.splitext(base_path)
    counter = 1
    while True:
        new_path = f"{base}_{counter}{ext}"
        if not os.path.exists(new_path):
            return new_path
        counter += 1


def save_last_directory(directory: str) -> None:
    """Save the last used directory to file."""
    with open(LAST_DIRECTORY_FILE, "w") as file:
        file.write(directory)


def load_last_directory() -> Optional[str]:
    """Load the last used directory from file."""
    if os.path.exists(LAST_DIRECTORY_FILE):
        with open(LAST_DIRECTORY_FILE, "r") as file:
            return file.read().strip()
    return None


# =========================
# Async Wraps for Core
# =========================


async def async_generate_dry_run_csv(directories: List[str], csv_path: str) -> None:
    """Async version of generate_dry_run_csv."""
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, generate_dry_run_csv, directories, csv_path)


async def async_write_csv(csv_path: str, rows: List[List[str]]) -> None:
    """Async version of write_csv."""
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, write_csv, csv_path, rows)


# =========================
# Main Application Entry
# =========================


def prompt_for_directories() -> List[str]:
    """Prompt user for source directories interactively."""
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
            logger.info(
                f"'{source_directory}' is not a valid directory. Please try again."
            )
    return directories


def main():
    """Main function to run the video file organizer."""
    directories = prompt_for_directories()
    if directories:
        current_date = datetime.now().strftime("%m-%d-%H:%M")
        csv_output_path = os.path.join(os.getcwd(), f"vids-{current_date}.csv")
        csv_output_path = get_unique_file_path(csv_output_path)
        generate_dry_run_csv(directories, csv_output_path)
        logger.info(f"Dry run completed. Output saved to {csv_output_path}")
    else:
        logger.info("No directories were provided to scan.")


async def async_main():
    """Async version of main function."""
    directories = prompt_for_directories()
    if directories:
        current_date = datetime.now().strftime("%m-%d-%H:%M")
        csv_output_path = os.path.join(os.getcwd(), f"vids-{current_date}.csv")
        csv_output_path = get_unique_file_path(csv_output_path)
        await async_generate_dry_run_csv(directories, csv_output_path)
        logger.info(f"Dry run completed. Output saved to {csv_output_path}")
    else:
        logger.info("No directories were provided to scan.")


# =========================
# Script Entrypoint
# =========================

if __name__ == "__main__":
    # Check if async mode is requested
    if len(sys.argv) > 1 and sys.argv[1] == "--async":
        asyncio.run(async_main())
    else:
        main()
