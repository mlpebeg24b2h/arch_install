#!/bin/bash

wipe_old_partitions="true"
step_log=/mnt/tmp/step.log
error_log=/tmp/error.log

echo "################# BEGIN installation script for cyclopia #################"

printf "STEP 01 - Wipe all partitions..."
if [ "${wipe_old_partitions}" == "true" ] ; then
   max_cr=0
   for i in $(parted -s /dev/sda print | awk '/^ / {print $1}') ; do
      parted -s /dev/sda rm $i 2> ${error_log}
      rc=$?
      if [ $rc -gt ${max_cr} ] ; then
         echo "KO !"
         echo "ERROR : $(cat ${error_log})"
         exit
      fi
   done

   for i in $(parted -s /dev/sdb print | awk '/^ / {print $1}') ; do
      parted -s /dev/sdb rm $i 2> ${error_log}
      rc=$?
      if [ $rc -gt ${max_cr} ] ; then
         echo "KO !"
         echo "ERROR : $(cat ${error_log})"
         exit
      fi
   done
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 02 - Create all partitions..."
max_cr=0
parted -s /dev/sda mklabel gpt mkpart '"EFI system partition"' 'fat32' '1MiB' '1GiB' 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
parted -s /dev/sda set 1 esp on 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
parted -s /dev/sda mkpart "root" xfs 1GiB 100% 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
parted -s /dev/sdb mklabel gpt mkpart "home" xfs 1MiB 100% 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 03 - Create all File systems..."
max_cr=0
mkfs.fat -F 32 /dev/sda1 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mkfs.xfs /dev/sda2 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mkfs.xfs /dev/sdb1 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 04 - Mount all File systems..."
max_cr=0
mount --mkdir /dev/sda1 /mnt/boot 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mount /dev/sda2 /mnt 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mount --mkdir /dev/sdb1 /mnt/home 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 05 - Install software packages (might take a long time)..."
pacstrap -K /mnt base linux linux-firmware iproute2 networkmanager vim 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 06 - Generate fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

arch-chroot /mnt hwclock --systohc

sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /mnt/etc/locale.gen

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

cp ./etc/locale.conf /mnt/etc/locale.conf

cp ./etc/vconsole.conf /mnt/etc/vconsole.conf

cp ./etc/hostname /mnt/etc/hostname

cp ./etc/NetworkManager/conf.d/dns-servers.conf /mnt/etc/NetworkManager/conf.d/dns-servers.conf

cp ./etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network

cp ./etc/systemd/network/20-wlan.network /mnt/etc/systemd/network/20-wlan.network

cp ./etc/systemd/network/20-wwan.network /mnt/etc/systemd/network/20-wwan.network

arch-chroot /mnt pacman -S grub efibootmgr

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 fsck.mode=skip"/g' /mnt/etc/default/grub

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "################# END installation script for cyclopia #################"
















