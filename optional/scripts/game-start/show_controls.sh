#!/bin/bash
killall -9 feh
ROMPATH="${1}"
ROM_BN_EXT="${ROMPATH##*/}"
ROM_BN="${ROM_BN_EXT%.*}"
feh --geometry +3840+0 "/home/arcade/ES-DE/media/${3}/controls/$ROM_BN.png" &
