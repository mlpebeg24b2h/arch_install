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
mkfs.xfs -f /dev/sda2 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mkfs.xfs -f /dev/sdb1 2> ${error_log}
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
genfstab -U /mnt >> /mnt/etc/fstab 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 07 - Generate local time zone..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 08 - Set the system time..."
arch-chroot /mnt hwclock --systohc 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 09 - Generate locales..."
max_cr=0
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /mnt/etc/locale.gen 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
arch-chroot /mnt locale-gen 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
cp ./etc/locale.conf /mnt/etc/locale.conf 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 10 - Generate keyboard mappings..."
cp ./etc/vconsole.conf /mnt/etc/vconsole.conf 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 11 - Generate hostname..."
cp ./etc/hostname /mnt/etc/hostname 2> ${error_log}
rc=$?
if [ $rc -gt 0 ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 12 - Configure Networking..."
max_cr=0
cp ./etc/NetworkManager/conf.d/dns-servers.conf /mnt/etc/NetworkManager/conf.d/dns-servers.conf 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
cp ./etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
cp ./etc/systemd/network/20-wlan.network /mnt/etc/systemd/network/20-wlan.network 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
cp ./etc/systemd/network/20-wwan.network /mnt/etc/systemd/network/20-wwan.network 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

printf "STEP 13 - Configure GRUB..."
max_cr=0
arch-chroot /mnt pacman -S grub efibootmgr 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 fsck.mode=skip"/g' /mnt/etc/default/grub 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"

echo "################# END installation script for cyclopia #################"
