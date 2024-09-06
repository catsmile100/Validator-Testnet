#!/bin/bash

# Prompt for PRIVATE_KEY_LOCAL input
read -p "Enter your PRIVATE_KEY_LOCAL: " PRIVATE_KEY_LOCAL

# Update and install dependencies
echo "Updating package list and upgrading installed packages..."
sudo apt update && sudo apt upgrade -y
if [ $? -ne 0 ]; then
  echo "Error updating and upgrading packages. Exiting..."
  exit 1
fi

echo "Installing required packages..."
sudo apt install curl wget tar build-essential jq unzip -y
if [ $? -ne 0 ]; then
  echo "Error installing packages. Exiting..."
  exit 1
fi

# Download the executor binary
echo "Downloading executor..."
wget https://github.com/t3rn/executor-release/releases/download/v0.20.0/executor-linux-v0.20.0.tar.gz
if [ $? -ne 0 ]; then
  echo "Error downloading executor. Exiting..."
  exit 1
fi

# Extract the binary
echo "Extracting executor..."
tar -xvf executor-linux-v0.20.0.tar.gz
if [ $? -ne 0 ]; then
  echo "Error extracting executor. Exiting..."
  exit 1
fi

# Create a systemd service file
echo "Creating executor service file..."
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=Executor Service
After=network.target

[Service]
User=root
WorkingDirectory=$(pwd)/executor/executor
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn"
ExecStart=$(pwd)/executor/executor/bin/executor
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
echo "Reloading systemd daemon and enabling executor service..."
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
  echo "Error reloading systemd daemon. Exiting..."
  exit 1
fi

sudo systemctl enable executor
if [ $? -ne 0 ]; then
  echo "Error enabling executor service. Exiting..."
  exit 1
fi

sudo systemctl start executor
if [ $? -ne 0 ]; then
  echo "Error starting executor service. Exiting..."
  exit 1
fi

echo "Executor started. Displaying logs..."
journalctl -u executor -f
