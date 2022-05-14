#!/usr/bin/env bash

# Functions
source functions.sh
chmod u+x base-installer.sh layer0/start-layer0.sh layer0/layer0.sh

# Installing tmux
log0 && is_OK "pacman -S tmux expect --noconfirm" "Installing misc tools" "Failed"

log0 && echo "Starting install"
tmux new-session -s main './base-installer.sh'

log0 && echo "Chrooting"
arch-chroot /mnt ./install/layer0/start-layer0.sh
umount /mnt/boot
umount /mnt
sleep 2
