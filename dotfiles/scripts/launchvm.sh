#!/bin/bash
set -x
#  _                           _      __     ____  __  
# | |    __ _ _   _ _ __   ___| |__   \ \   / /  \/  | 
# | |   / _` | | | | '_ \ / __| '_ \   \ \ / /| |\/| | 
# | |__| (_| | |_| | | | | (__| | | |   \ V / | |  | | 
# |_____\__,_|\__,_|_| |_|\___|_| |_|    \_/  |_|  |_| 
#                                                      
#  
# ----------------------------------------------------- 

op_creds_uuid="km4mekao6orq73qw6uzcmazoni"
vm_name="donbot"
win11user="$(op read op://informatique/${op_creds_uuid}/username)"
win11pass="$(op read op://informatique/${op_creds_uuid}/password)"

tmp=$(sudo virsh list --all | grep " ${vm_name} " | awk '{print $3}')
#tmp=$(virsh --connect qemu:///system list | grep " ${vm_name} " | awk '{ print $3}')

if ([ "x$tmp" == "x" ] || [ "x$tmp" != "xrunning" ])
then
    virsh --connect qemu:///system start ${vm_name}
    echo "Virtual Machine ${vm_name} is starting... Waiting 45s for booting up."
    notify-send "Virtual Machine ${vm_name} is starting..." "Waiting 45s for booting up."
    sleep 45
#else
#    notify-send "Virtual Machine ${vm_name} is already running." "Launching xfreerdp now!"
#    echo "Starting xfreerdp now..."
fi

ipwin11addr=$(sudo virsh net-dhcp-leases default|grep donbot|awk '{print $5}'|sed 's/\([[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\).*/\1/g')

notify-send "Virtual Machine ${vm_name} is already running - IP : ${ipwin11addr}" "Launching xfreerdp now!"

xfreerdp -grab-keyboard /v:${ipwin11addr} /size:100% /cert-ignore /u:$win11user /p:$win11pass /d: /dynamic-resolution /gfx-h264:avc444 +gfx-progressive &
