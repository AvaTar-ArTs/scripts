#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Base directory
BASE_DIR="/Users/steven/Downloads/Batch-Mockup-Smart-Object-Replacement-photoshop-script-master"

# Directories and files to be created
PATHS=(
"Examples"
"Examples/example-1"
"Examples/example-1/assets"
"Examples/example-1/assets/_input files"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/deadline-ui-kit.url"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_02.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_05.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_06.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_07.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_09.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_11.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_12.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Login_13.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_03.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_05.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_06.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_08.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_10.jpg"
"Examples/example-1/assets/_input files/phone-screens/Deadline UI Kit/Welcome_13.jpg"
"Examples/example-1/assets/_input files/photos-1"
"Examples/example-1/assets/_input files/photos-2"
"Examples/example-1/assets/_input files/photos-3"
"Examples/example-1/assets/Bus Stop Billboard MockUp"
"Examples/example-1/assets/Bus Stop Billboard MockUp/Bus Stop Billboard MockUp.psd"
"Examples/example-1/assets/Bus Stop Billboard MockUp/Help.pdf"
"Examples/example-1/assets/Bus Stop Billboard MockUp/License.txt"
"Examples/example-1/assets/Mug PSD MockUp 2"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug/Logo 1.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug/Logo 2.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug/Logo 15.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug/Logo 20.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/black-mug/source.url"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/white-mug"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/white-mug/Logo 1.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/white-mug/Logo 2.png"
"Examples/example-1/assets/Mug PSD MockUp 2/_input files/white-mug/source.url"
"Examples/example-1/assets/Mug PSD MockUp 2/Help.pdf"
"Examples/example-1/assets/Mug PSD MockUp 2/License.txt"
"Examples/example-1/assets/Mug PSD MockUp 2/Mug PSD MockUp 2.psd"
"Examples/example-1/assets/Web Showcase Project Presentation"
"Examples/example-1/assets/Web Showcase Project Presentation/license-README-FIRST.txt"
"Examples/example-1/assets/Web Showcase Project Presentation/preview.jpg"
"Examples/example-1/assets/Web Showcase Project Presentation/Text Font.txt"
"Examples/example-1/assets/Web Showcase Project Presentation/Web-Showcase-Project-Presentation.psd"
"Examples/example-1/Batch replace - example 1.jsx"
"Examples/example-1 (output)"
"Examples/example-1 (output)/Bus Stop Billboard MockUp"
"Examples/example-1 (output)/Mug PSD MockUp 2"
"Examples/example-1 (output)/Web-Showcase-Project-Presentation"
"Examples/example-2"
"Examples/example-2/_input files"
"Examples/example-2/Modern Poster Mockup #10"
"Examples/example-2/Modern Poster Mockup #10/follow.url"
"Examples/example-2/Modern Poster Mockup #10/License.txt"
"Examples/example-2/Modern Poster Mockup #10/Mockup.psd"
"Examples/example-2/Batch replace - example 2.jsx"
"Examples/example-2 (output)"
"Examples/example-2 (output)/Bus Stop Billboard MockUp"
"Examples/example-2 (output)/Mockup"
"script"
"script/Batch Mockup Smart Object Replacement.gif
"script/Batch Mockup Smart Object Replacement.jsx"
.gitattributes"
"name"
"readme.md"
)

# Create the directories and files
for path in "${PATHS[@]}"; do
    full_path="$BASE_DIR/$path"
    if [[ $path == *"/"* && ! $path == *"."* ]]; then
        mkdir -p "$full_path"
    else
        touch "$full_path"
    fi
done

echo "Structure created successfully!"
