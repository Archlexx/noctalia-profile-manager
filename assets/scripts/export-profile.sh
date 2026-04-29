#!/bin/sh
# export-profile.sh <profile_dir> <exports_dir>
# Copies a profile to the exports directory, stripping machine-specific keys
# from settings.json (monitors, local paths, avatar) using jq if available.

set -e

PROFILE_DIR="$1"
EXPORTS_DIR="$2"
PROFILE_NAME="$(basename "$PROFILE_DIR")"
EXPORT_DIR="$EXPORTS_DIR/$PROFILE_NAME"

mkdir -p "$EXPORT_DIR"
cp -r "$PROFILE_DIR/." "$EXPORT_DIR/"

if [ -f "$EXPORT_DIR/settings.json" ] && command -v jq > /dev/null 2>&1; then
  jq 'del(
    .bar.monitors,
    .bar.screenOverrides,
    .dock.monitors,
    .notifications.monitors,
    .osd.monitors,
    .desktopWidgets.monitorWidgets,
    .wallpaper.monitorDirectories,
    .wallpaper.directory,
    .general.lockScreenMonitors,
    .general.avatarImage
  )' "$EXPORT_DIR/settings.json" > "$EXPORT_DIR/settings.json.tmp" \
    && mv "$EXPORT_DIR/settings.json.tmp" "$EXPORT_DIR/settings.json"
fi
