#!/bin/bash
set -e

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

# Download ES-DE and RetroArch
cd ~/Downloads
wget https://gitlab.com/es-de/emulationstation-de/-/package_files/210210324/download -O ES-DE_x64.AppImage
wget https://buildbot.libretro.com/stable/1.21.0/linux/x86_64/RetroArch.7z
p7zip -d RetroArch.7z

# Move applications
mv ES-DE_x64.AppImage ~/Applications/
mv RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage ~/Applications/
mv RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch ~/.config/ || true

# Cleanup downloads
cd ~
rm -rf ~/Downloads/*

# Permissions
chmod +x ~/Applications/*
chmod 777 ~/Applications/*

# Configure GRUB
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 fsck.mode=skip vt.global_cursor_default=0"/' /etc/default/grub
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

# Configure LightDM
sudo tee /etc/lightdm/lightdm.conf > /dev/null <<'EOF'
[SeatDefaults]
autologin-user=arcade
autologin-user-timeout=0
user-session=openbox
EOF
