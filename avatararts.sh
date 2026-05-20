#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

remote_dirs=(
    "/2025" "/Users" "/all" "/audio-texts" "/blog"
    "/build" "/card" "/city" "/clickandbuilds" "/convo"
    "/covers" "/covers-bak" "/css" "/csv" "/dad"
    "/dalle" "/disco" "/docs" "/etsy" "/flow"
    "/follow" "/gdrive" "/html" "/images" "/img"
    "/leo" "/leoai" "/leonardo" "/march" "/md"
    "/melody" "/mp4" "/music" "/mydesigns" "/number"
    "/ny" "/oct" "/og" "/pdf" "/python"
    "/repo" "/seamless" "/test" "/trashy" "/uploads"
    "/vids" "/xmas" "/chat.html" "/dalle.html" "/dallechat.html"
    "/form.html" "/index.html" "/mush.html" "/pod.html" "/privacy.html"
    "/seamless.htm"
)

local_dir="/Users/steven/AvaTarArTs"
remote_host="u114071855@access981577610.webspace-data.io"

for dir in "${remote_dirs[@]}"; do
    echo "Syncing $dir..."
    rsync -avz --progress --ignore-existing "$remote_host:$dir" "$local_dir"
done
