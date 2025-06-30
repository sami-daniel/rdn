#!/bin/bash

exec 1> >(logger -s -t "$(basename "$0")") 2>&1

CONF="/etc/NetworkManager/NetworkManager.conf"
SSID=$1
PWD=$2
PREFIX=$(pwd)

sudo apt install --no-install-recommends network-manager

if [ -z "$SSID" ] || [ -z "$PWD" ]; then
    echo "Use: command <SSID> <PASSWORD>" 1>&2
    exit 1
fi

cp "$CONF" "${CONF}.bak"

if grep -q "^\[ifupdown\]" "$CONF"; then
    if grep -q "^managed=" "$CONF"; then
        sed -i '/^\[ifupdown\]/,/^\[/ s/^managed=.*/managed=true/' "$CONF"
    else
        sed -i '/^\[ifupdown\]/a managed=true' "$CONF"
    fi
else
    echo -e "\n[ifupdown]\nmanaged=true" >> "$CONF"
fi

nmcli device wifi connect "$SSID" password "$PWD"
nmcli connection modify "$SSID" connection.autoconnect yes

chmod +x "$PREFIX/ensure_conn"
sudo mv "$PREFIX/ensure_conn" "/usr/bin/"

sudo mv "$PREFIX/ensure_conn.service" "/etc/systemd/system/"
sudo systemctl daemon-reload
sudo systemctl enable ensure_conn.service
sudo systemctl start ensure_conn.service
