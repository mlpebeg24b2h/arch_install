#!/bin/bash
#      _       _    __ _ _           
#   __| | ___ | |_ / _(_) | ___  ___ 
#  / _` |/ _ \| __| |_| | |/ _ \/ __|
# | (_| | (_) | |_|  _| | |  __/\__ \
#  \__,_|\___/ \__|_| |_|_|\___||___/
#                                    
# ------------------------------------------------------
# Install Script for dotfiles and configuration
# yay must be installed
# ------------------------------------------------------

# ------------------------------------------------------
# Load Library
# ------------------------------------------------------
WORKSPACE_GIT=~/Workspace/git/github
WORKSPACE_DOTFILES=${WORKSPACE_GIT}/arch_install/
source $(dirname "$0")/scripts/library.sh
clear
echo "     _       _    __ _ _            "
echo "  __| | ___ | |_ / _(_) | ___  ___  "
echo " / _' |/ _ \| __| |_| | |/ _ \/ __| "
echo "| (_| | (_) | |_|  _| | |  __/\__ \ "
echo " \__,_|\___/ \__|_| |_|_|\___||___/ "
echo "                                    "
echo "-------------------------------------"
echo ""
echo "The script will ask for permission to remove existing folders and files."
echo "But you can decide to keep your local versions by answering with No (Nn)."
echo "Symbolic links will be created from ~/dotfiles into your home and .config directories."
echo ""

# ------------------------------------------------------
# Confirm Start
# ------------------------------------------------------
while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Create .config folder
# ------------------------------------------------------
echo ""
echo "-> Check if .config folder exists"

if [ -d ~/.config ]; then
    echo ".config folder already exists."
else
    mkdir ~/.config
    echo ".config folder created."
fi

# ------------------------------------------------------
# Create symbolic links
# ------------------------------------------------------
# name symlink source target

echo ""
echo "-------------------------------------"
echo "-> Install general dotfiles"
echo "-------------------------------------"
echo ""

_installSymLink alacritty ~/.config/alacritty ${WORKSPACE_DOTFILES}/dotfiles/alacritty/ ~/.config
_installSymLink ranger ~/.config/ranger ${WORKSPACE_DOTFILES}/dotfiles/ranger/ ~/.config
_installSymLink vim ~/.config/vim ${WORKSPACE_DOTFILES}/dotfiles/vim/ ~/.config
_installSymLink nvim ~/.config/nvim ${WORKSPACE_DOTFILES}/dotfiles/nvim/ ~/.config
_installSymLink starship ~/.config/starship.toml ${WORKSPACE_DOTFILES}/dotfiles/starship/starship.toml ~/.config/starship.toml
_installSymLink rofi ~/.config/rofi ${WORKSPACE_DOTFILES}/dotfiles/rofi/ ~/.config
_installSymLink dunst ~/.config/dunst ${WORKSPACE_DOTFILES}/dotfiles/dunst/ ~/.config
_installSymLink wal ~/.config/wal ${WORKSPACE_DOTFILES}/dotfiles/wal/ ~/.config
wal -i screenshots/
echo "Pywal templates initiated!"
echo ""
echo "-------------------------------------"
echo "-> Install GTK dotfiles"
echo "-------------------------------------"
echo ""

_installSymLink .gtkrc-2.0 ~/.gtkrc-2.0 ${WORKSPACE_DOTFILES}/dotfiles/gtk/.gtkrc-2.0 ~/.gtkrc-2.0
_installSymLink gtk-3.0 ~/.config/gtk-3.0 ${WORKSPACE_DOTFILES}/dotfiles/gtk/gtk-3.0/ ~/.config/
_installSymLink .Xresouces ~/.Xresources ${WORKSPACE_DOTFILES}dotfiles/gtk/.Xresources ~/.Xresources
_installSymLink .icons ~/.icons ${WORKSPACE_DOTFILES}/dotfiles/gtk/.icons/ ~/

echo "-------------------------------------"
echo "-> Install Qtile dotfiles"
echo "-------------------------------------"
echo ""

_installSymLink qtile ~/.config/qtile ${WORKSPACE_DOTFILES}/dotfiles/qtile/ ~/.config
_installSymLink polybar ~/.config/polybar ${WORKSPACE_DOTFILES}/dotfiles/polybar/ ~/.config
_installSymLink picom ~/.config/picom ${WORKSPACE_DOTFILES}/dotfiles/picom/ ~/.config
_installSymLink .xinitrc ~/.xinitrc ${WORKSPACE_DOTFILES}/dotfiles/qtile/.xinitrc ~/.xinitrc

echo "-------------------------------------"
echo "-> Install Hyprland dotfiles"
echo "-------------------------------------"
echo ""

_installSymLink hypr ~/.config/hypr ${WORKSPACE_DOTFILES}/dotfiles/hypr/ ~/.config
_installSymLink waybar ~/.config/waybar ${WORKSPACE_DOTFILES}/dotfiles/waybar/ ~/.config
_installSymLink swaylock ~/.config/swaylock ${WORKSPACE_DOTFILES}/dotfiles/swaylock/ ~/.config
_installSymLink wlogout ~/.config/wlogout ${WORKSPACE_DOTFILES}/dotfiles/wlogout/ ~/.config
_installSymLink swappy ~/.config/swappy ${WORKSPACE_DOTFILES}/dotfiles/swappy/ ~/.config

# ------------------------------------------------------
# DONE
# ------------------------------------------------------
echo "DONE! Please reboot your system!"
