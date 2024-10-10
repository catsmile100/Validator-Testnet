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
        curl https://cli.nexus.xyz/install.sh | sh
    else
        echo "Nexus Prover is already installed."
    fi

    SERVICE_FILE="/etc/systemd/system/nexusd.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "Creating systemd service file for nexusd..."
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
        echo "Systemd service file for nexusd already exists."
    fi

    echo "Reloading systemd daemon and starting nexusd service..."
    sudo systemctl daemon-reload
    sudo systemctl start nexusd
    sudo systemctl enable nexusd
}

# Function to fix unused import warning
fix_unused_import() {
    echo "Fixing unused import warning..."
    sed -i 's/^use std::env;/\/\/ use std::env;/' /root/.nexus/network-api/clients/cli/src/prover.rs
}

# Function to remove service and clean up
cleanup() {
    echo "Stopping and disabling nexusd service..."
    sudo systemctl stop nexusd
    sudo systemctl disable nexusd
    echo "Removing service file..."
    sudo rm -f /etc/systemd/system/nexusd.service
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
}

# Main script execution
fix_unused_import

# Try to run the prover and check for errors
if ! cargo run --release --bin prover -- beta.orchestrator.nexus.xyz; then
    echo "Error detected, cleaning up and reinstalling..."
    cleanup
    install_nexus
else
    echo "Prover ran successfully."
fi

# Follow the logs
echo "Following the logs for nexusd service..."
sudo journalctl -fu nexusd -o cat
