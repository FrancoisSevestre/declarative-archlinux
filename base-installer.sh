#!/usr/bin/env bash

# Launching logs in split window
tmux split-window -l 14
tmux send 'tail -f -s 0.3 install.log' ENTER # TODO The file has to exist

# Functions
source functions.sh

reset-screen

# Check for dependencies and user privileges
log -c "is_root" -m "Checking user privileges" \
  -n "Error: This script must be run as root." -l "BASE INSTALL"

# Check if the system is archlinux
log -c "pacman -V" -m "Looking for pacman" \
  -n "pacman is not present on the system." -l "BASE INSTALL"

# Read install type
log -e -m "Reading configuration file" -l "BASE INSTALL"
install_type=$(readconfig install_type)

# Full disk install
if [ "$install_type" == "disk" ]; then

  # Read config for disk install
  disk=$(readconfig disk_install.disk)
  part_table_type=$(readconfig disk_install.part_table_type)
  boot_part_size=$(readconfig disk_install.boot_part.size)
  os_part_format=$(readconfig disk_install.os_part.format)
  os_part_size=$(readconfig disk_install.os_part.size)

  log -e -m "$(warning  "The disk $disk will be erased. Use Ctrl+C to stop.")" -l "BASE INSTALL"
  sleep 10
  log -c "parted -s /dev/$disk mklabel $part_table_type mkpart bootprt fat32  2048s $boot_part_size mkpart osprt $os_part_format $boot_part_size $os_part_size" \
      -m "Creating partitions on the disk" -l "BASE INSTALL" # TODO Split the command

  boot_part="$disk"1 # TODO check partition names before continue
  os_part="$disk"2
  # TODO Handle home and swap partitions

# Custom partitions install
elif [ "$install_type" == "custom_part" ]; then

  # Read config for disk install
  os_part=$(readconfig custom_install.os_part.location)
  os_part_format=$(readconfig custom_install.os_part.format)
  

  # check specified partitions
  lsblk -l -o NAME | grep "$os_part" || log -e -m "$(red "OS partition not found.")" -l "BASE INSTALL"
  if [ "$(readconfig custom_install.boot_part.enable)"  != false ]; then
    boot_part=$(readconfig custom_install.boot_part.location) # read config file
    lsblk -l -o NAME | grep "$boot_part" || log -e -m "$(red "Boot partition not found.")" -l "BASE INSTALL"
  fi

  # TODO Handle home and swap partitions

# If config failed
else
  log -e -m "$(red "Error in config file (install_type). Exiting")" -l "BASE INSTALL"
  exit 1
fi

# Formating partitions
log -c "mkfs -t $os_part_format /dev/$os_part" -m "Formatting partition $os_part" -l "BASE INSTALL"
   
if [ "$(readconfig custom_install.boot_part.enable)" != false ]; then
  log -c "mkfs.fat -F 32 /dev/$boot_part" -m "Formatting partition $boot_part" -l "BASE INSTALL"
fi

# Mounting partitions and installing base packages and Linux 
  # Mounting partitions
log -c "mount --mkdir /dev/$os_part /mnt" -m "Mounting $os_part" -l "BASE INSTALL"

if [ "$(readconfig custom_install.boot_part.enable)" != false ]; then
  log -c "mount --mkdir /dev/$boot_part /mnt/boot" -m "Mounting $boot_part" -l "BASE INSTALL"
fi

  # Pacstrap install
log -c "unbuffer -p pacstrap -C pacman.conf /mnt base linux linux-firmware linux-headers" \
  -m "Installing base packages (this may take a while)" -l "BASE INSTALL"

# Creating fstab
log -c "genfstab -U /mnt" -f "/mnt/etc/fstab" -l "BASE INSTALL" -m "Creating fstab" # TODO Check if user is sudo

# Passing Layer 0 script to partition
log -c "mkdir /mnt/install" -m "Creating scripts folder" -l "BASE INSTALL"
log -c "cp -t layer0/ functions.sh config.yml" -m "Copying files before transfert" -l "BASE INSTALL"
log -c "cp -r layer0/ /mnt/install/layer0/" -m "Transferring scripts" -l "BASE INSTALL"
log -c "cp pacman.conf /mnt/install/" -m "Copying pacman configuration" -l "BASE INSTALL"
log -c "cp -t /mnt/ install.log" -m "Copying logs" -l "BASE INSTALL" -a
log -c "chmod +x /mnt/install/layer0/*" -m "chmod scripts" -l "BASE INSTALL" # TODO Check necessity

log -e -m "Base install completed" -l "BASE INSTALL"
sleep 2
tmux kill-session
