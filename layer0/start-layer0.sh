#!/usr/bin/env bash

# Get parameters
source /install/layer0/config.cfg

# Functions
source /install/layer0/functions.sh

# System parameters
log -c "ln -sf /usr/share/zoneinfo/$zone_info /etc/localtime" -m "Defining timezone" -l "LAYER0"
log -c "echo $locale" -f "/etc/locale.gen" -m "Changing locale settings" -l "LAYER0"
log -c "locale-gen" -m "Generating locale configuration" -l "LAYER0"
log -c "echo LANG=$language" -f "/etc/locale.conf" -m "Setting language" -l "LAYER0"
log -c "echo KEYMAP=$vconsole" -f "/etc/vconsole.conf" -m "Setting Keyboard configuration" -l "LAYER0"
log -c "echo $hostname" -f "/etc/hostname" -m "Setting hostname" -l "LAYER0"

# Installing tmux
log -c "pacman -S tmux expect --noconfirm" -m "Installing misc tools" -l "LAYER0"
export LANG=fr_FR.UTF-8

# Launching tmux window
tmux new-session -s chroot './install/layer0/layer0.sh'
