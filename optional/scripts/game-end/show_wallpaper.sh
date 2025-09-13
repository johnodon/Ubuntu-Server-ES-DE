#!/bin/bash
killall -9 feh
feh --geometry +3840+0 /home/arcade/ES-DE/media/wallpaper.jpg &
sleep 0.3
xdotool search --class es-de windowactivate
