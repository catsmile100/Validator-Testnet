#!/bin/bash

# Set port prefix
PORT_PREFIX="29"

# Update and install dependencies
echo "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

# Install Go
echo "Installing Go..."
cd $HOME
VER="1.22.0"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# Verify Go installation
go version

# Download binaries
echo "Downloading binaries..."
cd $HOME
rm -rf bin
mkdir bin
cd bin
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.0-9603826.tar.gz
tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xzvf story-linux-amd64-0.10.0-9603826.tar.gz
mv ~/bin/geth-linux-amd64-0.9.2-ea9f0d2/geth ~/go/bin/
mv ~/bin/story-linux-amd64-0.10.0-9603826/story ~/go/bin/

mkdir -p ~/.story/story
mkdir -p ~/.story/geth

# Initialize the story client
echo "Initializing the story client..."
story init --moniker test --network iliad

# Modify config.toml to use custom ports
echo "Modifying config.toml..."
sed -i.bak -e "s/^proxy_app = \"tcp:\/\/127.0.0.1:26658\"/proxy_app = \"tcp:\/\/127.0.0.1:${PORT_PREFIX}658\"/" \
    -e "s/^laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/127.0.0.1:${PORT_PREFIX}657\"/" \
    -e "s/^pprof_laddr = \"localhost:6060\"/pprof_laddr = \"localhost:${PORT_PREFIX}060\"/" \
    -e "s/^laddr = \"tcp:\/\/0.0.0.0:26656\"/laddr = \"tcp:\/\/0.0.0.0:${PORT_PREFIX}656\"/" \
    -e "s/^prometheus_listen_addr = \":26660\"/prometheus_listen_addr = \":${PORT_PREFIX}660\"/" \
    $HOME/.story/story/config/config.toml

# Create geth service file
echo "Creating geth service file..."
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 0.0.0.0 --http.port ${PORT_PREFIX}45 --ws --ws.api eth,web3,net,txpool --ws.addr 0.0.0.0 --ws.port ${PORT_PREFIX}46 --port ${PORT_PREFIX}30
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Create story service file
echo "Creating story service file..."
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

# Enable and start services
echo "Enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable story-geth
sudo systemctl start story-geth
sudo systemctl enable story
sudo systemctl start story

echo "Installation and setup complete."
echo "To check the status of the services, use:"
echo "sudo systemctl status story-geth"
echo "sudo systemctl status story"
echo "To view logs, use:"
echo "sudo journalctl -u story-geth -f"
echo "sudo journalctl -u story -f"

# Pause for 30 seconds
echo "Pausing for 30 seconds before stopping services..."
sleep 30

# Stop all services
echo "Stopping all services..."
sudo systemctl stop story-geth
sudo systemctl stop story

echo "All services have been stopped."
