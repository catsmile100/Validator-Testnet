#!/bin/bash

# Port configuration at the beginning
echo "Enter port prefix (default: 26, press Enter to use default):"
read PORT_PREFIX
PORT_PREFIX=${PORT_PREFIX:-26}

# Calculate ports
RPC_PORT="${PORT_PREFIX}657"
API_PORT="${PORT_PREFIX}317"
GRPC_PORT="${PORT_PREFIX}090"
GRPC_WEB_PORT="${PORT_PREFIX}091"
JSON_RPC_PORT="${PORT_PREFIX}545"
WS_PORT="${PORT_PREFIX}546"

echo "Using the following ports:"
echo "RPC Port: $RPC_PORT"
echo "API Port: $API_PORT"
echo "gRPC Port: $GRPC_PORT"
echo "gRPC-Web Port: $GRPC_WEB_PORT"
echo "JSON-RPC Port: $JSON_RPC_PORT"
echo "WebSocket Port: $WS_PORT"

echo "Continue with these ports? (y/n)"
read CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Installation cancelled"
    exit 1
fi

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

# Check dependencies
is_installed() {
    dpkg -l "$1" &> /dev/null
}

# Install dependencies if not already installed
sudo apt update
for pkg in curl wget jq lz4; do
    if ! is_installed $pkg; then
        echo "Installing $pkg..."
        sudo apt install -y $pkg
    else
        echo "$pkg is already installed."
    fi
done

# Get latest Story Geth
echo "Installing Story Geth..."
GETH_LATEST=$(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | jq -r .tag_name)
wget -O geth "https://github.com/piplabs/story-geth/releases/download/$GETH_LATEST/geth-linux-amd64"
chmod +x geth
sudo mv geth /usr/local/bin/

# Get specific version of Story
echo "Installing Story v0.13.0..."
cd $HOME
git clone https://github.com/piplabs/story
cd story
git checkout v0.13.0
go build -o story ./client
sudo mv story /usr/local/bin/

# Init Story
echo "Initializing Story..."
story init --moniker test --network odyssey

# State Sync Configuration
SNAP_RPC="https://story-testnet-rpc.itrocket.net:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

# Configure directories and files
mkdir -p $HOME/.story/story/config

# Download genesis and addrbook
wget -O $HOME/.story/story/config/genesis.json https://server-3.itrocket.net/testnet/story/genesis.json
wget -O $HOME/.story/story/config/addrbook.json https://server-3.itrocket.net/testnet/story/addrbook.json

# Set peers and seeds
PEERS="c2a6cc9b3fa468624b2683b54790eb339db45cbf@story-testnet-peer.itrocket.net:26656,fe36782944fdcb79b787a9bbc539ad901552dcd3@184.174.33.116:26656"
SEEDS="434af9dae402ab9f1c8a8fc15eae2d68b5be3387@story-testnet-seed.itrocket.net:29656"

# Create config.toml with dynamic ports
cat > $HOME/.story/story/config/config.toml << EOF
# State sync configuration
[statesync]
enable = true
rpc_servers = "$SNAP_RPC,$SNAP_RPC"
trust_height = $BLOCK_HEIGHT
trust_hash = "$TRUST_HASH"
trust_period = "168h"

[p2p]
persistent_peers = "$PEERS"
seeds = "$SEEDS"
max_num_inbound_peers = 100
max_num_outbound_peers = 50
persistent_peers_max_dial_period = "0s"
allow_duplicate_ip = true

[rpc]
laddr = "tcp://0.0.0.0:${RPC_PORT}"

[api]
enable = true
address = "tcp://0.0.0.0:${API_PORT}"
EOF

# Create app.toml with dynamic ports
cat > $HOME/.story/story/config/app.toml << EOF
[api]
enable = true
address = "tcp://0.0.0.0:${API_PORT}"
enabled-unsafe-cors = true

[grpc]
enable = true
address = "0.0.0.0:${GRPC_PORT}"

[grpc-web]
enable = true
address = "0.0.0.0:${GRPC_WEB_PORT}"

[json-rpc]
enable = true
address = "0.0.0.0:${JSON_RPC_PORT}"
EOF

# Create Story service
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

# Create Story Geth service with dynamic ports
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/geth \
    --odyssey \
    --syncmode full \
    --http \
    --http.addr 0.0.0.0 \
    --http.port ${JSON_RPC_PORT} \
    --http.api eth,net,web3,txpool \
    --http.corsdomain "*" \
    --ws \
    --ws.addr 0.0.0.0 \
    --ws.port ${WS_PORT}
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

echo "Installation completed with the following ports:"
echo "RPC Port: $RPC_PORT"
echo "API Port: $API_PORT"
echo "gRPC Port: $GRPC_PORT"
echo "gRPC-Web Port: $GRPC_WEB_PORT"
echo "JSON-RPC Port: $JSON_RPC_PORT"
echo "WebSocket Port: $WS_PORT"
echo "Check Story logs: sudo journalctl -u story -f"
echo "Check Geth logs: sudo journalctl -u story-geth -f"

# Check sync status
echo "Waiting for sync to start..."
sleep 10

check_sync() {
    echo "Moniker: $(curl -s localhost:$RPC_PORT/status | jq -r .result.node_info.moniker) | Story: v0.13.0-stable | Geth: v0.10.1 | $(echo "Sync: $(curl -s localhost:$RPC_PORT/status | jq -r .result.sync_info.catching_up) | Local: $(curl -s localhost:$RPC_PORT/status | jq -r .result.sync_info.latest_block_height) | Remote: $(curl -s https://story-testnet-rpc.itrocket.net/status | jq -r .result.sync_info.latest_block_height) | Behind: $(($(curl -s https://odyssey.storyrpc.io/status | jq -r .result.sync_info.latest_block_height) - $(curl -s localhost:$RPC_PORT/status | jq -r .result.sync_info.latest_block_height)))")"
}

# Check sync status every 30 seconds for 2 minutes
for i in {1..4}; do
    check_sync
    sleep 30
done
