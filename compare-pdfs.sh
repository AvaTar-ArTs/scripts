#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing your PDF files
pdf_dir="/Users/steven/Documents/pdfs/TrashCaTs"

# List of PDF files
files=(
    "15-16-29-Raccoon_Alley_Album_Art.pdf"
    "alleywhereihide.pdf"
    "Anti-Valentines TrashCat Grunge Panda In an alley draped in the spoils of a thousand dumpster dives, the 'Heart Bandit' sits atop its hoard, the self-proclaimed monarch of the urban underbelly. Wi-collecyion.pdf"
    "Bite in the Night.pdf"
    "ChatGPT - DiGiTaL DiVe.pdf"
    "Junkyard King.pdf"
    "Live Fast East Trash.pdf"
    "Love is RuBBiSh By a TrashCat Grunge Raacoon with.pdf"
    "Raccoon Alley Album Art (optimized).pdf"
    "Raccoon Image Prompts.pdf"
    "Trash Panda.pdf"
    "TrashCat CoverArt.pdf"
    "TrashCaT GrungePanda raccoon clan! Their music is an eclectic mix of grunge, punk rock, and a dash of glam trash. Imagine Nirvana in a back alley dumpster fire with RaGe.pdf"
    "TrashCaT Medium OuTLIne.pdf"
    "TrashCat-YT-titles.pdf"
    "trashCaT.pdf"
    "trashCaTs - Music.pdf"
    "trashLove.pdf"
    "Trashy VAlentines #32.pdf"
    "trashyc-3.pdf"
    "trashyc.pdf"
    "USER.html.pdf"
)

# Function to compare PDFs using diff-pdf
compare_pdfs() {
    local file1="$1"
    local file2="$2"
    local output="$3"
    
    diff-pdf --output-diff="$output" "$file1" "$file2"
}

# Iterate over the PDF files and compare them
for ((i=0; i<${#files[@]}-1; i++)); do
    file1="$pdf_dir/${files[$i]}"
    file2="$pdf_dir/${files[$i+1]}"
    output="$pdf_dir/diff_${files[$i]%.pdf}_${files[$i+1]%.pdf}.pdf"
    
    # Create a directory for the diff output if it doesn't exist
    mkdir -p "$pdf_dir/diffs"
    output="$pdf_dir/diffs/diff_${files[$i]%.pdf}_${files[$i+1]%.pdf}.pdf"
    
    compare_pdfs "$file1" "$file2" "$output"
done
