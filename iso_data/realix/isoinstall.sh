#!/usr/bin/env bash

# Find the BOOT drive 
W=$(lsblk -f | grep -B1 ' WORK ' | head -1 | head -c 3)

if [[ -n $W ]]; then
    # Yes, find the boot drive
    if [[ $W == "sdb" ]]; then
      BOOT="/dev/sda"
      WORK="/dev/sdb"
    else
      BOOT="/dev/sdb"
      WORK="/dev/sda"
    fi 
else
    BOOT="/dev/sda"
    WORK="/dev/sdb"
fi

BOOTP1="$BOOT"1
BOOTP2="$BOOT"2
BOOTP3="$BOOT"3

set +e
# If BOOT is mounted for any reason, unmount it
umount $BOOTP1 &> /dev/null
umount $BOOTP3 &> /dev/null
umount $BOOTP1 &> /dev/null

swapoff $BOOTP2 &> /dev/null

# ZAP the boot drive
wipefs -af $BOOTP1 &> /dev/null
wipefs -af $BOOTP2 &> /dev/null
wipefs -af $BOOTP3 &> /dev/null
wipefs -af $BOOT &> /dev/null
set -e

# Format the boot drive
sfdisk -f $BOOT << EOF
label: gpt
2048,500M,U,*
,1G,S,
,
EOF

mkswap $BOOTP2
swaplabel -L SWAP $BOOTP2
swapon $BOOTP2

mkfs.fat -F 32 $BOOTP1
sync ; sleep 1    
fatlabel $BOOTP1 BOOT
mkfs.ext4 $BOOTP3 -L ROOT
sync ; sleep 1    
mkdir -p /mnt
mount /dev/disk/by-label/ROOT /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

# Format the work drive, IF and only IF it does not already exist
# DO nothing if we don't have a work drive at all
if [[ -e $WORK && ! -e /dev/disk/by-label/WORK ]]; then
  sfdisk $WORK << EOF
  label: gpt
  ,
EOF
  #mkfs.ext4 "$WORK"1 -L WORK
  mkfs.btrfs "$WORK"1 -L WORK
fi

# Must be done in this order
nixos-generate-config --root /mnt
cp -rL /root/realix /mnt/etc/nixos
cp -rL /mnt/etc/nixos/realix/* /mnt/etc/nixos

nix-channel --update

cd /mnt/
RES=1
while [[ 0 != $RES ]]; do
  nixos-install --no-root-password --impure --flake /mnt/etc/nixos#gizmo
  RES=$?
done

shutdown now
