#!/bin/bash

# Configuration du bluetooth
# ==========================
sudo pacman -Sy bluez bluez-utils
sudo pacman -Sy pulseaudio-bluetooth
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
# Pour le casque Logi Zone 900 : 
# dans le gestionnaire bluetooth, click-droit sur le casque, puis 
# - cocher audio and input profiles
# - sélectionner audio Profile > Handsfree Head Unit (HFP)
#
# numlock on startup
yay -S systemd-numlockontty
systemctl enable numLockOnTty
systemctl start numLockOnTty
