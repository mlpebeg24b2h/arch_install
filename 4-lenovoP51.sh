#!/bin/bash

sudo pacman -Sy linux-headers nvidia-dkms
yay -S hyprland-nvidia-git
#  adding nvidia_drm.modeset=1 to the end of GRUB_CMDLINE_LINUX_DEFAULT= in /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

# in /etc/mkinitcpio.conf add nvidia nvidia_modeset nvidia_uvm nvidia_drm to your MODULES

# add a new line to /etc/modprobe.d/nvidia.conf (make it if it does not exist) and add the line options nvidia-drm modeset=1

# Export these variables in your hyprland config:

env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

sudo pacman -Sy qt5-wayland qt5ct libva
yay -S libva-nvidia-driver-git
