#!/bin/bash

# Remove the tern.sh file if it exists
rm -rf tern.sh

echo "Welcome to the t3rn Executor Setup!"

# Function to stop and remove the old service
remove_old_service() {
    echo "Stopping and removing the old service if it exists..."
    sudo systemctl stop executor.service
    sudo systemctl disable executor.service
    sudo rm -f /etc/systemd/system/executor.service
    sudo systemctl daemon-reload
    echo "Old service has been removed."
}

# Function to update and upgrade the system
update_system() {
    echo "Updating and upgrading the system..."
    sudo apt update -q && sudo apt upgrade -qy
}

# Function to download and extract the binary
download_and_extract_binary() {
    LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4)
    EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/${LATEST_VERSION}/executor-linux-${LATEST_VERSION}.tar.gz"
    EXECUTOR_FILE="executor-linux-${LATEST_VERSION}.tar.gz"

    echo "Latest version detected: $LATEST_VERSION"
    echo "Downloading Executor binary from $EXECUTOR_URL..."
    curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

    if [ $? -ne 0 ]; then
        echo "Failed to download Executor binary. Please check your internet connection and try again."
        exit 1
    fi

    echo "Extracting binary..."
    tar -xzvf $EXECUTOR_FILE
    rm -rf $EXECUTOR_FILE
    cd executor/executor/bin

    echo "Binary successfully downloaded and extracted."
}

# Function to set environment variables
set_environment_variables() {
    export NODE_ENV=testnet
    export LOG_LEVEL=debug
    export LOG_PRETTY=false
    echo "Environment variables set: NODE_ENV=$NODE_ENV, LOG_LEVEL=$LOG_LEVEL, LOG_PRETTY=$LOG_PRETTY"
}

# Function to set the private key
set_private_key() {
    read -p "Enter your Metamask Private Key (with or without 0x prefix): " PRIVATE_KEY_LOCAL
    # Ensure the private key always starts with 0x
    PRIVATE_KEY_LOCAL=$(echo $PRIVATE_KEY_LOCAL | sed 's/^0x//;s/^/0x/')
    export PRIVATE_KEY_LOCAL
    echo "Private key has been set."
}

# Function to set enabled networks
set_enabled_networks() {
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
    echo "Enabled networks: $ENABLED_NETWORKS"
}

# Function to create systemd service
create_systemd_service() {
    SERVICE_FILE="/etc/systemd/system/executor.service"
    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Executor Service
After=network.target

[Service]
User=root
WorkingDirectory=/root/executor/executor
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=$ENABLED_NETWORKS"
ExecStart=/root/executor/executor/bin/executor
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL
}

# Function to start the service
start_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable executor.service
    sudo systemctl start executor.service
    echo "Setup complete! Executor service has been created and started."
    echo "You can check the service status using: sudo systemctl status executor.service"
}

# Function to display logs
display_log() {
    echo "Displaying logs from the executor service:"
    sudo journalctl -u executor.service -f
}

# Running all functions
remove_old_service
update_system
download_and_extract_binary
set_environment_variables
set_private_key
set_enabled_networks
create_systemd_service
start_service
display_log
