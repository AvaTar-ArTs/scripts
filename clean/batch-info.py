# Load API keys from ~/.env.d/ (best practice - handles export statements, quotes, comments)
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

import os

from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
import csv
import re
import subprocess

from dotenv import load_dotenv

# Load environment variables from the specified .env file
load_dotenv("/Users/steven/Documents/python/.env")

# Set OpenAI API key from the environment variable


# Function to categorize scripts based on content
def categorize_script(content, file_name):
    if "image" in content.lower() or "convert" in file_name.lower():
        return "Image Conversion and Upscaling Script"
    if "backup" in content.lower() or "autopep8" in content.lower():
        return "File Backup and Autopep8 Formatting"
    if "scan" in content.lower() or "directory" in content.lower():
        return "Directory Scan for Large Images"
    if (
        "cleanup" in content.lower()
        or "virtualenv" in content.lower()
        or "venv" in content.lower()
    ):
        return "Virtual Environment Cleanup Manager"
    if "google" in content.lower() or "drive" in content.lower():
        return "Google Drive Link Converter"
    if "quiz" in file_name.lower():
        if "tts" in file_name.lower():
            return "Trivia Quiz Generator"
        else:
            return "Image Upscaling and YouTube Content Generator"
    if "vance" in file_name.lower() or "ai" in content.lower():
        return "Image Upscaling with Vance AI API"
    if "speech" in content.lower() or "text-to-speech" in content.lower():
        return "Text-to-Speech Speech Generation"
    if "transcribe" in content.lower() or "audio" in content.lower():
        return "Speech Transcription"
    if "analyze" in content.lower() or "lyrics" in content.lower():
        return "Lyrics Analyzer Assistant"

    # Default category if none matched
    return "General Script"


# Function to generate documentation using pydocgen
def generate_pydocgen(file_path):
    try:
        # Generate documentation using the pydocgen command-line tool
        result = subprocess.run(["pydocgen", file_path], capture_output=True, text=True)
        # Return the generated documentation if successful
        if result.returncode == 0:
            return result.stdout
        else:
            print(f"pydocgen failed for {file_path}: {result.stderr}")
            return "Documentation generation failed"
    except Exception as e:
        print(f"Error generating documentation for {file_path}: {e}")
        return "Documentation generation failed"


# Function to get script titles using OpenAI API
def get_openai_batch_titles(script_contents):
    if not openai.api_key:
        raise ValueError(
            "OpenAI API key is missing. Make sure it's set in the .env file."
        )

    # Prepare messages for the batch request
    messages = [
        {
            "role": "system",
            "content": "You are an expert Python programmer. Suggest appropriate titles for the following scripts.",
        },
        {
            "role": "user",
            "content": "\n\n".join(
                f"Script {i + 1}:\n{content[:1000]}"
                for i, content in enumerate(script_contents)
            ),
        },
    ]

    try:
        # Make the batch request to OpenAI
        response = client.chat.completions.create(
            model="gpt-3.5-turbo", messages=messages, max_tokens=300
        )

        # Parse the response to extract the titles for each script
        response_text = response.choices[0].message.content.strip()
        titles = []

        # Process each line of the response text to extract titles
        for i, line in enumerate(response_text.split("\n")):
            line = line.strip()
            if line and re.match(
                r"\d+\.", line
            ):  # Look for lines that start with a number followed by a dot
                titles.append(line)
            else:
                titles.append(f"{i + 1}. Untitled")

        if len(titles) < len(script_contents):
            titles.extend(
                [f"{i + 1}. Untitled" for i in range(len(titles), len(script_contents))]
            )

        return titles
    except Exception as e:
        print(f"Error during batch processing: {e}")
        return [f"{i + 1}. Untitled" for i in range(len(script_contents))]


# Function to process files in batches and get their details
def suggest_script_titles_batch(file_paths, batch_size=10):
    results = []

    for i in range(0, len(file_paths), batch_size):
        batch_paths = file_paths[i : i + batch_size]
        batch_contents = []

        # Read each file in the batch
        for file_path in batch_paths:
            try:
                with open(file_path, "r", encoding="utf-8") as file:
                    content = file.read()
                batch_contents.append(content)
            except Exception as e:
                print(f"Error reading {file_path}: {e}")
                batch_contents.append("")

        # Get titles from OpenAI
        batch_titles = get_openai_batch_titles(batch_contents)

        # Get file details
        for file_path, title, content in zip(batch_paths, batch_titles, batch_contents):
            category = categorize_script(content, os.path.basename(file_path))
            documentation = generate_pydocgen(file_path)
            results.append(
                {
                    "File Name": os.path.basename(file_path),
                    "Categories": category,
                    "Suggested Title": title,
                    "Documentation": documentation,
                    "Path": file_path,
                }
            )
            # Print in the preferred format
            print(f"Suggested category for {os.path.basename(file_path)}: {category}")
            print(f"Suggested title for {os.path.basename(file_path)}: {title}")

    return results


# Function to scan a directory for .py files and output the results to a CSV
def process_directory_with_batching(:
    directory_path, batch_size=10, output_csv="output.csv"
):
    file_paths = [
        os.path.join(root, file)
        for root, _, files in os.walk(directory_path)
        for file in files
        if file.endswith(".py")
    ]

    if not file_paths:
        print("No Python files found in the specified directory.")
        return

    results = suggest_script_titles_batch(file_paths, batch_size=batch_size)

    # Write results to CSV
    with open(output_csv, "w", newline="", encoding="utf-8") as csvfile:
        fieldnames = [
            "File Name",
            "Categories",
            "Suggested Title",
            "Documentation",
            "Path",
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for result in results:
            writer.writerow(result)

    print(f"Results have been written to {output_csv}")


# Example usage
if __name__ == "__main__":
    directory_path = "/Users/steven/Documents/python/clean"  # Your target directory
    batch_size = 10  # Number of scripts to process at a time
    output_csv = "/Users/steven/Documents/python/output.csv"  # Output CSV file path

    process_directory_with_batching(
        directory_path, batch_size=batch_size, output_csv=output_csv
    )
