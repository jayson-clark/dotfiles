#!/bin/bash

# Git URL prefix for cloning repositories
GIT_URL_PREFIX="https://github.com/jayson-clark"

# Function to print section headers
print_header() {
  echo ""
  echo "------------------ $1 --------------------"
  echo ""
}

# Function to check if there is an ethernet connection
check_internet() {
  print_header "Network Connectivity"
  if ping -c 1 archlinux.org &> /dev/null; then
    echo "Internet connection detected."
  else
    echo "No internet connection detected. Setting up WiFi."
    setup_wifi
  fi
}

# Function to set up WiFi if no ethernet connection is available
setup_wifi() {
  read -p "Enter WiFi SSID: " ssid
  read -sp "Enter WiFi Password: " password
  echo ""
  iwctl station wlan0 connect "$ssid"
  if [ $? -ne 0 ]; then
    echo "WiFi connection failed. Exiting..."
    exit 1
  fi
}

# Ask for the disk to install Arch Linux
select_disk() {
  print_header "Disk Selection"
  lsblk
  echo "Please enter the drive to install Arch Linux on (e.g., /dev/sda):"
  read drive
  echo "WARNING: This will erase all data on $drive. Do you want to continue? (y/n)"
  read confirm
  if [[ $confirm != "y" ]]; then
    echo "Installation aborted."
    exit 1
  fi
}

# Partition and format the disk
partition_and_format_disk() {
  print_header "Partitioning and Formatting Disk"
  echo "Partitioning and formatting the drive..."
  parted "$drive" mklabel gpt
  parted "$drive" mkpart primary fat32 1MiB 512MiB
  parted "$drive" set 1 esp on
  parted "$drive" mkpart primary ext4 512MiB 100%

  mkfs.fat -F32 "${drive}1"
  mkfs.ext4 "${drive}2"
}

# Mount the partitions
mount_partitions() {
  print_header "Mounting Partitions"
  echo "Mounting partitions..."
  mount "${drive}2" /mnt
  mkdir /mnt/boot
  mount "${drive}1" /mnt/boot
}

# Install base system
install_base_system() {
  print_header "Installing Base System"
  echo "Installing base system..."
  pacstrap /mnt base linux linux-firmware git
}

# Generate fstab
generate_fstab() {
  print_header "Generating FSTAB"
  echo "Generating fstab..."
  genfstab -U /mnt >> /mnt/etc/fstab
}

# Set up systemd-boot
setup_systemd_boot() {
  print_header "Setting Up Systemd-Boot"
  echo "Setting up systemd-boot..."
  arch-chroot /mnt bootctl install
  echo "default  arch" > /mnt/boot/loader/loader.conf

  cat <<EOF > /mnt/boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value ${drive}2) rw
EOF
}

# Set the time zone, language, hostname, etc.
final_setup() {
  print_header "Final System Setup"
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
  arch-chroot /mnt hwclock --systohc
  echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
  echo "archlinux" > /mnt/etc/hostname
}

# Create a user with the specified username and password
create_user() {
  print_header "User Creation"
  read -p "Enter username for the new user: " username
  arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$username"
  echo "Set password for $username"
  arch-chroot /mnt passwd "$username"
}

# Set root password
set_root_password() {
  print_header "Root Password Setup"
  echo "Set the root password"
  arch-chroot /mnt passwd
}

# Function to ask if you want to install your custom software
install_custom_software() {
  print_header "Custom Software Installation"

  echo "Would you like to install your custom software? (y/n)"
  read install_custom

  if [[ $install_custom == "y" ]]; then
    # Ask about each piece of software and clone repos accordingly
    echo "Do you want to install dwm? (y/n)"
    read install_dwm
    if [[ $install_dwm == "y" ]]; then
      arch-chroot /mnt git clone "$GIT_URL_PREFIX/dwm.git" /home/$username/dwm
      arch-chroot /mnt bash -c "cd /home/$username/dwm && ./install.sh"
    fi

    echo "Do you want to install dmenu? (y/n)"
    read install_dmenu
    if [[ $install_dmenu == "y" ]]; then
      arch-chroot /mnt git clone "$GIT_URL_PREFIX/dmenu.git" /home/$username/dmenu
      arch-chroot /mnt bash -c "cd /home/$username/dmenu && ./install.sh"
    fi

    echo "Do you want to install st? (y/n)"
    read install_st
    if [[ $install_st == "y" ]]; then
      arch-chroot /mnt git clone "$GIT_URL_PREFIX/st.git" /home/$username/st
      arch-chroot /mnt bash -c "cd /home/$username/st && ./install.sh"
    fi

    echo "Do you want to install Neovim configuration and dotfiles? (y/n)"
    read install_neovim
    if [[ $install_neovim == "y" ]]; then
      arch-chroot /mnt git clone "$GIT_URL_PREFIX/neovim-config.git" /home/$username/.config/nvim
      arch-chroot /mnt git clone "$GIT_URL_PREFIX/dotfiles.git" /home/$username/dotfiles
      arch-chroot /mnt bash -c "cd /home/$username/dotfiles && ./install.sh"
    fi
  fi
}

# Main installation steps
main() {
  echo "Starting barebones Arch Linux installation."

  # Step 1: Check for internet connection
  check_internet

  # Step 2: Select disk to install on
  select_disk

  # Step 3: Partition and format the disk
  partition_and_format_disk

  # Step 4: Mount the partitions
  mount_partitions

  # Step 5: Install the base system
  install_base_system

  # Step 6: Generate fstab
  generate_fstab

  # Step 7: Set up systemd-boot
  setup_systemd_boot

  # Step 8: Final setup (timezone, language, etc.)
  final_setup

  # Step 9: Set the root password
  set_root_password

  # Step 10: Create a user
  create_user

  # Step 11: Install custom software
  install_custom_software

  echo "Installation complete! You can now chroot into /mnt and set up additional configurations."
  echo "To chroot: arch-chroot /mnt"
}

main

