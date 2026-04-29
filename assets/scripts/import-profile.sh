#!/bin/sh
# import-profile.sh <source_dir> <profiles_dir>
# Copies a profile folder into the profiles directory.
# Fails if a profile with the same name already exists.

set -e

SOURCE_DIR="$1"
PROFILES_DIR="$2"
PROFILE_NAME="$(basename "$SOURCE_DIR")"
DEST_DIR="$PROFILES_DIR/$PROFILE_NAME"

if [ -d "$DEST_DIR" ]; then
  echo "Profile \"$PROFILE_NAME\" already exists" >&2
  exit 1
fi

cp -r "$SOURCE_DIR" "$DEST_DIR"
