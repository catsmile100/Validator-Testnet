#!/bin/bash

# Stop and remove old executor service
echo "Stopping and removing old executor service..."
sudo systemctl stop executor
sudo systemctl disable executor
sudo rm -f /etc/systemd/system/executor.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Update and install dependencies
cd $HOME
rm -rf executor; rm -f t3rn.sh
sudo apt -q update
sudo apt -qy upgrade

# Get the latest version of the executor
echo "Fetching the latest executor version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | jq -r .tag_name)
if [ -z "$LATEST_VERSION" ]; then
  echo "Error fetching the latest version. Exiting..."
  exit 1
fi

EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/executor-linux-$LATEST_VERSION.tar.gz"
EXECUTOR_FILE="executor-linux-$LATEST_VERSION.tar.gz"

echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

if [ $? -ne 0 ]; then
    echo "Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE
rm -rf $EXECUTOR_FILE
sudo mv executor-linux-$LATEST_VERSION /usr/local/bin/executor

echo "Binary downloaded and extracted successfully."
echo

read -p "Enter your preferred Node Environment (e.g., testnet, mainnet): " NODE_ENV
export NODE_ENV=${NODE_ENV:-testnet}
echo "Node Environment set to: $NODE_ENV"
echo

export LOG_LEVEL=debug
export LOG_PRETTY=false
echo "Log settings configured: LOG_LEVEL=$LOG_LEVEL, LOG_PRETTY=$LOG_PRETTY"
echo

read -s -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
echo -e "\nPrivate key has been set."
echo

read -p "Enter the networks to operate on (comma-separated, e.g., arbitrum-sepolia,base-sepolia): " ENABLED_NETWORKS
export ENABLED_NETWORKS=${ENABLED_NETWORKS:-arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn}
echo "Enabled Networks set to: $ENABLED_NETWORKS"
echo

read -p "Would you like to set custom RPC URLs? (y/n): " SET_RPC
if [ "$SET_RPC" == "y" ]; then
  for NETWORK in $(echo $ENABLED_NETWORKS | tr "," "\n"); do
    read -p "Enter the RPC URLs for $NETWORK (comma-separated): " RPC_URLS
    export EXECUTOR_${NETWORK^^}_RPC_URLS=$RPC_URLS
    echo "RPC URLs set for $NETWORK"
  done
else
  echo "Skipping custom RPC URL setup. Default URLs will be used."
fi
echo

# Create a systemd service file
echo "Creating executor service file..."
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=Executor Service
After=network.target

[Service]
User=root
WorkingDirectory=/usr/local/bin/executor
Environment="NODE_ENV=$NODE_ENV"
Environment="LOG_LEVEL=$LOG_LEVEL"
Environment="LOG_PRETTY=$LOG_PRETTY"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=$ENABLED_NETWORKS"
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

echo "Executor service started. Displaying logs..."
journalctl -u executor -f
