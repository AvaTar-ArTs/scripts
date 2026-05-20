#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


urls=(
  "https://suno.com/song/79bf1d33-3abf-47f0-9b25-c3c5c8b37b65"
  "https://suno.com/song/a035afec-9095-46df-ac87-e52291f8ba3b"
  "https://suno.com/song/97c0605b-3d78-47b4-bc88-0ed14153b65f"
  "https://suno.com/song/34fccf32-e357-488c-aac4-38cd9c13a0dd"
  "https://suno.com/song/cf790316-cd5a-493d-8693-5ba1bfe88852"
  "https://suno.com/song/76e60ae3-60af-49f4-bd81-c7bf9835c7bf"
  "https://suno.com/song/887af7e3-9f0c-40b8-b8a2-06e25e411866"
  "https://suno.com/song/c81845e8-af60-4158-8551-9a246e84561e"
  "https://suno.com/song/5bb1194a-5652-432d-976e-48b834ffed05"
  "https://suno.com/song/78d947ab-e9dc-4649-b9c9-d4715c2f3331"
  "https://suno.com/song/b28c50c0-d0fd-4a82-be00-c3e56d3a1cb4"
  "https://suno.com/song/d603ebcc-f778-4409-a9b7-0ebec096c6d3"
  "https://suno.com/song/376a9eb5-4028-46a3-8782-68c92a4fc7a2"
  "https://suno.com/song/dbce4b57-1c99-42ea-a15a-48df37973ecd"
  "https://suno.com/song/93ccad7b-3610-43fd-940d-d56270db9b5f"
  "https://suno.com/song/c65142cb-a266-429d-95de-cc862e119d6d"
  "https://suno.com/song/39ce23de-8c8d-4c19-93bf-75bb82ebaab0"
  "https://suno.com/song/1dfe1581-d2e9-4366-972a-c8f0581307a0"
  "https://suno.com/song/78eb07c3-4dc1-4e7e-a0f0-e4db53230470"
  "https://suno.com/song/2dd27e7b-aa36-4363-b462-f90410479bf7"
  "https://suno.com/song/ba881445-920e-46af-bc14-72a85c5cf81a"
  "https://suno.com/song/994acc06-cd45-4964-a2b6-d027ec8b3dea"
  "https://suno.com/song/2a845f5a-6d78-4f4f-88aa-7764739ad60d"
  "https://suno.com/song/4f5010da-f940-4da3-b7d2-a8356cd2f31d"
  "https://suno.com/song/aaeed504-d15f-430a-ad72-130ef78a1a37"
  "https://suno.com/song/63ab5c9f-105d-41db-9870-f4ea96c18db8"
  "https://suno.com/song/3c0cf4e3-804e-4c02-a0cf-118956ead761"
  "https://suno.com/song/8dd3a6d2-e9af-4675-9e8c-05ea053b2e13"
  "https://suno.com/song/b6407d5c-c66e-4c75-8106-be3eb1f52761"
  "https://suno.com/song/0f160624-1e8f-4aae-aff6-2d81f2f43e19"
  "https://suno.com/song/f02d1503-d641-4258-9051-59166c78fd8e"
  "https://suno.com/song/1dfe1581-d2e9-4366-972a-c8f0581307a0"
  "https://suno.com/song/7e6c186b-1173-4f83-9b00-a13ceabf2e3a"
  "https://suno.com/song/87edfad5-c37b-4419-8e0b-5ed5b4bb3be3"
  "https://suno.com/song/9da2053f-9df4-41d2-b2a9-37a387800f3d"
  "https://suno.com/song/5cafe837-e79c-45f2-9842-6487dfd9a1e9"
  "https://suno.com/song/c1480cde-5e9b-48d9-8812-df02ff059f30"
)

for url in "${urls[@]}"; do
  open "$url"       # Open the URL in the default browser
  echo "Press Enter after closing the tab to continue..."
  read -r           # Wait for user input (Enter key) before proceeding
done
