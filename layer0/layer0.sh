#!/usr/bin/env bash

# Get parameters
source /install/layer0/config.cfg

# System parameters
ln -sf /usr/share/zoneinfo/"$zone_info" /etc/localtime
echo "$locale" >> /etc/locale.gen
echo "LANG=$locale" > /etc/locale.conf
echo "KEYMAP=$vconsole" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname

# Pacman optimisation
# TODO activate paralleldownload, Color and ILoveCandy options for pacman
pacman -S reflector --noconfirm 
reflector -l 5 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syyu --noconfirm

# Installing wifi and internet services
# TODO take in account the specified network parameters
pacman -S iwd dhcpcd --noconfirm 
systemctl enable iwd
systemctl enable dhcpcd

# Base tools installation
pacman -S zsh grml-zsh-config zsh-completions \
  base-devel \
  amd-ucode \
  grub efibootmgr os-prober \
  wget git vim --noconfirm

# Creating root password:
echo "root:$root_passwd" | chpasswd

# Creating standard user:
useradd -m -G wheel -s /bin/zsh "$user_name"
echo "$user_name:$user_passwd" | chpasswd

# grub-install and config
# TODO choose MBR or EFI?
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# TODO add wheel to sudoers
