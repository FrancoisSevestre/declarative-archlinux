#!/usr/bin/env bash

# Get the grub install parameter
source /install/layer0/grubinstall.sh

# System parameters
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "fr_FR.UTF-8" >> /etc/locale.gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
echo "francoisTest" > /etc/hostname

# Pacman optimisation
# TODO activate paralleldocnload, Color and ILoveCandy options for pacman
pacman -S reflector --noconfirm 
reflector --country France -l 5 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syyu --noconfirm

# Installing wifi and internet services
pacman -S iwd dhcpcd --noconfirm 
systemctl enable iwd
systemctl enable dhcpcd

# Creating root password:
printf "Enter root password\n>"
passwd

# Base tools installation
pacman -S zsh grml-zsh-config zsh-completions \
  base-devel \
  amd-ucode \
  grub efibootmgr os-prober \
  wget git --noconfirm

# Creating standard user:
printf "Enter user name\n>"
read -r username
useradd -m -G wheel -s /bin/zsh "$username"
printf 'Enter %s'\''s password\n>' "$username"
passwd "$username"

# grub-install and config
grub-install --target=x86_64-efi --efi-directory=/boot/grub/ --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# TODO add wheel to sudoers
