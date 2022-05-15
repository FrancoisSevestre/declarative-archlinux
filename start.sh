#!/usr/bin/env bash

# Functions
source functions.sh
chmod u+x base-installer.sh layer0/start-layer0.sh layer0/layer0.sh

# Installing tmux
log -c "pacman -S tmux expect --noconfirm" -m "Installing misc tools" -l "BASE INSTALL"
log -e -m "Launching installation" -l "BASE INSTALL"

# Launching tmux session
tmux new-session -s main './base-installer.sh'

log -e -m "Chrooting" -l "BASE INSTALL"
arch-chroot /mnt ./install/layer0/start-layer0.sh

log -e -m "Unmounting partitions" -l "BASE INSTALL"
umount /mnt/boot
umount /mnt
sleep 2
