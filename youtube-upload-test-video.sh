#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

source ./venv/bin/activate
python3 yt_upload.py --file="./media/askreddit_submission_test0.mp4" --title="AskReddit: Top Subreddit of all time" --description="Poop" --keywords="reddit, AskReddit" --category="22" --privacyStatus="public"
