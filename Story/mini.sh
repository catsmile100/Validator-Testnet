#!/bin/bash

echo "Cleaning up old installation..."
sudo systemctl stop story story-geth 2>/dev/null
sudo systemctl disable story story-geth 2>/dev/null
sudo rm -f /etc/systemd/system/story.service
sudo rm -f /etc/systemd/system/story-geth.service
sudo systemctl daemon-reload
rm -rf $HOME/.story
rm -rf $HOME/story
rm -rf $HOME/go/bin/story
rm -rf $HOME/go/bin/geth

# Install dependencies
sudo apt update
sudo apt install curl wget jq lz4 -y

# Get latest release for Story Geth
GETH_LATEST=$(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | jq -r .tag_name)
wget -O geth "https://github.com/piplabs/story-geth/releases/download/$GETH_LATEST/geth-linux-amd64"
chmod +x geth
sudo mv geth /usr/local/bin/

# Get latest release for Story
cd $HOME
git clone https://github.com/piplabs/story
cd story
STORY_LATEST=$(git describe --tags $(git rev-list --tags --max-count=1))
git checkout $STORY_LATEST
go build -o story ./client
sudo mv story /usr/local/bin/

# Init Story (perubahan di sini)
story init --moniker test --network odyssey

# State Sync
SNAP_RPC="https://story-testnet-rpc.itrocket.net:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

# Configure
mkdir -p $HOME/.story/story/config

# Download genesis dan addrbook
wget -O $HOME/.story/story/config/genesis.json https://server-3.itrocket.net/testnet/story/genesis.json
wget -O $HOME/.story/story/config/addrbook.json https://server-3.itrocket.net/testnet/story/addrbook.json

# Configure state sync
cat > $HOME/.story/story/config/config.toml << EOF
# State sync configuration
[statesync]
enable = true
rpc_servers = "$SNAP_RPC,$SNAP_RPC"
trust_height = $BLOCK_HEIGHT
trust_hash = "$TRUST_HASH"
EOF

# Create services
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/story run
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
ExecStart=/usr/local/bin/geth --odyssey --syncmode full --http
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable story story-geth
sudo systemctl start story story-geth

echo "Installation completed!"
echo "Check logs with: sudo journalctl -u story -f"
