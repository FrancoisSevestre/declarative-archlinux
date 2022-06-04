#!/usr/bin/env bash

# Functions
source /install/layer0/functions.sh

# logs in tmux side window
tmux split-window -l 14
tmux send 'tail -f install.log' ENTER

# Get parameters
source /install/layer0/config.cfg

# Pacman optimisation
log -c "unbuffer -p pacman -S reflector --noconfirm" -m "Installing Reflector" -l "LAYER0"
log -c "reflector -l 5 -p http --sort rate --save /etc/pacman.d/mirrorlist" -m "Updating mirror list with reflector" -l "LAYER0"
#log -c "pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com" -m "Fetching chaotic AUR keys" -l "LAYER0" # TODO re-enable with security
#log -c "pacman-key --lsign-key FBA220DFC880C036" -m "Adding keys" -l "LAYER0"
#log -c "pacman -U https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst --noconfirm" \
#  -m "Installing chaotic AUR keyring" -l "LAYER0"
log -c "cp /install/pacman.conf /etc/pacman.conf" -m "Copying pacman configuration" -l "LAYER0"
log -c "unbuffer -p pacman -Syyu --noconfirm" -m "Updating repos" -l "LAYER0"

# Installing wifi and internet services
# TODO take in account the specified network parameters
log -c "unbuffer -p pacman -S iwd dhcpcd --noconfirm" -m "Installing network tools" -l "LAYER0"
log -c "systemctl enable iwd" -m "enabling iwd servicea" -l "LAYER0"
log -c "systemctl enable dhcpcd" -m "enabling dhcpcd service" -l "LAYER0"

# Base tools installation
log -c "unbuffer -p pacman -S zsh grml-zsh-config zsh-completions \
  base-devel \
  amd-ucode \
  grub efibootmgr os-prober \
  wget git vim --noconfirm" -m "Installing base tools" -l "LAYER0"

# Creating root password:
echo root:$root_passwd | chpasswd

# Creating standard user:
useradd -m -G wheel -s /bin/zsh $user_name
echo $user_name:$user_passwd | chpasswd

# grub-install and config
# TODO choose MBR or EFI?
# TODO check if grub is to be installed
log -c "grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB" -m "Installing grub" -l "LAYER0"
log -c "grub-mkconfig -o /boot/grub/grub.cfg" -m "Generating grub config" -l "LAYER0"

# TODO add wheel to sudoers
tmux kill-session
exit
