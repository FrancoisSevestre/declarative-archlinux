#!/usr/bin/env bash

# Functions
source functions.sh

log -e -m "Preparing installation" -l "BASE INSTALL"
chmod u+x base-installer.sh layer0/start-layer0.sh layer0/layer0.sh

# Installing tmux, expect, yq
log -c "pacman -S tmux expect yq --noconfirm" -m "Installing misc tools" -l "BASE INSTALL"
log -e -m "Launching installation" -l "BASE INSTALL"

# Launching tmux session
tmux new-session -s base -- ./base-installer.sh

log -e -m "Chrooting" -l "BASE INSTALL"
arch-chroot /mnt ./install/layer0/start-layer0.sh

log -e -m "Unmounting partitions" -l "BASE INSTALL"
umount /mnt/boot
umount /mnt
sleep 2
log -e -m "Installation completed" -l "CLOSING"
