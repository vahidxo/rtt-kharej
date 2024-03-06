#!/bin/bash

# Step 0: Check if RTT file exists in /root directory
if [ -f "/root/RTT" ]; then
    echo "RTT file found in /root directory. Skipping installation step."
else
    # Step 1: Download and run install.sh
    cd /root || exit 1
    wget "https://raw.githubusercontent.com/radkesvat/ReverseTlsTunnel/master/scripts/install.sh" -O install.sh && chmod +x install.sh && bash install.sh
fi

# Step 2: Prompt for service name and other variables
read -p "Enter service name (without .service extension): " NAME
read -p "Enter Iran ip: " IP_IR
read -p "Enter Iran port: " Port_IR
read -p "Enter kharej port: " Port_KH
read -p "Enter SNI: " SNI
read -p "Enter password: " PASS

# Step 3: Remove existing service file if it exists
SERVICE_FILE="/etc/systemd/system/${NAME}.service"
if [ -f "$SERVICE_FILE" ]; then
    echo "Deleting existing service file: $SERVICE_FILE"
    rm "$SERVICE_FILE"
    # Flag indicating that the service file was deleted
    SERVICE_DELETED=true
fi

# Step 4: Create new service file
cat <<EOF >"$SERVICE_FILE"
[Unit]
Description=Reverse TLS Tunnel

[Service]
Type=idle
User=root
WorkingDirectory=/root
ExecStart=/root/RTT --kharej --iran-ip:${IP_IR} --iran-port:${Port_IR} --toip:127.0.0.1 --toport:${Port_KH} --password:${PASS} --sni:${SNI} --terminate:24
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Reload systemd daemon
systemctl daemon-reload

# Step 6: Start or restart the service based on whether it was deleted before
if [ "$SERVICE_DELETED" = true ]; then
    # If the service was deleted, restart it
    systemctl restart "${NAME}.service"
else
    # Otherwise, start the service
    systemctl start "${NAME}.service"
fi

# Step 7: Check the service status
systemctl status "${NAME}.service"

# Step 8: Enable the service
systemctl enable "${NAME}.service"
