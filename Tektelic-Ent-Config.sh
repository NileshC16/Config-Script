#!/bin/bash

# Function to display a menu and get user input
select_interface_preference() {
    echo "Choose the gateway configuration:"
    echo "1. Ethernet Primary, failover Cellular"
    echo "2. Cellular Primary, failover Ethernet"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            INTERFACE="eth0,wwan0"
            ;;
        2)
            INTERFACE="wwan0,eth0"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Remove existing timezone configuration
echo "Removing existing timezone configuration..."
sudo rm -rf /etc/localtime

# Set timezone to Indian/Mauritius
echo "Setting timezone to Indian/Mauritius..."
sudo ln -s /usr/share/zoneinfo/Indian/Mauritius /etc/localtime

# Remove existing Kona packet forwarder
echo "Removing Kona packet forwarder..."
sudo opkg remove kona-pkt-forwarder

# Download and install Loriot software
INSTALL_SCRIPT_URL="https://ap4pro.loriot.io/home/gwsw/loriot-tektelic-kona-enterprise-SPI-0-latest.sh"
INSTALL_SCRIPT="/tmp/loriot-install.sh"

echo "Downloading Loriot installation script..."
if command -v wget &> /dev/null; then
    wget "$INSTALL_SCRIPT_URL" -O "$INSTALL_SCRIPT"
elif command -v curl &> /dev/null; then
    curl -o "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL"
else
    echo "Error: Neither wget nor curl is available. Please install one of them to proceed."
    exit 1
fi

echo "Making Loriot installation script executable..."
chmod +x "$INSTALL_SCRIPT"

echo "Running Loriot installation script..."
"$INSTALL_SCRIPT" -f -s ap4pro.loriot.io

# Select the gateway configuration
select_interface_preference

# Apply the selected configuration
echo "Applying the selected gateway configuration..."
./loriot-gw -f -i "$INTERFACE" -s ap1.loriot.io

echo "Configuration complete."