#!/usr/bin/env bash

# Get the grub install parameter
source /install/layer0/grubinstall.sh

echo "# System parameters"
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "fr_FR.UTF-8" >> /etc/locale.gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
echo "francoisTest" > /etc/hostname

echo "# Pacman optimisation"
pacman -S reflector --noconfirm && reflector --country France -l 5 -p http --sort rate --save /etc/pacman.d/mirrorlist
cp /install/pacman.conf /etc/pacman.conf
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
pacman -Syyu

echo "# Installing wifi and internet services"
pacman -S iwd dhcpcd --noconfirm && systemctl enable iwd && systemctl enable dhcpcd

echo "# Creating root password:"
printf "Enter root password\n>"
passwd

echo "# Installation des outils de base"
pacman -S zsh grml-zsh-config zsh-completions base-devel amd-ucode wget git --noconfirm

echo "# Creating standard user:"
printf "Enter user name\n>"
read -r username
useradd -m -G wheel -s /bin/zsh "$username"
printf 'Enter %s'\''s password\n>' "$username"
passwd "$username"

# TODO add wheel to sudoers
