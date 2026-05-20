import os

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
                            value = value.strip().strip("'").strip("'")
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

import whisper

import logging

logger = logging.getLogger(__name__)


def transcribe_audio(file_path):
    """transcribe_audio function."""

    # Load the Whisper model
    model = whisper.load_model("base")

    # Transcribe the audio file
    result = model.transcribe(file_path)

    return result["segments"]

    """save_transcription function."""


def save_transcription(segments, output_file):
    with open(output_file, "w") as f:
        for segment in segments:
            start = segment["start"]
            end = segment["end"]
            text = segment["text"]
            f.write(f"[{start:.2f} - {end:.2f}] {text}\n")
    logger.info(f"Transcription saved to {output_file}")

    """process_directory function."""


def process_directory(source_directory):
    for root, _, files in os.walk(source_directory):
        for filename in files:
            if filename.lower().endswith(".mp3"):
                mp3_file = os.path.join(root, filename)
                filename_no_ext = os.path.splitext(filename)[0]
                transcription_file = os.path.join(
                    root, f"{filename_no_ext}_transcription.txt"
                )

                # Transcribe the MP3 file
                segments = transcribe_audio(mp3_file)

                # Save the transcription
                save_transcription(segments, transcription_file)
    """main function."""


def main():
    source_directory = input("Enter the path to the source directory: ")
    if os.path.isdir(source_directory):
        process_directory(source_directory)
    else:
        logger.info(f"The directory {source_directory} does not exist.")


if __name__ == "__main__":
    main()
