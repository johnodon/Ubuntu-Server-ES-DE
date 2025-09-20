#!/usr/bin/env bash
set -euo pipefail

# Enable repositories and install drivers
sudo add-apt-repository ppa:oibaf/graphics-drivers -y
sudo apt update -y && sudo apt upgrade -y
sudo apt install libvulkan1 mesa-vulkan-drivers mesa-utils -y

