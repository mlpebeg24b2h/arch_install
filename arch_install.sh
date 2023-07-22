#!/bin/bash

wipe_old_partitions="true"
step_log=/mnt/tmp/step.log
error_log=/tmp/error.log
skip_to=14

echo "################# BEGIN installation script for cyclopia #################"

printf "STEP 01 - Wipe all partitions..."
if [ ${skip_to} -le 1 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 02 - Create all partitions..."
if [ ${skip_to} -le 2 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 03 - Create all File systems..."
if [ ${skip_to} -le 3 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 04 - Mount all File systems..."
max_cr=0
mount /dev/sda2 /mnt 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
mount --mkdir /dev/sda1 /mnt/boot 2> ${error_log}
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
echo "check FS : "
df -k | grep mnt
read toto

printf "STEP 05 - Install software packages (might take a long time)..."
if [ ${skip_to} -le 5 ] ; then
   pacstrap -K /mnt base linux linux-firmware openssh iproute2 networkmanager vim 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 06 - Generate fstab..."
if [ ${skip_to} -le 6 ] ; then
   genfstab -U /mnt >> /mnt/etc/fstab 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 07 - Generate local time zone..."
if [ ${skip_to} -le 7 ] ; then
   arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 08 - Set the system time..."
if [ ${skip_to} -le 8 ] ; then
   arch-chroot /mnt hwclock --systohc 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 09 - Generate locales..."
if [ ${skip_to} -le 9 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 10 - Generate keyboard mappings..."
if [ ${skip_to} -le 10 ] ; then
   cp ./etc/vconsole.conf /mnt/etc/vconsole.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 11 - Generate hostname..."
if [ ${skip_to} -le 11 ] ; then
   cp ./etc/hostname /mnt/etc/hostname 2> ${error_log}
   rc=$?
   if [ $rc -gt 0 ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 12 - Configure Networking..."
if [ ${skip_to} -le 12 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 13 - Configure GRUB..."
if [ ${skip_to} -le 13 ] ; then
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
else
   echo "skipped"
fi

printf "STEP 14 - Change root passwd..."
if [ ${skip_to} -le 14 ] ; then
   arch-chroot /mnt passwd root
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 15 - Create user..."
if [ ${skip_to} -le 15 ] ; then
   arch-chroot /mnt useradd -d /home/nicolas -m -s /usr/bin/bash nicolas
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 16 - Change user passwd..."
if [ ${skip_to} -le 16 ] ; then
   arch-chroot /mnt passwd nicolas
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 17 - Enable systemd unit files..."
if [ ${skip_to} -le 17 ] ; then
   arch-chroot /mnt systemctl enable NetworkManager
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt systemctl enable sshd
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

echo "################# END installation script for cyclopia #################"
