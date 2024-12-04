#!/bin/bash

echo "Cleaning up old installation..."

# Stop services if they exist
sudo systemctl stop story story-geth 2>/dev/null
sudo systemctl disable story story-geth 2>/dev/null

# Remove old services
sudo rm -f /etc/systemd/system/story.service
sudo rm -f /etc/systemd/system/story-geth.service
sudo systemctl daemon-reload

# Remove old directories and files
rm -rf $HOME/.story
rm -rf $HOME/story
rm -rf $HOME/go/bin/story
rm -rf $HOME/go/bin/geth

# Remove old Go installation
sudo rm -rf /usr/local/go

echo "Cleanup completed. Starting fresh installation..."

# Vars
MONIKER="test"
CHAIN_ID="odyssey-0"

# Install dependencies
sudo apt update
sudo apt install curl git wget htop tmux build-essential jq make gcc unzip -y

# Install Go v1.21.5
cd $HOME
VER="1.21.5"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source ~/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# Install Story
cd $HOME
wget -O geth https://github.com/piplabs/story-geth/releases/download/v0.10.1/geth-linux-amd64
chmod +x geth
sudo mv geth /usr/local/bin/

git clone https://github.com/piplabs/story
cd story
git checkout v0.13.0
go mod tidy
go install ./client    

# Verifikasi instalasi
which story
if [ $? -ne 0 ]; then
    echo "Story installation failed!"
    exit 1
fi

# Init
story init $MONIKER --chain-id $CHAIN_ID

# State Sync
SNAP_RPC="https://story-testnet-rpc.itrocket.net:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

# Create config directory if it doesn't exist
mkdir -p $HOME/.story/story/config

# Configure
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.story/story/config/config.toml

# Create services
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which story) run
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --odyssey --syncmode full --http
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable story story-geth
sudo systemctl start story story-geth

echo "Installation completed!"
echo "Check logs with: sudo journalctl -u story -f"
