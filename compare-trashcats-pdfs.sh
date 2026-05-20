#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing your PDF files
pdf_dir="/Users/steven/Documents/pdfs/TrashCaTs"

# List of PDF files
files=(
    "15-16-29-Raccoon_Alley_Album_Art.pdf"
    "aiMuic-Trash.pdf"
    "alleywhereihide.pdf"
    "Anti-Valentines TrashCat Grunge Panda In an alley draped in the spoils of a thousand dumpster dives, the 'Heart Bandit' sits atop its hoard, the self-proclaimed monarch of the urban underbelly. Wi-collecyion.pdf"
    "Bite in the Night.pdf"
    "ChatGPT - DiGiTaL DiVe.pdf"
    "Cover Images.pdf"
    "Covers-typingmind.pdf"
    "in this Alley where I hide.pdf"
    "Junkyard King.pdf"
    "Live Fast East Trash.pdf"
    "Love is RuBBiSh By a TrashCat Grunge Raacoon with.pdf"
    "Raccoon Alley Album Art (optimized).pdf"
    "Raccoon Alley Album Art.pdf"
    "Raccoon Image Prompts.pdf"
    "The image has been created to depict the menacing presence of the Vahzilok and the Clockwork within a desolate cityscape. The Vahzilok, with their dark cloaks and necromantic powers, stand as a di.pdf"
    "Trash Panda.pdf"
    "TrashCat CoverArt.pdf"
    "TrashCaT GrungePanda raccoon clan! Their music is an eclectic mix of grunge, punk rock, and a dash of glam trash. Imagine Nirvana in a back alley dumpster fire with RaGe.pdf"
    "TrashCaT Medium OuTLIne.pdf"
    "TrashCat-YT-titles.pdf"
    "trashCaT.pdf"
    "trashCaTs - Music.pdf"
    "trashLove.pdf"
    "Trashy Anti-Valentines #1.pdf"
    "Trashy TON.pdf"
    "Trashy VAlentines #32.pdf"
    "trashyc-3.pdf"
    "trashyc.pdf"
    "USER.html.pdf"
)

# Function to convert PDFs to text and compare
compare_pdfs_text() {
    local file1="$1"
    local file2="$2"
    
    pdftotext "$file1" "${file1%.pdf}.txt"
    pdftotext "$file2" "${file2%.pdf}.txt"
    
    diff "${file1%.pdf}.txt" "${file2%.pdf}.txt"
}

# Function to extract images and compare
compare_pdfs_images() {
    local file1="$1"
    local file2="$2"
    local base1="${file1%.pdf}"
    local base2="${file2%.pdf}"
    
    mkdir -p "$base1"
    mkdir -p "$base2"
    
    pdfimages -all "$file1" "$base1/image"
    pdfimages -all "$file2" "$base2/image"
    
    compare "${base1}/image-000.png" "${base2}/image-000.png" "${base1}_vs_${base2}_diff.png"
}

# Example usage
compare_pdfs_text "$pdf_dir/15-16-29-Raccoon_Alley_Album_Art.pdf" "$pdf_dir/alleywhereihide.pdf"
compare_pdfs_images "$pdf_dir/15-16-29-Raccoon_Alley_Album_Art.pdf" "$pdf_dir/alleywhereihide.pdf"
