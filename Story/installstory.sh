#!/bin/bash

# Banner ASCII
echo " ██████╗ █████╗ ████████╗███████╗███╗   ███╗██╗██╗     ███████╗"
echo "██╔════╝██╔══██╗╚══██╔══╝██╔════╝████╗ ████║██║██║     ██╔════╝"
echo "██║     ███████║   ██║   ███████╗██╔████╔██║██║██║     █████╗  "
echo "██║     ██╔══██║   ██║   ╚════██║██║╚██╔╝██║██║██║     ██╔══╝  "
echo "╚██████╗██║  ██║   ██║   ███████║██║ ╚═╝ ██║██║███████╗███████╗"
echo " ╚═════╝╚═╝  ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝"
echo "                                                               "

# Stop and disable existing services, remove old files
echo -e "\n\e[42mStopping and disabling existing services, removing old files...\e[0m\n"
{
    sudo systemctl stop geth
    sudo systemctl disable geth
    sudo systemctl stop story
    sudo systemctl disable story
    sudo rm /etc/systemd/system/story.service /etc/systemd/system/geth.service
    rm -rf $HOME/.story $HOME/bin $HOME/go/bin/story $HOME/go/bin/geth
    sudo systemctl daemon-reload
} &>/dev/null
echo -e "\n\e[42mExisting services stopped and old files removed.\e[0m\n"

# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    if ss -tuln | grep ":$port " > /dev/null; then
        return 0  # Port is in use
    else
        return 1  # Port is not in use
    fi
}

# Function to find an available port prefix
find_available_prefix() {
    local default_ports=(8551 1717 26658 26657 6060 26656 26660)
    local start_prefix=1
    local port_prefix

    while true; do
        port_prefix=$(printf "%02d" $start_prefix)
        local is_available=1

        for port in "${default_ports[@]}"; do
            local new_port=$((port_prefix * 100 + port))
            if is_port_in_use $new_port; then
                is_available=0
                break
            fi
        done

        if [ $is_available -eq 1 ]; then
            echo $port_prefix
            return
        fi

        start_prefix=$((start_prefix + 1))
    done
}

# Prompt user for moniker
read -p "Enter the moniker: " MONIKER

# Find an available port prefix
PORT_PREFIX=$(find_available_prefix)
echo "Using port prefix: $PORT_PREFIX"

# Install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip ufw -y

# Install Go, if needed
echo "Installing Go..."
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"

if [ ! -f ~/.bash_profile ]; then
    touch ~/.bash_profile
fi

echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile

if [ ! -d ~/go/bin ]; then
    mkdir -p ~/go/bin
fi

# Download binaries
echo "Downloading and extracting binaries..."
cd $HOME
rm -rf bin
mkdir bin
cd bin
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xvf story-linux-amd64-0.9.11-2a25df1.tar.gz
mv ~/bin/geth-linux-amd64-0.9.2-ea9f0d2/geth ~/go/bin/
mv ~/bin/story-linux-amd64-0.9.11-2a25df1/story ~/go/bin/

mkdir -p ~/.story/story
mkdir -p ~/.story/geth

# Initialize the Story client
echo "Initializing Story client..."
story init --moniker "$MONIKER" --network iliad

# Create Geth service file
echo "Creating Geth service file..."
sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 127.0.0.1 --http.port 8545 --ws --ws.api eth,web3,net,txpool --ws.addr 127.0.0.1 --ws.port 8546
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Create Story service file
echo "Creating Story service file..."
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/.story/story
ExecStart=$(which story) run

Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Update ports in configuration files
echo "Updating configuration files with port prefix $PORT_PREFIX..."
sed -i.bak -e "s%engine-endpoint = \"http://localhost:8551\"%engine-endpoint = \"http://localhost:${PORT_PREFIX}51\"%g;
s%api-address = \"127.0.0.1:1717\"%api-address = \"127.0.0.1:${PORT_PREFIX}17\"%g" $HOME/.story/story/config/story.toml

sed -i.bak -e "s%:26658%:${PORT_PREFIX}658%g;
s%:26657%:${PORT_PREFIX}657%g;
s%:6060%:${PORT_PREFIX}660%g;
s%:26656%:${PORT_PREFIX}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${PORT_PREFIX}656\"%;
s%:26660%:${PORT_PREFIX}660%g" $HOME/.story/story/config/config.toml

echo "Configuration updated successfully."

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow $(($PORT_PREFIX * 100 + 30303))/tcp comment 'geth_p2p_port'
sudo ufw allow $(($PORT_PREFIX * 100 + 26656))/tcp comment 'story_p2p_port'
sudo ufw reload

# Add persistent peers to config.toml
echo "Updating persistent peers in config.toml..."
PEERS="2f372238bf86835e8ad68c0db12351833c40e8ad@story-testnet-peer.itrocket.net:26656,00c495396dfee53a31476d7619d1cc252b9a47b9@89.58.62.213:26656,800bd9a3bb37a07d5c57c42a5de72d7ab370cfd1@100.42.189.22:26656,8e33fb7dfa20e61bf743cdea89f8ca909946a189@65.108.232.134:26656,c82d2b5fe79e3159768a77f25eee4f22e3841f56@3.209.222.59:26656,a03f525b72ece596b6ea3609b49c676751fafc14@94.141.103.163:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.story/story/config/config.toml

# Update addrbook and genesis files
echo "Updating addrbook and genesis files..."
wget -O $HOME/.story/story/config/addrbook.json https://server-5.itrocket.net/testnet/story/addrbook.json
wget -O $HOME/.story/story/config/genesis.json https://server-5.itrocket.net/testnet/story/genesis.json

# Add peer to Geth
echo "Adding peer to Geth..."
geth --exec 'admin.addPeer("enode://499267340ce74fd95b56181b219fc1097b138156c961a38cce608cbd8e22dc02214644997a6fc84c49023e59a70d52ee10c3c40007bd1ccca06267d708fc4aeb@story-testnet-enode.itrocket.net:30301")' attach ~/.story/geth/iliad/geth.ipc

# Handle snapshot
echo "Handling snapshot..."
sudo systemctl stop story geth
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup
rm -rf $HOME/.story/story/data
rm -rf $HOME/.story/geth/iliad/geth/chaindata
curl https://server-5.itrocket.net/testnet/story/story_2024-09-02_211110_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json
sudo systemctl start story geth

# Enable and start services
echo "Enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable geth
sudo systemctl enable story
sudo systemctl restart geth
sudo systemctl restart story

echo "All services are started. Monitoring logs..."

