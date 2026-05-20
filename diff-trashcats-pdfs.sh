#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Array of PDF files
files=(
  "15-16-29-Raccoon_Alley_Album_Art.pdf"
  "ChatGPT_-_DiGiTaL_DiVe.pdf"
  "Cover_Images.pdf"
  "Covers-typingmind.pdf"
  "in_this_Alley_where_I_hide.pdf"
  "Junkyard_King.pdf"
  "Raccoon_Alley_Album_Art.pdf"
  "Raccoon_Image_Prompts.pdf"
  "USER.html.pdf"
  "trashyc.pdf"
  "trashyc-3.pdf"
  "Trashy_VAlentines_#32.pdf"
  "Trashy_TON.pdf"
  "Trashy_Anti-Valentines_#1.pdf"
  "trashLove.pdf"
  "trashCaTs_-_Music.pdf"
  "trashCaT.pdf"
  "TrashCat-YT-titles.pdf"
  "TrashCaT_Medium_OuTLIne.pdf"
  "TrashCaT_GrungePanda_raccoon_clan_Their_music_is_an_eclectic_mix_of_grunge_punk_rock_and_a_dash_of_glam_trash_Imagine_Nirvana_in_a_back_alley_dumpster_fire_with_RaGe.pdf"
  "TrashCat_CoverArt.pdf"
  "Trash_Panda.pdf"
  "The_image_has_been_created_to_depict_the_menacing_presence_of_the_Vahzilok_and_the_Clockwork_within_a_desolate_cityscape_The_Vahzilok_with_their_dark_cloaks_and_necromantic_powers_stand_as_a_di.pdf"
  "Love_is_RuBBiSh_By_a_TrashCat_Grunge_Raacoon_with.pdf"
  "Live_Fast_East_Trash.pdf"
  "Anti-Valentines_TrashCat_Grunge_Panda_In_an_alley_draped_in_the_spoils_of_a_thousand_dumpster_dives_the_'Heart_Bandit'_sits_atop_its_hoard_the_self-proclaimed_monarch_of_the_urban_underbelly_Wi-collecyion.pdf"
  "aiMuic-Trash.pdf"
)

# Base directory for the PDFs
base_dir="/Users/steven/Documents/pdfs/TrashCaTs"

# Compare each file with the next one in the array
for ((i=0; i<${#files[@]}-1; i++)); do
  file1="$base_dir/${files[$i]}"
  file2="$base_dir/${files[$i+1]}"
  output="$base_dir/diff_${files[$i]%.pdf}_${files[$i+1]%.pdf}.pdf"
  diff-pdf --output-diff="$output" "$file1" "$file2"
done
