#!/usr/bin/env bash

# Functions
source /install/layer0/functions.sh

# logs in tmux side window
tmux split-window -l 14
tmux send 'tail -f install.log; exit' ENTER

# Get parameters
source /install/layer0/config.cfg

# Pacman optimisation
log0 && is_OK "unbuffer -p pacman -S reflector --noconfirm" "Installing Reflector" "Failed"
log0 && is_OK "reflector -l 5 -p http --sort rate --save /etc/pacman.d/mirrorlist" "Updating mirror list with reflector" "Failed"
#log0 && is_OK "pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com" "Fetching chaotic AUR keys" "Failed"
#log0 && is_OK "pacman-key --lsign-key FBA220DFC880C036" "Adding keys" "Failed"
#log0 && is_OK "pacman -U https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst --noconfirm" \
#  "Installing chaotic AUR keyring" "Failed"
log0 && is_OK "cp /install/pacman.conf /etc/pacman.conf" "Copying pacman
configuration" "Error while copying"
log0 && is_OK "unbuffer -p pacman -Syyu --noconfirm" "Updating repos" "Error"

# Installing wifi and internet services
# TODO take in account the specified network parameters
log0 && is_OK "unbuffer -p pacman -S iwd dhcpcd --noconfirm" "Installing network tools" "Failed"
log0 && is_OK "systemctl enable iwd" "enabling iwd servicea" "Failed"
log0 && is_OK "systemctl enable dhcpcd" "enabling dhcpcd service" "Failed"

# Base tools installation
log0 && is_OK "unbuffer -p pacman -S zsh grml-zsh-config zsh-completions \
  base-devel \
  amd-ucode \
  grub efibootmgr os-prober \
  wget git vim --noconfirm" "Installing base tools" "Error"

# Creating root password:
echo root:$root_passwd | chpasswd

# Creating standard user:
useradd -m -G wheel -s /bin/zsh $user_name
echo $user_name:$user_passwd | chpasswd

# grub-install and config
# TODO choose MBR or EFI?
# TODO check if grub is to be installed
log0 && is_OK "grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB" "Installing grub" "Failed"
log0 && is_OK "grub-mkconfig -o /boot/grub/grub.cfg" "Generating grub config" "Failed"

# TODO add wheel to sudoers
killall tail
