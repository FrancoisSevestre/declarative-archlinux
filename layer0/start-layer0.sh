#!/usr/bin/env bash

# Get parameters
source /install/layer0/config.cfg

# Functions
source /install/layer0/functions.sh

# System parameters
log0 && is_OK "ln -sf /usr/share/zoneinfo/$zone_info /etc/localtime" "Defining timezone" "Failed"
echo "$locale" >> /etc/locale.gen 
locale-gen
echo "LANG=$language" > /etc/locale.conf
echo "KEYMAP=$vconsole" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname

# Installing tmux
log0 && is_OK "pacman -S tmux --noconfirm" "Installing misc tools" "Failed"
export LANG=fr_FR.UTF-8

# Launching tmux window
tmux new-session -s chroot './install/layer0/layer0.sh'
