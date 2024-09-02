#!/bin/bash

# Banner ASCII
echo " ██████╗ █████╗ ████████╗███████╗███╗   ███╗██╗██╗     ███████╗"
echo "██╔════╝██╔══██╗╚══██╔══╝██╔════╝████╗ ████║██║██║     ██╔════╝"
echo "██║     ███████║   ██║   ███████╗██╔████╔██║██║██║     █████╗  "
echo "██║     ██╔══██║   ██║   ╚════██║██║╚██╔╝██║██║██║     ██╔══╝  "
echo "╚██████╗██║  ██║   ██║   ███████║██║ ╚═╝ ██║██║███████╗███████╗"
echo " ╚═════╝╚═╝  ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo "                                                               "

# Stop and disable existing services, remove old files
{
    sudo systemctl stop story geth
    sudo systemctl disable story geth
    sudo rm /etc/systemd/system/story.service /etc/systemd/system/geth.service
    rm -rf $HOME/.story $HOME/bin $HOME/go/bin/story $HOME/go/bin/geth
    sudo systemctl daemon-reload
} &>/dev/null

# Input moniker
read -p "Enter your moniker: " MONIKER

# Function to check if a port is available
check_port() {
    local port=$1
    if sudo lsof -i -P -n | grep -q ":$port"; then
        return 1
    else
        return 0
    fi
}

# Default ports
DEFAULT_PORTS=(26656 26657 26658 1317 8545 8546)

# Check if default ports are available
echo -e "\n\e[42mChecking default ports...\e[0m\n"
all_ports_available=true
for port in "${DEFAULT_PORTS[@]}"; do
    if ! check_port $port; then
        all_ports_available=false
        break
    fi
done

# If default ports are not available, prompt for new port prefix
if [ "$all_ports_available" = false ]; then
    echo "Default ports are not available. Please enter a new port prefix."
    read -p "Enter new port prefix (2 digits, e.g., 14): " NEW_PREFIX

    # Validate input
    while [[ ! $NEW_PREFIX =~ ^[0-9]{2}$ ]]; do
        echo "Invalid input. Please enter 2 digits."
        read -p "Enter port prefix (2 digits, e.g., 14): " NEW_PREFIX
    done
else
    NEW_PREFIX=""
fi

# Update and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make gcc unzip ufw -y

# Install lz4 using snap if not already installed
if ! command -v lz4 &> /dev/null; then
    sudo snap install lz4
fi

# Install dos2unix if not already installed
if ! command -v dos2unix &> /dev/null; then
    sudo apt install dos2unix -y
fi

# Install Go
cd $HOME
GO_VER="1.20.3"
wget "https://golang.org/dl/go$GO_VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$GO_VER.linux-amd64.tar.gz"
rm "go$GO_VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
[ ! -d $HOME/go/bin ] && mkdir -p $HOME/go/bin

# Download and install binaries
cd $HOME
rm -rf bin
mkdir -p bin
cd bin
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xvf story-linux-amd64-0.9.11-2a25df1.tar.gz
mv geth-linux-amd64-0.9.2-ea9f0d2/geth $HOME/go/bin/
mv story-linux-amd64-0.9.11-2a25df1/story $HOME/go/bin/

# Initialize Story
story init --moniker "$MONIKER" --network iliad

# Configure peers
PEERS="2f372238bf86835e8ad68c0db12351833c40e8ad@story-testnet-peer.itrocket.net:26656,fe5b39d2bd701ed12a953894cc1449d4c5c6d699@135.125.189.91:26656,ae2d5116b30e5d0c61894b2f643005f71a4aa313@75.119.129.76:26656,a320f8a15892bddd7b5502527e0d11c5b5b9d0e3@69.67.150.107:29931,a03f525b72ece596b6ea3609b49c676751fafc14@94.141.103.163:26656,00c495396dfee53a31476d7619d1cc252b9a47b9@89.58.62.213:26656,ee5ecaf1364cb3238113ba9a29813c17fab97694@157.173.197.110:26656,5a0191a6bd8f17c9d2fa52386ff409f5d796d112@3.209.222.188:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.story/story/config/config.toml

# Download addrbook and genesis
echo -e "\n\e[42mDownloading addrbook...\e[0m\n"
wget -O $HOME/.story/story/config/addrbook.json https://server-5.itrocket.net/testnet/story/addrbook.json

echo -e "\n\e[42mDownloading genesis...\e[0m\n"
wget -O $HOME/.story/story/config/genesis.json https://server-5.itrocket.net/testnet/story/genesis.json

# Stop Story service
sudo systemctl stop story 2>/dev/null

# Backup and remove old data
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup
rm -rf $HOME/.story/story/data

# Download and extract new snapshot
echo -e "\n\e[42mDownloading and extracting new snapshot...\e[0m\n"
curl -o - -L https://story.snapshot.stavr.tech/story-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.story/story/ --strip-components 3

# Restore priv_validator_state.json
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Create JWT secret file
mkdir -p $HOME/.story/geth/iliad/geth
echo "your_jwt_secret" > $HOME/.story/geth/iliad/geth/jwtsecret
chmod 600 $HOME/.story/geth/iliad/geth/jwtsecret

# Create Geth service
sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Geth Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/geth --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 127.0.0.1 --http.port ${NEW_PREFIX}45 --ws --ws.api eth,web3,net,txpool --ws.addr 127.0.0.1 --ws.port ${NEW_PREFIX}46
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Create Story service
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/.story/story
ExecStart=$HOME/go/bin/story run
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Change ports if necessary
if [ -n "$NEW_PREFIX" ]; then
    DAEMON_HOME="$HOME/.story/story"

    # Function to change port
    change_port() {
        local old_port=$1
        local new_port="${NEW_PREFIX}${old_port:2}"
        sed -i -e "s|:$old_port|:$new_port|g" $DAEMON_HOME/config/config.toml
        sed -i -e "s|:$old_port|:$new_port|g" $DAEMON_HOME/config/story.toml
        echo "Port $old_port changed to $new_port"
    }

    echo -e '\n\e[42mChanging ports automatically...\e[0m\n'

    # Change Story ports
    change_port 26656
    change_port 26657
    change_port 26658
    change_port 1317

    # Change Geth ports
    GETH_HTTP_PORT="${NEW_PREFIX}45"
    GETH_WS_PORT="${NEW_PREFIX}46"
    sed -i "s|--http.port 8545|--http.port $GETH_HTTP_PORT|g" /etc/systemd/system/geth.service
    sed -i "s|--ws.port 8546|--ws.port $GETH_WS_PORT|g" /etc/systemd/system/geth.service
    echo "Geth HTTP port changed to $GETH_HTTP_PORT"
    echo "Geth WebSocket port changed to $GETH_WS_PORT"

    echo -e "\n\e[42mAll ports have been changed with prefix $NEW_PREFIX.\e[0m\n"

    # Allow new ports through firewall
    sudo ufw allow ${NEW_PREFIX}45/tcp
    sudo ufw allow ${NEW_PREFIX}46/tcp
    sudo ufw allow ${NEW_PREFIX}656/tcp
    sudo ufw allow ${NEW_PREFIX}657/tcp
    sudo ufw allow ${NEW_PREFIX}658/tcp
    sudo ufw allow ${NEW_PREFIX}17/tcp
else
    # Allow default ports through firewall
    sudo ufw allow 26656/tcp
    sudo ufw allow 26657/tcp
    sudo ufw allow 26658/tcp
    sudo ufw allow 1317/tcp
    sudo ufw allow 8545/tcp
    sudo ufw allow 8546/tcp
fi

# Allow SSH port through firewall
sudo ufw allow ssh

# Enable firewall
sudo ufw enable

# Start services
sudo systemctl daemon-reload
sudo systemctl enable geth
sudo systemctl start geth
sudo systemctl enable story
sudo systemctl start story

# Monitor Story service logs
sudo journalctl -fu story -o cat
