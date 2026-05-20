import os

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
