sudo sed -i -e '$a\\arcade ALL=(ALL) NOPASSWD:ALL' /etc/sudoers

sudo apt update -y \&\& sudo apt upgrade -y



sudo apt install xorg openbox obconf lxterminal yad screen lxappearance xterm nemo nano lxpolkit firefox rofi lightdm libfuse2 alsa-utils samba git dialog unzip xmlstarlet mpv dos2unix mc build-essential libsdl2-dev libsdl2-gfx-dev libsdl2-ttf-dev libvorbis-dev libsdl2-image-dev autotools-dev scrot jstest-gtk --no-install-recommends -y



sudo ubuntu-drivers install



sudo nano /etc/samba/smb.conf

[Home]
path = /home/arcade

*public = yes*

*guest only = yes*

*writable = yes*

*browseable = yes*

*force user = arcade*

*inherit permissions = yes*



sudo service smbd restart



mkdir -p ~/.config/openbox

nano ~/.config/openbox/AutoStart

*# Suppress screensaver start attempts and autoblanking*

*xset -dpms \&*

*xset s off \&*

*#Start ES-DE*

*~/Applications/ES-DE\*.AppImage \&*



copy rc.xml to ~/.config/openbox



mkdir ~/Applications



copy ES-DE and RA appimages

copy RA .config folder to ~



chmod +x ~/Applications/\*

chmod 777 ~/Applications/\*



sudo nano /etc/default/grub

*GRUB\_CMDLINE\_LINUX\_DEFAULT="quiet console=tty3 loglevel=2 fsck.mode=skip vt.global\_cursor\_default=0"*



sudo update-grub



sudo systemctl disable getty@tty1.service --now



sudo nano /etc/lightdm/lightdm.conf

*\[SeatDefaults]*

*autologin-user=arcade*

*autologin-user-timeout=0*

*user-session=openbox*



