#!/bin/bash
exec 1> >(logger -s -t "$(basename "$0")") 2>&1

set -euo pipefail
trap 'echo "Error at line $LINENO"; exit 1' ERR

PKGS=('ca-certificates' xwayland chromium cage 'wlr-randr' grep uhubctl)
SERVICE_FOLDER=~/.config/systemd/user/
prefix=$(pwd)

echo "Setting up system..."

echo "Checking connection. Pinging four times against google.com..."
ping google.com -c 4 > /dev/null 2>&1 
|| { echo "Connect to internet before running setup.sh. Use sudo raspi-config command."; exit 1; }

echo "Updating packages..."
(
set -e
sudo apt-get update
sudo apt-get full-upgrade -y
) || { echo "Failed on update packages. Exiting..."; exit 1; }

echo "Installing required packages for system..."
(
set -e
sudo apt-get install --reinstall openssh-client openssh-server &&
sudo apt-get install -y "${PKGS[@]}"
) || { echo "Failed on installation of nescessary packages. Exiting..."; exit 1; }

echo "Configuring permissions for script nescessary scripts..."
chmod +x "$prefix/start_cage"
chmod +x "$prefix/start_chromium"

echo "Moving scripts to /usr/bin..."
sudo mv "$prefix/start_chromium" /usr/bin/
sudo mv "$prefix/start_cage" /usr/bin/

echo "Creating service folder for user..."
mkdir -p $SERVICE_FOLDER

echo "Moving service file to systemd correctly folder..."
sudo mv "$prefix/chromium_signage.service" $SERVICE_FOLDER

echo "Enabling and starting service for user..."

(
set -e
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable chromium_signage.service
systemctl --user start chromium_signage.service
) || { echo "Failed on initialization of chromium_signage service. Exiting..."; exit 1; }
