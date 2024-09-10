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

# Remove old executor files
echo "Stopping and removing old executor files..."
sudo systemctl stop executor
sudo systemctl disable executor
sudo rm -rf /etc/systemd/system/executor.service
sudo rm -rf /usr/local/bin/executor
sudo rm -rf $(pwd)/executor
if [ $? -ne 0 ]; then
  echo "Error removing old executor files. Exiting..."
  exit 1
fi

# Get the latest version of the executor
echo "Fetching the latest executor version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | jq -r .tag_name)
if [ -z "$LATEST_VERSION" ]; then
  echo "Error fetching the latest version. Exiting..."
  exit 1
fi

# Download the executor binary
echo "Downloading executor version $LATEST_VERSION..."
wget https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/executor-linux-$LATEST_VERSION.tar.gz
if [ $? -ne 0 ]; then
  echo "Error downloading executor. Exiting..."
  exit 1
fi

# Extract the binary
echo "Extracting executor..."
tar -xvf executor-linux-$LATEST_VERSION.tar.gz
if [ $? -ne 0 ]; then
  echo "Error extracting executor. Exiting..."
  exit 1
fi

# Move the binary to a standard location
sudo mv executor-linux-$LATEST_VERSION /usr/local/bin/executor

# Display the version of the executor
echo "Executor version installed:"
/usr/local/bin/executor/bin/executor --version

# Create a systemd service file
echo "Creating executor service file..."
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=Executor Service
After=network.target

[Service]
User=root
WorkingDirectory=/usr/local/bin/executor
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn"
ExecStart=/usr/local/bin/executor/bin/executor
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
