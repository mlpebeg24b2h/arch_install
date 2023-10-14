#/bin/bash
#  ___           _        _ _  
# |_ _|_ __  ___| |_ __ _| | | 
#  | || '_ \/ __| __/ _` | | | 
#  | || | | \__ \ || (_| | | | 
# |___|_| |_|___/\__\__,_|_|_| 
#                              
# ----------------------------------------------------- 
# Install Script for required packages
# Rework from Stephan Raabe
# ------------------------------------------------------

# ------------------------------------------------------
# Load Library
# ------------------------------------------------------
WORKSPACE_GIT=~/Workspace/git/github
WORKSPACE_TMP=~/Workspace/tmp
WORKSPACE_DOTFILES=${WORKSPACE_GIT}/arch_install/
source ${WORKSPACE_DOTFILES}/dotfiles/scripts/library.sh
clear
echo "  ___           _        _ _  "
echo " |_ _|_ __  ___| |_ __ _| | | "
echo "  | ||  _ \/ __| __/ _  | | | "
echo "  | || | | \__ \ || (_| | | | "
echo " |___|_| |_|___/\__\__,_|_|_| "
echo "                              "
echo "-------------------------------------"
echo ""

# ------------------------------------------------------
# Check if yay is installed
# ------------------------------------------------------
if sudo pacman -Qs yay > /dev/null ; then
    echo "yay is installed. You can proceed with the installation"
else
    echo "yay is not installed. Will be installed now!"
    git clone https://aur.archlinux.org/yay-git.git ${WORKSPACE_TMP}/yay-git
    cd ${WORKSPACE_TMP}/yay-git
    makepkg -si
    cd ${WORKSPACE_GIT}/arch_install/
    clear
    echo "yay has been installed successfully."
    echo ""
    echo "  ___           _        _ _  "
    echo " |_ _|_ __  ___| |_ __ _| | | "
    echo "  | ||  _ \/ __| __/ _  | | | "
    echo "  | || | | \__ \ || (_| | | | "
    echo " |___|_| |_|___/\__\__,_|_|_| "
    echo "                              "
    echo "-------------------------------------"
    echo ""
fi

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
# Install required packages
# ------------------------------------------------------
echo ""
echo "-> Install main packages"

packagesPacman=(
    "pacman-contrib"
    "alacritty"
    "rofi"
    "chromium"
    "nitrogen"
    "dunst"
    "starship"
    "neovim"
    "mpv"
    "freerdp"
    "xfce4-power-manager"
    "thunar"
    "mousepad"
    "ttf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "figlet"
    "lxappearance"
    "breeze"
    "breeze-gtk"
    "vlc"
    "exa"
    "python-pip"
    "python-psutil"
    "python-rich"
    "python-click"
    "xdg-desktop-portal-gtk"
    "pavucontrol"
    "tumbler"
    "xautolock"
    "blueman"
    "nautilus"
    "htop"
);

packagesYay=(
    "brave-bin"
    "pfetch"
    "bibata-cursor-theme"
    "trizen"
    "kora-icon-theme"
);
  
# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
_installPackagesPacman "${packagesPacman[@]}";
_installPackagesYay "${packagesYay[@]}";

# ------------------------------------------------------
# Install pywal
# ------------------------------------------------------
if [ -f /usr/bin/wal ]; then
    echo "pywal already installed."
else
    yay --noconfirm -S pywal
fi

clear

# ------------------------------------------------------
# Install .bashrc
# ------------------------------------------------------
echo ""
echo "-> Install .bashrc"

_installSymLink .bashrc ~/.bashrc ${WORKSPACE_GIT}/arch_install/dotfiles/shell/bash/.bashrc ~/.bashrc

# ------------------------------------------------------
# Install custom issue (login prompt)
# ------------------------------------------------------
echo ""
echo "-> Install login screen"
while true; do
    read -p "Do you want to install the custom login prompt? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            sudo cp ${WORKSPACE_GIT}/arch_install/dotfiles/login/issue /etc/issue
            echo "Login prompt installed."
        break;;
        [Nn]* ) 
            echo "Custom login prompt skipped."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Install wallpapers
# ------------------------------------------------------
echo ""
echo "-> Install wallpapers"
while true; do
    read -p "Do you want to clone the wallpapers? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            if [ -d ~/Workspace/wallpapers/ ]; then
                echo "wallpaper folder already exists."
            else
                mkdir ~/Workspace/wallpapers/
                cp -r ${WORKSPACE_GIT}/wallpapers/* ~/Workspace/wallpapers/
                echo "wallpapers installed."
            fi
        break;;
        [Nn]* ) 
            if [ -d ~/Workspace/wallpapers/ ]; then
                echo "wallpapers folder already exists."
            else
                mkdir ~/Workspace/wallpapers
            fi
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Init pywal
# ------------------------------------------------------
echo ""
echo "-> Init pywal"
wal -i ${WORKSPACE_GIT}/wallpapers/default.jpg
echo "pywal initiated."

# ------------------------------------------------------
# DONE
# ------------------------------------------------------
clear
echo "DONE!"
