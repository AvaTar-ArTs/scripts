#!/usr/bin/env bash

# Usage: ./git-tag-release.sh <tag> <message>
# Example: ./git-tag-release.sh v1.0.0 "Initial stable release"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tag> <message>"
    echo "Example: $0 v1.0.0 'Release 1.0.0'"
    exit 1
fi

TAG=$1
MESSAGE=$2

# 1. Ensure working directory is clean
if [[ -n $(git status -s) ]]; then
    echo "Error: Working directory is not clean. Commit changes first."
    exit 1
fi

# 2. Create the annotated tag
echo "Creating tag $TAG..."
git tag -a "$TAG" -m "$MESSAGE"

# 3. Push the tag to remote
echo "Pushing tag to origin..."
git push origin "$TAG"

if [ $? -eq 0 ]; then
    echo "Successfully created and pushed tag: $TAG"
else
    echo "Error pushing tag. Check your remote connection."
    exit 1
fi
