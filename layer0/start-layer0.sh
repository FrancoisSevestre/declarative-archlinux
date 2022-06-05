#!/usr/bin/env bash

# Functions
source /install/layer0/functions.sh
log -c "cd /install/layer0/" -m "Moving to install directory" -l "LAYER0"

# Installing tmux, expect, yq
log -c "pacman -S tmux expect yq --noconfirm" -m "Installing misc tools" -l "LAYER0"

# Reading config file
zone_info=$(readconfig system.zone_info)
locale=$(readconfig system.locale)
charset=$(readconfig system.charset)
vconsole=$(readconfig system.vconsole)
hostname=$(readconfig system.hostname)

# System parameters
log -c "ln -sf /usr/share/zoneinfo/$zone_info /etc/localtime" -m "Defining timezone" -l "LAYER0"
log -c "echo $locale $charset" -f "/etc/locale.gen" -m "Changing locale settings" -l "LAYER0"
log -c "locale-gen" -m "Generating locale configuration" -l "LAYER0"
log -c "echo LANG=$locale" -f "/etc/locale.conf" -m "Setting language" -l "LAYER0"
log -c "echo KEYMAP=$vconsole" -f "/etc/vconsole.conf" -m "Setting Keyboard configuration" -l "LAYER0"
log -c "echo $hostname" -f "/etc/hostname" -m "Setting hostname" -l "LAYER0"

# Launching tmux window
export LANG=$locale
tmux new-session -s chroot -- ./layer0.sh
