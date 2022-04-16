#!/usr/bin/env bash

# Functions


# Welcome message
clear
welcome_msg="## AutoInstall: ArchLinux ##"
echo "$welcome_msg"

# Check for dependencies and user privileges
  # Checking user privileges
if ((EUID)); then 
  echo "#! This script must be run as root. Exiting."
  exit 1
fi

# User input: Choose partitions to install
echo "# Devices:"
lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
  # Initialize install parameters
format_disk=false
partition=false
boot_partition=false
  # Ask for install type
echo "#? Select the type of install:"
select installtype in "Whole disk install" "Partition install" "Partition install + boot"
do
  case $installtype in
    "Whole disk install")
      format_disk=true
      break;;
    "Partition install")
      partition=true
      break;;
    "Partition install + boot")
      partition=true
      boot_partition=true
      break;;
    *)
      echo "#! Invalid Entry"
      break;;
  esac
done

# Ask user for disk/partitions to use
grubinstall=false
  # User wants to erase disk
if [ $format_disk == true ]; then
  echo "#? The disk will be formated, select which one:"
  # Ask user which disk to format
  lsblk -d -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
  select disk in $(lsblk -nd -o NAME)
  do
    echo "# the disk $disk will be erased" # TODO
    # create partitions
    parted -s "/dev/$disk" mklabel gpt mkpart bootprt fat32 0.0 500.0MB mkpart osprt ext4 500.MB0 100%
    bootprt="$disk"1
    osprt="$disk"2
    grubinstall=true
    mkfs.fat -F 32 /dev/"$bootprt"
    mkfs.ext4 /dev/"$osprt"
    lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
    break
  done

  # User wants to install system in partition
elif [ $partition == true ]; then
  # Ask user on wich partition to install the system
  clear
  lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
  echo "#? The system will be installed on a disk partition, select wich one."
  select part in $(lsblk -l -o NAME | grep "[0-9]")
    do
      echo "# The system will be installed in the partition $part" # TODO
      # check if partition exists and is mounted
      # check partition format
      # Install linux on partition
      break
    done

  if [ $boot_partition == true ]; then
    # Ask user on which partition to install the grub
    clear
    lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
    echo "#? A boot partition will be installed, select wich one."
    select bpart in $(lsblk -l -o NAME | grep "[0-9]")
      do
        echo "# The boot files  will be installed in the partition $bpart" # TODO
        # check if partition exists and is mounted
        # check partition format
        # install grub
        break
      done
  fi
else
  echo "Error. Exiting."
  exit 1
fi

# Mounting partitions and installing base packages and Linux 
  # Mounting partitions
mkdir /mnt
mount "/dev/$osprt" /mnt
mount --mkdir "/dev/$bootprt" /mnt/boot
# Pacstrap install
pacstrap -ic /mnt base linux linux-firmware linux-headers vim
# Adding grubinstall infos into the layer0 script
echo "grubinstall=$grubinstall" > layer0/grubinstall.sh
# Passing Layer 0 script to partition
mkdir /mnt/install
cp layer0/ /mnt/install/layer0/
# Chroot into installed partition
chmod +x /mnt/install/layer0/layer0.sh
arch-chroot /mnt ./install/layer0/layer0.sh
