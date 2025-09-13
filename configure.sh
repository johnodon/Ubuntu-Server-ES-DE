#!/usr/bin/env bash
set -euo pipefail

# Add arcade to sudoers
sudo sed -i -e '$a\arcade ALL=(ALL) NOPASSWD:ALL' /etc/sudoers

# Enable repositories
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y

# Update & upgrade
sudo apt update -y && sudo apt dist-upgrade -y

# Install packages
sudo apt install -y \
  xorg openbox obconf lxterminal inxi yad screen lxappearance xterm nemo nano feh lxpolkit firefox rofi \
  lightdm libfuse2 samba git dialog pulseaudio pavucontrol alsa-utils unzip xmlstarlet mpv dos2unix mc xdotool \
  p7zip build-essential libsdl2-dev libsdl2-gfx-dev libsdl2-ttf-dev libvorbis-dev net-tools libsdl2-image-dev \
  autotools-dev scrot jstest-gtk --no-install-recommends

# Configure Samba
sudo tee -a /etc/samba/smb.conf > /dev/null <<'EOF'

[Home]
path = /home/arcade
public = yes
guest only = yes
writable = yes
browseable = yes
force user = arcade
inherit permissions = yes
EOF

sudo service smbd restart

# Clone config repo
git clone --depth=1 https://github.com/johnodon/Ubuntu-Server-ES-DE.git
mv ~/Ubuntu-Server-ES-DE/.config ~
rm -rf ~/Ubuntu-Server-ES-DE

# Create dirs
mkdir -p ~/Applications ~/Downloads

# Download ES-DE
cd ~/Downloads
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

# Download RetroArch
cd ~/Downloads
wget https://buildbot.libretro.com/stable/1.21.0/linux/x86_64/RetroArch.7z
p7zip -d RetroArch.7z

# Download Hypseus-Singe
# Target directory
HS_APP_DIR="$HOME/Applications/hypseus-singe"
mkdir -p "$HS_APP_DIR"

# Fetch latest release info from GitHub API
LATEST_URL=$(curl -s https://api.github.com/repos/DirtBagXon/hypseus-singe/releases/latest \
  | grep "browser_download_url" \
  | grep "AppImage.tar.gz" \
  | cut -d '"' -f 4)

# Exit if no URL found
if [[ -z "$LATEST_URL" ]]; then
  echo "❌ Could not find Hypseus-Singe AppImage tar.gz download URL."
  exit 1
fi

echo "⬇️ Downloading: $LATEST_URL"
wget -q --show-progress "$LATEST_URL" -O /tmp/hypseus-singe.tar.gz

echo "📦 Extracting..."
gzip -dc /tmp/hypseus-singe.tar.gz | tar -xvzf -

# Move applications
mv ES-DE_x64.AppImage ~/Applications/
mv RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage ~/Applications/
mv RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch ~/.config/ || true
mv hypseus-singe/* "$HS_APP_DIR"

# Cleanup downloads
rm /tmp/hypseus*.gz
cd ~
rm -rf ~/Downloads/*

# Permissions
chmod 777 ~/Applications/*
chmod +x "$HS_APP_DIR/hypseus.bin"

# Configure GRUB
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 console=tty2 fsck.mode=skip vt.global_cursor_default=0"/' /etc/default/grub
sudo sed -i 's/^#GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080/' /etc/default/grub
sudo update-grub

# Add arcade user to groups
sudo usermod -a -G input arcade
sudo usermod -a -G audio arcade
sudo usermod -a -G video arcade

# Fix ownership
chown -R arcade:arcade ~

# Disable login messages
sudo rm -f /etc/issue
touch ~/.hushlogin
sudo systemctl disable getty@tty1.service --now

# Remove cloud-init
sudo apt-get purge cloud-init -y
sudo rm -rf /etc/cloud/ /var/lib/cloud/

# Remove kdump-tools
sudo apt remove kdump-tools -y

# Configure LightDM
sudo tee /etc/lightdm/lightdm.conf > /dev/null <<'EOF'
[SeatDefaults]
autologin-user=arcade
autologin-user-timeout=0
user-session=openbox
EOF
