#!/bin/bash

PKGS=('ca-certificates' xwayland chromium cage 'wlr-randr' grep 'openssh-client' 'openssh-server' uhubctl)
SERVICE_FOLDER=~/.config/systemd/user/

echo "Setting up system..."

echo "Checking connection. Pinging four times against google.com..."
ping google.com -c 4 > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Connect to internet before running setup.sh. Use sudo raspi-config command."
    exit 1
fi

echo "Updating packages..."
(
set -e
sudo apt-get update
sudo apt-get full-upgrade -y
) > /dev/null

echo "Installing required packages for system..."
(
set -e
sudo apt-get remove openssh-client openssh-server
sudo apt-get install -y "${PKGS[@]}"
) > /dev/null

echo "Updating system firmware..."
sudo rpi-update

echo "Configuring permissions for script nescessary scripts..."
chmod +x ./start_cage
chmod +x ./start_chromium

echo "Moving scripts to /usr/bin..."
sudo mv ./start_chromium /usr/bin/
sudo mv ./start_cage /usr/bin/

echo "Creating service folder for user..."
mkdir -p $SERVICE_FOLDER

echo "Moving service file to systemd correctly folder..."
sudo mv ./chromium_signage.service $SERVICE_FOLDER

echo "Enabling and starting service for user..."

(
set -e
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable chromium_signage.service
systemctl --user start chromium_signage.service
) > /dev/null
