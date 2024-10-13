#!/bin/bash

# Function to install dependencies and setup service
install_nexus() {
    echo "Updating packages..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing necessary packages..."
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source $HOME/.cargo/env
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        echo "Rust is already installed."
    fi

    if [ ! -f "$HOME/.nexus/network-api/clients/cli/target/release/prover" ]; then
        echo "Installing Nexus Prover..."
        curl https://cli.nexus.xyz/install.sh | sh -s -- -y
    else
        echo "Nexus Prover is already installed."
    fi

    SERVICE_FILE="/etc/systemd/system/nexus.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "Creating systemd service file for nexus..."
        sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Nexus Network
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.nexus/network-api/clients/cli
ExecStart=$(which cargo) run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    else
        echo "Systemd service file for nexus already exists."
    fi

    echo "Reloading systemd daemon and starting nexus service..."
    sudo systemctl daemon-reload
    sudo systemctl start nexus
    sudo systemctl enable nexus
}

# Function to fix unused import warning
fix_unused_import() {
    echo "Fixing unused import warning..."
    sed -i 's/^use std::env;/\/\/ use std::env;/' $HOME/.nexus/network-api/clients/cli/src/prover.rs
}

# Function to remove service and clean up
cleanup() {
    echo "Stopping and disabling nexus service..."
    sudo systemctl stop nexus
    sudo systemctl disable nexus
    echo "Removing service file..."
    sudo rm -f /etc/systemd/system/nexus.service
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
    echo "Removing Nexus installation..."
    rm -rf $HOME/.nexus
}

# Main script execution
echo "Cleaning up old installation..."
cleanup

echo "Installing Nexus..."
install_nexus

fix_unused_import

echo "Installation complete. Checking service status..."
sudo systemctl status nexus

echo "Following the logs for nexus service..."
sudo journalctl -fu nexus -o cat
