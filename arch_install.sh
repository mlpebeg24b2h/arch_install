#!/bin/bash

wipe_old_partitions="true"
step_log=/mnt/tmp/step.log
error_log=/tmp/error.log
incr=0
if [ -n "$1" ] ; then
   skip_to=$1
else
   skip_to=0
fi

echo "################# BEGIN installation script for cyclopia #################"

echo "!!!!!!!!!! DON'T FORGET TO CHECK DISKS BEFORE INSTALLATION !!!!!!!!!!"
echo "Do you want to exit ?"
read input
if [ "$input" == "y" ] ; then
   exit
fi

export disk="/dev/sda"

incr=$(expr $incr + 1)
printf "STEP ${incr} - Wipe all partitions..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   if [ "${wipe_old_partitions}" == "true" ] ; then
      max_cr=0
      echo "wipefs $disk"
      wipefs -af $disk 2> ${error_log}
      rc=$?
      if [ $rc -gt ${max_cr} ] ; then
         echo "KO !"
         echo "ERROR : $(cat ${error_log})"
         echo "STEP ${incr}" && exit
      fi
      echo "clear $disk"
      sgdisk --zap-all --clear $disk 2> ${error_log}
      rc=$?
      if [ $rc -gt ${max_cr} ] ; then
         echo "KO !"
         echo "ERROR : $(cat ${error_log})"
         echo "STEP ${incr}" && exit
      fi
      echo "partprobe $disk"
      partprobe $disk 2> ${error_log}
      rc=$?
      if [ $rc -gt ${max_cr} ] ; then
         echo "KO !"
         echo "ERROR : $(cat ${error_log})"
         echo "STEP ${incr}" && exit
      fi
      echo "OK"
   else
      echo "skipped"
   fi
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Create all partitions..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> creation of EFI partition"
   sgdisk -n 0:0:+1GiB -t 0:ef00 -c 0:esp $disk 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> creation of main partition"
   sgdisk -n 0:0:0 -t 0:8309 -c 0:luks $disk 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> partprobe"
   partprobe $disk 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> print the new partition table"
   sgdisk -p $disk 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Crypt all partitions..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> crypt main partition"
   cryptsetup -y -v luksFormat ${disk}2 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Open all crypted partitions..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> open main crypted partition"
   cryptsetup open ${disk}2 root 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Create all File systems..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> creation of EFI FS"
   mkfs.vfat -F32 -n ESP ${disk}1 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> creation of root FS"
   mkfs.btrfs -L archlinux /dev/mapper/root -f 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Mount all File systems..."
echo "Press enter when ready"
read input
max_cr=0
echo "==> mount root partition"
mount /dev/mapper/root /mnt 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   echo "STEP ${incr}" && exit
fi
#echo "==> mount EFI partition"
#mount --mkdir /dev/sda1 /mnt/boot 2> ${error_log}
#rc=$?
#if [ $rc -gt ${max_cr} ] ; then
#   echo "KO !"
#   echo "ERROR : $(cat ${error_log})"
#   echo "STEP ${incr}" && exit
#fi
echo "OK"
echo "check FS : "
df -k | grep mnt
echo "Press enter when ready"
read input

incr=$(expr $incr + 1)
printf "STEP ${incr} - Create BTRFS subvolumes..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   btrfs subvolume create /mnt/@ 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@home 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@snapshots 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@cache 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@libvirt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@log 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   btrfs subvolume create /mnt/@tmp 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Mount the BTRFS subvolumes..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   echo "==> umount the root partition"
   umount /mnt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> set mount options for the subvolumes"
   export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
   echo "==> Mount the new BTRFS root subvolume"
   mount -o ${sv_opts},subvol=@ /dev/mapper/root /mnt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> create mountpoints for the additional subvolumes"
   mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp} 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount home subvolume"
   mount -o ${sv_opts},subvol=@home /dev/mapper/root /mnt/home 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount snapshot subvolume"
   mount -o ${sv_opts},subvol=@snapshots /dev/mapper/root /mnt/.snapshots 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount cache subvolume"
   mount -o ${sv_opts},subvol=@cache /dev/mapper/root /mnt/var/cache 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount libvirt subvolume"
   mount -o ${sv_opts},subvol=@libvirt /dev/mapper/root /mnt/var/lib/libvirt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount log subvolume"
   mount -o ${sv_opts},subvol=@log /dev/mapper/root /mnt/var/log 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount tmp subvolume"
   mount -o ${sv_opts},subvol=@tmp /dev/mapper/root /mnt/var/tmp 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> create ESP mount point"
   mkdir /mnt/efi 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> mount ESP partition"
   mount ${disk}1 /mnt/efi 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
   df -h | grep mnt
else
   echo "skipped"
fi

#### ADD : 
# grep vendor_id /proc/cpuinfo
# export microcode="intel-ucode"
# pacstrap ${microcode}
####

incr=$(expr $incr + 1)
printf "STEP ${incr} - Install software packages (might take a long time)..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   pacstrap -K /mnt base base-devel btrfs-progs intel-ucode linux linux-firmware cryptsetup openssh iproute2 networkmanager python git vim sudo xdg-user-dirs 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Generate fstab..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   genfstab -U -p /mnt >> /mnt/etc/fstab 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Generate local time zone..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Set the system time..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt hwclock --systohc 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Generate locales..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /mnt/etc/locale.gen 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   arch-chroot /mnt locale-gen 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   cp ./etc/locale.conf /mnt/etc/locale.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Generate keyboard mappings..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   cp ./etc/vconsole.conf /mnt/etc/vconsole.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Generate hostname..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   cp ./etc/hostname /mnt/etc/hostname 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Configure Networking..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> configure DNS servers"
   cp ./etc/NetworkManager/conf.d/dns-servers.conf /mnt/etc/NetworkManager/conf.d/dns-servers.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> configure ethernet network"
   cp ./etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> configure wlan network"
   cp ./etc/systemd/network/20-wlan.network /mnt/etc/systemd/network/20-wlan.network 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> configure wwan network"
   cp ./etc/systemd/network/20-wwan.network /mnt/etc/systemd/network/20-wwan.network 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - keyfile..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> create keyfile"
   arch-chroot /mnt dd bs=512 count=4 iflag=fullblock if=/dev/random of=/crypto_keyfile.bin 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> change keyfile permissions"
   chmod 600 /mnt/crypto_keyfile.bin 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> add this keyfile to luks"
   arch-chroot /mnt cryptsetup luksAddKey ${disk}2 /crypto_keyfile.bin 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - mkinitcpio..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> add the keyfile"
   echo "FILES=(/crypto_keyfile.bin)" >> /mnt/etc/mkinitcpio.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> add btrfs support"
   echo "MODULES=(btrfs)" >> /mnt/etc/mkinitcpio.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> set hooks"
   sed -i 's/HOOKS=.*/HOOKS=(base udev keyboard autodetect keymap consolefont modconf kms block encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   max_cr=1
   arch-chroot /mnt mkinitcpio -P
   rc=$?
   echo "==> recreate the initramfs image"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - GRUB..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   arch-chroot /mnt pacman -S grub efibootmgr 2> ${error_log}
   rc=$?
   echo "==> install grub binaries"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   UUID_ROOT=$(blkid|grep sda2|awk '{print $2}'|sed 's/"//g')
   echo "==> configure GRUB file"
   sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 fsck.mode=skip cryptdevice=${UUID_ROOT}:root root=\/dev\/mapper\/root\"/g" /mnt/etc/default/grub 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> include the luks module"
   sed -i "s/GRUB_PRELOAD_MODULES=\"\(.*\)\"/GRUB_PRELOAD_MODULES=\"\1 luks\"/g" /mnt/etc/default/grub 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> enable crypto disk"
   sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g" /mnt/etc/default/grub 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> install GRUB on system"
   echo "Press enter when ready"
   read input
   arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> verify that a GRUB entry has been added to the UEFI bootloader by running : efibootmgr"
   arch-chroot /mnt efibootmgr
   echo "Press enter when ready"
   read input
   arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 2> ${error_log}
   rc=$?
   echo "==> configure GRUB on system"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "==> verify that grub.cfg has entries for insmod cryptodisk and insmod luks by running : grep 'cryptodisk\|luks' /efi/grub/grub.cfg"
   echo "Press enter when ready"
   read input
   grep 'cryptodisk\|luks' /mnt/boot/grub/grub.cfg
   rc=$?
   echo "==> configure GRUB on system"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   #echo "home         ${UUID_HOME}        none    timeout=180" >> /mnt/etc/crypttab
   #rc=$?
   #echo "==> configure crypttab file"
   #if [ $rc -gt ${max_cr} ] ; then
   #   echo "KO !"
   #   echo "ERROR : $(cat ${error_log})"
   #   echo "STEP ${incr}" && exit
   #fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Change root passwd..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt passwd root
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Create user..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt useradd -d /home/nicolas -m -s /bin/bash -G wheel nicolas
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Change user passwd for nicolas..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt passwd nicolas
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Enable and configure NetworkManager and SSH services..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt systemctl enable NetworkManager 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   arch-chroot /mnt systemctl enable sshd 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   #sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /mnt/etc/ssh/sshd_config 2> ${error_log}
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Configure sudo..."
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /mnt/etc/sudoers 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Create and configure xdg user dirs..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt su -c 'xdg-user-dirs-update' nicolas 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   arch-chroot /mnt su -c 'systemctl enable xdg-user-dirs-update --user' nicolas 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   arch-chroot /mnt su -c 'mkdir -p ~/Workspace/tmp && mkdir -p ~/Workspace/backup/system-wide-desktop-entries && mkdir ~/Venv && mkdir -p ~/Workspace/git/github' nicolas 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
else
   echo "skipped"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Copy current dir to arch linux..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   cp -r /tmp/arch_install /mnt/home/nicolas/Workspace/git/github 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
  arch-chroot /mnt chown -R nicolas /home/nicolas/Workspace/git/github/arch_install 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
fi

incr=$(expr $incr + 1)
printf "STEP ${incr} - Umount everything..."
max_cr=0
if [ "${skip_to}" -le "${incr}" ] ; then
   echo "Press enter when ready"
   read input
   umount -R /mnt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      echo "STEP ${incr}" && exit
   fi
   echo "OK"
fi

echo "################# END installation script for cyclopia #################"
echo ""
echo "Important: In this early stage of boot GRUB is using the us keyboard, not any alternative keymap that might be set in vconsole.conf."

