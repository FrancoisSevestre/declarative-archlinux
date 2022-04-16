#!/usr/bin/env bash

# Functions


# Welcome message
clear
welcome_msg="## AutoInstall: ArchLinux ##"
echo "$welcome_msg"

# Check for dependencies and user privileges
if ((EUID)); then # Checking user privileges
  echo "#! This script must be run as root. Exiting."
  exit 1
fi

# User input: Choose partitions to install
echo "# Devices:"
lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
echo "#? Select the type of install:" # Ask for install type
format_disk=false
partition=false
boot_partition=false
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
if [ $format_disk == true ]; then # User wants to erase disk
  echo "#? The disk will be formated, select which one:"
  # Ask user which disk to format
  lsblk -d -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
  select disk in $(lsblk -nd -o NAME)
  do
    echo "# the disk $disk will be erased" # TODO
    # create partitions
    parted -s "/dev/$disk" mklabel gpt mkpart bootprt fat32 0.0 500.0 mkpart osprt ext4 500.0 100%
    mkfs.fat -F 32 /dev/"$disk"1
    mkfs.ext4 /dev/"$disk"2
    lsblk -o NAME,MOUNTPOINTS,FSTYPE,FSVER,SIZE && echo ""
    sleep 10
    
    # Use parted
    # install linux
    # install grub
    break
  done

elif [ $partition == true ]; then # User wants to install system in partition
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
# Pacstrap install
# Passing Layer 0 script to partition
