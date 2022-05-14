#!/usr/bin/env bash

tmux split-window -l 14
tmux send 'tail -f -s 0.3 install.log; exit' ENTER

# Functions
source functions.sh

reset-screen

# Check for dependencies and user privileges
log0 && is_OK "is_root" "Checking user privileges" \
  "Error: This script must be run as root. Exiting."

# Check if the system is archlinux
log0 && is_OK "pacman -V" "Looking for pacman" \
  "pacman is not present on the system. Exiting"

# importing configuration
source config.cfg

if [ $install_type == "full_disk" ]; then
  log0 && warning  "The disk $disk will be erased."
  sleep 5
  log0 && is_OK "parted -s /dev/$disk mklabel $part_table_type mkpart bootprt fat32  2048s $boot_part_size mkpart osprt $os_part_type $boot_part_size $os_part_size" \
      "Creating partitions on the disk" "Error while partitioning. Exiting"

  boot_part="$disk"1 # TODO check partition names before continue
  os_part="$disk"2

elif [ $install_type == "custom_part" ]; then
  # check specified partitions
  lsblk -l -o NAME | grep "$os_part" || log0 && red "OS partition not found."
  if [ "$boot_part" != false ]; then
    lsblk -l -o NAME | grep "$boot_part" || log0 && red "Boot partition not
    found." 
  fi

else
  log0 && "$(red "Error in config file (install_type). Exiting")"
  exit 1
fi

# Formating partitions
log0 && is_OK "mkfs -t $os_part_type /dev/$os_part" "Formatting partition $os_part" \
    "Error while formatting $os_part. Exiting"

if [ "$boot_part" != false ]; then
  log0 && is_OK "mkfs.fat -F 32 /dev/$boot_part" "Formatting partition $boot_part" \
    "Error while formatting $boot_part. Exiting"
fi

# Mounting partitions and installing base packages and Linux 
  # Mounting partitions
log0 && is_OK "mount --mkdir /dev/$os_part /mnt" "Mounting $os_part" \
   "Error while mounting $os_part. Exiting" 

if [ "$boot_part" != false ]; then
  log0 && is_OK "mount --mkdir /dev/$boot_part /mnt/boot" "Mounting $boot_part" \
     "Error while mounting $boot_part. Exiting" 
fi

  # Pacstrap install
log0 && is_OK "unbuffer -p pacstrap -C pacman.conf /mnt base linux linux-firmware linux-headers" \
  "Installing base packages (this may take a while)" "Error while installing base packages. Exiting"

# Passing Layer 0 script to partition
log0 && is_OK "mkdir /mnt/install" "Creating scripts folder" \
  "Error while creating scripts folder."

log0 && is_OK "cp -t layer0/ functions.sh config.cfg" "Copying files before transfert" "Error while copying"
log0 && is_OK "cp -r layer0/ /mnt/install/layer0/" "Transferring scripts" \
  "Error while transfering scripts."
log0 && is_OK "cp pacman.conf /mnt/install/" "Copying pacman
configuration" "Error while copying"

# Chroot into installed partition
log0 && is_OK "chmod +x /mnt/install/layer0/layer0.sh" "chmod scripts" \
  "Error in chmod scripts."
sleep 2

killall tail
