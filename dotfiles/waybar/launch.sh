#!/bin/sh
#  ____  _             _    __        __          _                 
# / ___|| |_ __ _ _ __| |_  \ \      / /_ _ _   _| |__   __ _ _ __  
# \___ \| __/ _` | '__| __|  \ \ /\ / / _` | | | | '_ \ / _` | '__| 
#  ___) | || (_| | |  | |_    \ V  V / (_| | |_| | |_) | (_| | |    
# |____/ \__\__,_|_|   \__|    \_/\_/ \__,_|\__, |_.__/ \__,_|_|    
#                                           |___/                   
# ----------------------------------------------------- 

# ----------------------------------------------------- 
# Quit running waybar instances
# ----------------------------------------------------- 
killall waybar

# ----------------------------------------------------- 
# Loading the configuration based on the username
# ----------------------------------------------------- 
if [[ $USER = "raabe" ]]
then
    waybar -c ~/Workspace/git/github/arch_install/dotfiles/waybar/myconfig & -s ~/Workspace/git/github/arch_install/dotfiles/waybar/style.css  
else
    waybar &
fi 
