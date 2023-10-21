#!/bin/bash

export disk="/dev/nvme1n1"

echo "==> open main crypted partition"
cryptsetup open ${disk}p1 qsync

echo "==> creation of qsync FS"
mkfs.btrfs -L qsync /dev/mapper/qsync -f

echo "==> mount qsync partition"
mount /dev/mapper/qsync /mnt

echo "Create BTRFS subvolumes"
btrfs subvolume create /mnt/@qsync
btrfs subvolume create /mnt/@MyHomeEbooks
btrfs subvolume create /mnt/@MyHomeIT
btrfs subvolume create /mnt/@MyHomeITsoftware
btrfs subvolume create /mnt/@MyHomeMovies
btrfs subvolume create /mnt/@MyHomeMusique
btrfs subvolume create /mnt/@MyHomePersoPhotos
btrfs subvolume create /mnt/@MyHomePersoVideos
btrfs subvolume create /mnt/@MyHomePrivacyPhotos
btrfs subvolume create /mnt/@MyHomePrivacyVideos
btrfs subvolume create /mnt/@MyHomeOrg
btrfs subvolume create /mnt/@MyHomeTmp
btrfs subvolume create /mnt/@MyHomeVMs

echo "umount"
umount /mnt

echo "mount all subvolumes"
export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
echo "."
mount -o ${sv_opts},subvol=@qsync /dev/mapper/qsync /mnt
mkdir -p /mnt/{MyHomeEbooks,MyHomeIT,MyHomeITsoftware,MyHomeMovies,MyHomeMusique,MyHomePersoPhotos,MyHomePersoVideos,MyHomePrivacyPhotos,MyHomePrivacyVideos,MyHomeOrg,MyHomeTmp,MyHomeVMs}
mount -o ${sv_opts},subvol=@MyHomeEbooks /dev/mapper/qsync /mnt/MyHomeEbooks
mount -o ${sv_opts},subvol=@MyHomeIT /dev/mapper/qsync /mnt/MyHomeIT
mount -o ${sv_opts},subvol=@MyHomeITsoftware /dev/mapper/qsync /mnt/MyHomeITsoftware
mount -o ${sv_opts},subvol=@MyHomeMovies /dev/mapper/qsync /mnt/MyHomeMovies
mount -o ${sv_opts},subvol=@MyHomeMusique /dev/mapper/qsync /mnt/MyHomeMusique
mount -o ${sv_opts},subvol=@MyHomePersoPhotos /dev/mapper/qsync /mnt/MyHomePersoPhotos
mount -o ${sv_opts},subvol=@MyHomePersoVideos /dev/mapper/qsync /mnt/MyHomePersoVideos
mount -o ${sv_opts},subvol=@MyHomePrivacyPhotos /dev/mapper/qsync /mnt/MyHomePrivacyPhotos
mount -o ${sv_opts},subvol=@MyHomePrivacyVideos /dev/mapper/qsync /mnt/MyHomePrivacyVideos
mount -o ${sv_opts},subvol=@MyHomeOrg /dev/mapper/qsync /mnt/MyHomeOrg
mount -o ${sv_opts},subvol=@MyHomeTmp /dev/mapper/qsync /mnt/MyHomeTmp
mount -o ${sv_opts},subvol=@MyHomeVMs /dev/mapper/qsync /mnt/MyHomeVMs


