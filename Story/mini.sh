#!/bin/bash

# Vars
MONIKER="test"
CHAIN_ID="odyssey-0"
PORT="52"

# Quick Install
sudo apt update && sudo apt install curl git wget jq lz4 -y

# Install Go & Binary
cd $HOME
wget "https://golang.org/dl/go1.22.3.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go1.22.3.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source ~/.bash_profile

# Install Story
wget -O geth https://github.com/piplabs/story-geth/releases/download/v0.10.1/geth-linux-amd64
chmod +x geth && mv geth ~/go/bin/

git clone https://github.com/piplabs/story
cd story && git checkout v0.13.0
go build -o story ./client && mv story ~/go/bin/

# Init
story init --moniker $MONIKER --network odyssey

# State Sync Config
SNAP_RPC="https://story-testnet-rpc.itrocket.net:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

# Backup & Configure
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup 2>/dev/null
rm -rf $HOME/.story/story/data
mkdir -p $HOME/.story/story/data
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json 2>/dev/null

# Update config.toml
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.story/story/config/config.toml

# Create Services
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=$USER
ExecStart=$(which story) run
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth
After=network.target

[Service]
User=$USER
ExecStart=$(which geth) --odyssey --syncmode full --http
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Start
sudo systemctl daemon-reload
sudo systemctl enable story story-geth
sudo systemctl restart story story-geth

echo "Checking logs... (Ctrl+C to exit)"
sudo journalctl -u story -f