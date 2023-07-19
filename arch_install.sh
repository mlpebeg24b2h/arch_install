#!/bin/bash

for i in $(parted -s /dev/sda print | awk '/^ / {print $1}') ; do
   parted -s /dev/sda rm $i
done

for i in $(parted -s /dev/sdb print | awk '/^ / {print $1}') ; do
   parted -s /dev/sdb rm $i
done

parted -s /dev/sda mklabel gpt mkpart '"EFI system partition"' 'fat32' '1MiB' '1GiB'

parted -s /dev/sda set 1 esp on

parted -s /dev/sda mkpart "root" xfs 1GiB 100%

parted -s /dev/sdb mklabel gpt mkpart "home" xfs 1MiB 100%

mkfs.fat -F 32 /dev/sda1

mkfs.xfs /dev/sda2

mkfs.xfs /dev/sdb1

mount --mkdir /dev/sda1 /mnt/boot

mount /dev/sda2 /mnt

mount --mkdir /dev/sdb1 /mnt/home

pacstrap -K /mnt base linux linux-firmware iproute2 networkmanager vim

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

arch-chroot /mnt hwclock --systohc

sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /mnt/etc/locale.gen

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

cp ./etc_locale.conf /mnt/etc/locale.conf























