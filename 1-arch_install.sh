#!/bin/bash

stderr_log="/tmp/error.log"
stdout_log="/tmp/output.log"

# Functions needed for the execution of the script

display_output() {
    if [ $RC -gt 0 ] ; then
        echo "/!\ KO /!\ ERROR :"
        cat ${error_log}
    else
        echo ":) OK :)"
    fi
    while true;do
        printf "Do you want to display the standard output (yY/nN): "
        read answer
        case $answer in
        y|Y) cat ${stdout_log} ; break;;
        n|N) break;;
        *) echo "Input not recognized, please repeat";;
        esac
    done
    clear
}

install_custom_binaries() {
    CustomBinaries="lshw jq"
    pacman -Sy ${CustomBinaries} 2>${stderr_log} 1>${stdout_log}
    export RC=$?
    display_output
}

display_all_disks_to_choose() {
    lshw -class disk -class storage -json|jq -r '.[] | select(.id=="disk" or .id=="nvme")|{type: .id, device_path: .logicalname, product: .product, vendor: .vendor}'
}


clear
echo "---------------------------------------------------------------------------"
echo ""
echo " _         _    ____   ____ _   _  ____ _   _ __________  _    _     _     "
echo "/ |       / \  |  _ \ / ___| | | | |_ _| \ | / ___|_   _|/ \  | |   | |    "
echo "| |_____ / _ \ | |_) | |   | |_| |  | ||  \| \___ \ | | / _ \ | |   | |    "
echo "| |     / ___ \|  _ <| |___|  _  |  | || |\  |___) || |/ ___ \| |___| |___ "
echo "|_|    /_/   \_\_| \_\\____|_| |_| |___|_| \_|____/ |_/_/   \_\_____|_____|"
echo ""
echo "---------------------------------------------------------------------------"
echo ""

echo "First we need to install custom binaries..."
echo "==========================================="
install_custom_binaries

echo "Please answer the following questions in order to customize your Arch installation:"
echo "==================================================================================="
echo ""
echo "Q1 -> Please choose the primary disk to install the OS on it:"
display_all_disks_to_choose
echo ""