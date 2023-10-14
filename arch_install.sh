#!/bin/bash

wipe_old_partitions="true"
step_log=/mnt/tmp/step.log
error_log=/tmp/error.log
skip_to=0

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
   
      #for i in $(parted -s /dev/sdb print | awk '/^ / {print $1}') ; do
      #   parted -s /dev/sdb rm $i 2> ${error_log}
      #   rc=$?
      #   if [ $rc -gt ${max_cr} ] ; then
      #      echo "KO !"
      #      echo "ERROR : $(cat ${error_log})"
      #      exit
      #   fi
      #done
      echo "OK"
   else
      echo "skipped"
   fi
else
   echo "skipped"
fi

printf "STEP 02 - Create all partitions..."
if [ ${skip_to} -le 2 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> creation of EFI partition"
   parted -s /dev/sda mklabel gpt mkpart '"EFI system partition"' 'fat32' '1MiB' '1GiB' 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   #parted -s /dev/sda set 1 esp on 2> ${error_log}
   #rc=$?
   #if [ $rc -gt ${max_cr} ] ; then
   #   echo "KO !"
   #   echo "ERROR : $(cat ${error_log})"
   #   exit
   #fi
   echo "==> creation of root partition"
   parted -s /dev/sda mkpart "root" xfs '1GiB' '101GiB' 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> creation of home partition"
   parted -s /dev/sda mkpart "home" xfs '101GiB' 100% 2> ${error_log}
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

printf "STEP 03 - Crypt all partitions..."
if [ ${skip_to} -le 3 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> crypt root partition"
   cryptsetup -y -v luksFormat /dev/sda2 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> crypt home partition"
   cryptsetup -y -v luksFormat /dev/sda3 2> ${error_log}
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

printf "STEP 04 - Open all crypted partitions..."
if [ ${skip_to} -le 4 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> open root crypted partition"
   cryptsetup open /dev/sda2 root 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> open home crypted partition"
   cryptsetup open /dev/sda3 home 2> ${error_log}
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

printf "STEP 05 - Create all File systems..."
if [ ${skip_to} -le 5 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> creation of EFI FS"
   mkfs.fat -F 32 /dev/sda1 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> creation of root FS"
   mkfs.xfs /dev/mapper/root -f 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> creation of home FS"
   mkfs.xfs /dev/mapper/home -f 2> ${error_log}
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

printf "STEP 06 - Mount all File systems..."
echo "Press enter when ready"
read input
max_cr=0
echo "==> mount root partition"
mount /dev/mapper/root /mnt 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "==> mount EFI partition"
mount --mkdir /dev/sda1 /mnt/boot 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "==> mount home partition"
mount --mkdir /dev/mapper/home /mnt/home 2> ${error_log}
rc=$?
if [ $rc -gt ${max_cr} ] ; then
   echo "KO !"
   echo "ERROR : $(cat ${error_log})"
   exit
fi
echo "OK"
echo "check FS : "
df -k | grep mnt
echo "Press enter when ready"
read input

printf "STEP 07 - Install software packages (might take a long time)..."
if [ ${skip_to} -le 7 ] ; then
   echo "Press enter when ready"
   read input
   pacstrap -K /mnt base base-devel linux linux-firmware openssh iproute2 networkmanager python git vim sudo xdg-user-dirs 2> ${error_log}
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

printf "STEP 08 - Generate fstab..."
if [ ${skip_to} -le 8 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 09 - Generate local time zone..."
if [ ${skip_to} -le 9 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 10 - Set the system time..."
if [ ${skip_to} -le 10 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 11 - Generate locales..."
if [ ${skip_to} -le 11 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 12 - Generate keyboard mappings..."
if [ ${skip_to} -le 12 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 13 - Generate hostname..."
if [ ${skip_to} -le 13 ] ; then
   echo "Press enter when ready"
   read input
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

printf "STEP 14 - Configure Networking..."
if [ ${skip_to} -le 14 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   echo "==> configure DNS servers"
   cp ./etc/NetworkManager/conf.d/dns-servers.conf /mnt/etc/NetworkManager/conf.d/dns-servers.conf 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> configure ethernet network"
   cp ./etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> configure wlan network"
   cp ./etc/systemd/network/20-wlan.network /mnt/etc/systemd/network/20-wlan.network 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "==> configure wwan network"
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

printf "STEP 15 - Configure GRUB..."
if [ ${skip_to} -le 15 ] ; then
   echo "Press enter when ready"
   read input
   max_cr=0
   sed -i 's/HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf 2> ${error_log}
   rc=$?
   echo "==> configure mkinitcpio file"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   max_cr=1
   arch-chroot /mnt mkinitcpio -P
   rc=$?
   echo "==> launch mkinitcpio reconfiguration"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   max_cr=0
   arch-chroot /mnt pacman -S grub efibootmgr 2> ${error_log}
   rc=$?
   echo "==> install grub binaries"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   UUID_ROOT=$(blkid|grep sda2|awk '{print $2}'|sed 's/"//g')
   UUID_HOME=$(blkid|grep sda3|awk '{print $2}'|sed 's/"//g')
   sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 fsck.mode=skip cryptdevice=${UUID_ROOT}:root root=\/dev\/mapper\/root\"/g" /mnt/etc/default/grub 2> ${error_log}
   rc=$?
   echo "==> configure GRUB file"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB 2> ${error_log}
   rc=$?
   echo "==> install GRUB on system"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 2> ${error_log}
   rc=$?
   echo "==> configure GRUB on system"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "home         ${UUID_HOME}        none    timeout=180" >> /mnt/etc/crypttab
   rc=$?
   echo "==> configure crypttab file"
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 16 - Change root passwd..."
if [ ${skip_to} -le 16 ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt passwd root
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

printf "STEP 17 - Create user..."
if [ ${skip_to} -le 17 ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt useradd -d /home/nicolas -m -s /bin/bash -G wheel nicolas
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

printf "STEP 18 - Change user passwd for nicolas..."
if [ ${skip_to} -le 18 ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt passwd nicolas
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

printf "STEP 19 - Enable and configure NetworkManager and SSH services..."
max_cr=0
if [ ${skip_to} -le 19 ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt systemctl enable NetworkManager 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt systemctl enable sshd 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   #sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /mnt/etc/ssh/sshd_config 2> ${error_log}
   echo "OK"
else
   echo "skipped"
fi

printf "STEP 20 - Configure sudo..."
if [ ${skip_to} -le 20 ] ; then
   echo "Press enter when ready"
   read input
   sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /mnt/etc/sudoers 2> ${error_log}
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

printf "STEP 21 - Create and configure xdg user dirs..."
max_cr=0
if [ ${skip_to} -le 21 ] ; then
   echo "Press enter when ready"
   read input
   arch-chroot /mnt su -c 'xdg-user-dirs-update' nicolas 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt su -c 'systemctl enable xdg-user-dirs-update --user' nicolas 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   arch-chroot /mnt su -c 'mkdir -p ~/Workspace/tmp && mkdir -p ~/Workspace/backup/system-wide-desktop-entries && mkdir ~/Venv && mkdir -p ~/Workspace/git/github' nicolas 2> ${error_log}
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
printf "STEP 22 - Copy current dir to arch linux..."
max_cr=0
if [ ${skip_to} -le 22 ] ; then
   echo "Press enter when ready"
   read input
   cp -r /tmp/arch_install /mnt/home/nicolas/Workspace/git/github 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
  arch-chroot /mnt chown -R nicolas /mnt/home/nicolas/Workspace/git/github/arch_install 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
fi
printf "STEP 23 - Umount everything..."
max_cr=0
if [ ${skip_to} -le 23 ] ; then
   echo "Press enter when ready"
   read input
   umount -f /mnt/home && umount -f /mnt/boot && umount -f /mnt 2> ${error_log}
   rc=$?
   if [ $rc -gt ${max_cr} ] ; then
      echo "KO !"
      echo "ERROR : $(cat ${error_log})"
      exit
   fi
   echo "OK"
fi

echo "################# END installation script for cyclopia #################"

