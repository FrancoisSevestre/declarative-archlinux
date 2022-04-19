#!/usr/bin/env bash

# Welcome message
welcome_msg="## AutoInstall: ArchLinux ##"

# Functions
reset-screen()
{
  clear
  echo "$welcome_msg"
}

# Check for dependencies and user privileges
  # Checking user privileges
if ((EUID)); then 
  echo "#! This script must be run as root. Exiting."
  exit 1
fi

# Check if the system is archlinux
pacman -V > /dev/null 2>&1 || echo "pacman is not present on the system."

# Import config
source layer0/config.cfg
if [ $install_type == "full_disk" ]; then
  echo "The disk $disk will be erased"
  parted -s "/dev/$disk" mklabel "$part_table_type" \
    mkpart bootprt fat32  0.0 "$boot_part_size" \
    mkpart osprt "$os_part_type" "$boot_part_size" "$os_part_size"
  boot_part="$disk"1
  os_part="$disk"2

elif [ $install_type == "custom_part" ]; then
  echo "this" # TODO

else
  echo "Error in config file (install_type). Exiting" && exit 1
fi

# Formating partitions
mkfs -t "$os_part_type" /dev/"$os_part"
if [ "$boot_part" != false ]; then
  mkfs.fat -F 32 /dev/"$boot_part"
fi
# Mounting partitions and installing base packages and Linux 
  # Mounting partitions
mount --mkdir /dev/"$os_part" /mnt
mount --mkdir /dev/"$boot_part" /mnt/boot

  # Pacstrap install
pacstrap -C pacman.conf /mnt base linux linux-firmware linux-headers

# Passing Layer 0 script to partition
mkdir /mnt/install
cp -r layer0/ /mnt/install/layer0/

# Chroot into installed partition
chmod +x /mnt/install/layer0/layer0.sh
arch-chroot /mnt ./install/layer0/layer0.sh
