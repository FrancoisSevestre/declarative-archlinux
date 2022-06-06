#!/usr/bin/env bash

# Functions
source /install/layer0/functions.sh
log -c "cd /install/layer0/" -m "Moving to install directory" -l "LAYER0"

# logs in tmux side window
tmux split-window -l 14
tmux send 'tail -f install.log' ENTER


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

# TODO Determining CPU brand, installing ucode
cpu_vendor=$(grep -i "vendor_id" /proc/cpuinfo| uniq | cut -d ' ' -f 2)
if [ "$cpu_vendor" == "AuthenticAMD" ]; then
  ucode_package="amd-ucode"
elif [ "$cpu_vendor" == "GenuineIntel" ]; then
  ucode_package="intel-ucode"
else
  ucode_package=""
fi

# Base tools installation
log -c "unbuffer -p pacman -S zsh \
  base-devel \
  $ucode_package \
  grub efibootmgr os-prober \
  wget git vim --noconfirm" -m "Installing base tools" -l "LAYER0"

# Reading config file
root_passwd=$(readconfig system.root_password)

# Creating root password:
log -e -m "Setting root password" -l "LAYER0"
echo root:"$root_passwd" | chpasswd

# Creating standard user:
  # Looping throught users
(( user_index = $(readconfig "system.users | length") - 1 ))
for user in $(seq 0 $user_index)
do
  user_name=$(readconfig "system.users[$user].name")
  user_passwd=$(readconfig "system.users[$user].password")
  user_shell=$(readconfig "system.users[$user].shell")

  log -e -m "Creating user $user_name" -l "LAYER0"
  useradd -m -s "$user_shell" "$user_name"
  echo "$user_name":"$user_passwd" | chpasswd

  (( group_index = $(readconfig "system.users[$user].groups | length") - 1 ))
  for group in $(seq 0 $group_index)
  do
    usermod -a -G "$(readconfig "system.users[$user].groups[$group]")" "$user_name"
  done
done

# Add wheel to sudoers
sed 's/0,/# %wheel/s//%wheel/' /etc/sudoers

# grub-install and config
# TODO choose MBR or EFI?
if [ "$(readconfig "install_type")" == "disk" ] || [ "$(readconfig "custom_install.boot_part.enable")" != false ]; then
  log -c "grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB" -m "Installing grub" -l "LAYER0"
  log -c "grub-mkconfig -o /boot/grub/grub.cfg" -m "Generating grub config" -l "LAYER0"
fi

# Installing additional packages
log -c "unbuffer -p pacman -S $(readconfig "system.packages[]") --noconfirm" -m "Installing additionnal packages" -l "test"

# Starting additionnal services
(( services = $(readconfig "system.services | length") - 1 ))
for service in $(seq 0 $services)
do
  
  log -c "systemctl enable $(readconfig "system.services[$service]")" -m "enabling service $(readconfig "system.services[$service]")" -l "LAYER0"
done


log -e -m "Layer0 install complete" -l "LAYER0"
sleep 3
tmux kill-session
exit
