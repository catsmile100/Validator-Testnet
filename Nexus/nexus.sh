#!/bin/bash

# Function to install dependencies and setup service
install_nexus() {
    echo "Updating packages..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing necessary packages..."
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source $HOME/.cargo/env
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    echo "Installing Nexus Prover..."
    curl https://cli.nexus.xyz/install.sh | sh -s -- -y
    
    echo "Menyesuaikan kepemilikan file..."
    sudo chown -R $USER:$USER $HOME/.nexus

    SERVICE_FILE="/etc/systemd/system/nexus.service"
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

    echo "Reloading systemd daemon and starting nexus service..."
    sudo systemctl daemon-reload
    sudo systemctl enable nexus
    sudo systemctl start nexus
}

# Function to fix unused import warning
fix_unused_import() {
    PROVER_FILE="$HOME/.nexus/network-api/clients/cli/src/prover.rs"
    if [ -f "$PROVER_FILE" ]; then
        echo "Memberikan izin penuh dan memperbaiki $PROVER_FILE..."
        sudo chmod 777 "$PROVER_FILE"
        sudo sed -i '/use std::env;/d' "$PROVER_FILE"
        
        echo "Mengompilasi ulang proyek..."
        cd "$HOME/.nexus/network-api/clients/cli"
        cargo clean && cargo build --release
    else
        echo "File $PROVER_FILE tidak ditemukan."
    fi
}

# Function to remove service and clean up
cleanup() {
    sudo systemctl stop nexus
    sudo systemctl disable nexus
    sudo rm -f /etc/systemd/system/nexus.service
    sudo systemctl daemon-reload
    rm -rf $HOME/.nexus
}

# Main script execution
echo "Cleaning up old installation..."
cleanup

echo "Installing Nexus..."
install_nexus

echo "Memperbaiki peringatan impor yang tidak digunakan dan mengompilasi ulang..."
fix_unused_import

echo "Installation complete. Checking service status..."
sudo systemctl status nexus

echo "Following the logs for nexus service..."
sudo journalctl -fu nexus -o cat
