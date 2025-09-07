#!/usr/bin/env bash
set -euo pipefail

# URL of the latest_release.json
JSON_URL="https://gitlab.com/es-de/emulationstation-de/-/raw/master/latest_release.json"

# Temporary file to store JSON
TMP_JSON="$(mktemp)"

# Destination AppImage
DEST_FILE="ES-DE_x64.AppImage"

# Check for dependencies
for cmd in wget jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' is required but not installed."
        exit 1
    fi
done

# Download JSON
wget -qO "$TMP_JSON" "$JSON_URL"

# Parse URL for LinuxAppImage (stable channel)
APPIMAGE_URL=$(jq -r '.stable.packages[] | select(.name=="LinuxAppImage") | .url' "$TMP_JSON")

if [[ -z "$APPIMAGE_URL" || "$APPIMAGE_URL" == "null" ]]; then
    echo "Error: LinuxAppImage URL not found in latest_release.json"
    exit 2
fi

echo "Downloading ES-DE Linux AppImage..."
wget -O "$DEST_FILE" "$APPIMAGE_URL"

# Make it executable
chmod +x "$DEST_FILE"

# Clean up
rm -f "$TMP_JSON"

echo "Download complete: $DEST_FILE"
