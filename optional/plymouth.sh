#!/usr/bin/env bash
set -euo pipefail

# clone plymouth themes repo
cd ~/Downloads
git clone https://github.com/adi1090x/plymouth-themes.git

# add 'splash' to grub
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=0 fsck.mode=skip vt.global_cursor_default=0 video=1920x1080"/' /etc/default/grub
sudo update-grub

# after downloading or cloning themes, copy the selected theme in plymouth theme dir
sudo cp -r ~/Downloads/plymouth-themes/pack_1/angular /usr/share/plymouth/themes/

# install the new theme (angular, in this case)
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/angular/angular.plymouth 100

# select the theme to apply
sudo update-alternatives --config default.plymouth

# update initramfs
sudo update-initramfs -u