#!/bin/bash

# Set download URL and target folder
DOWNLOAD_URL="https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch.7z"
TARGET_FOLDER=~/Applications
APPIMAGE=~/Applications/RetroArch-Linux-x86_64.AppImage

# Create a temporary directory for downloading and extracting
TEMP_DIR=$(mktemp -d)

# Download the 7z file
echo "Downloading the latest RetroArch AppImage 7z file..."
wget -q --show-progress -O "$TEMP_DIR/retroarch.7z" "$DOWNLOAD_URL"

# Extract the 7z file
echo "Extracting the 7z file..."
7z x "$TEMP_DIR/retroarch.7z" -o"$TEMP_DIR"

# Find the AppImage file (assuming only one AppImage is in the directory)
APPIMAGE_FILE=$(find "$TEMP_DIR" -name "*.AppImage")

# Check if AppImage was found
if [[ -f "$APPIMAGE_FILE" ]]; then
	echo "AppImage file found: $APPIMAGE_FILE"
	# Backup existing AppImage file
	if [[ -f "$APPIMAGE" ]]; then
		echo "Existing AppImage found"
		cp -f ~/Applications/RetroArch-Linux-x86_64.AppImage ~/Applications/RetroArch-Linux-x86_64.AppImage.bak
		echo "Existing AppImage backed up"
	else
		echo ""
	fi
    # Copy new AppImage file to the target folder
    cp -f "$APPIMAGE_FILE" "$TARGET_FOLDER"
    echo "AppImage copied to $TARGET_FOLDER"
else
    echo "No AppImage file found in the extracted contents."
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"
