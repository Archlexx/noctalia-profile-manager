#!/bin/sh
# duplicate-profile.sh <source_dir> <dest_dir>
# Copies source profile directory to dest_dir (which must not exist yet).

set -e
cp -r "$1" "$2"
