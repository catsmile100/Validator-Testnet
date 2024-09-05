#!/bin/bash

# Update and install dependencies
echo "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
sleep 2

# Install Go
echo "Installing Go..."
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
sleep 2

# Download binaries
echo "Downloading binaries..."
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
sleep 2

# Initialize the story client
echo "Initializing the story client..."
story init --moniker test --network iliad
sleep 2

# Create geth service file
echo "Creating geth service file..."
sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=root
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 127.0.0.1 --http.port 8545 --ws --ws.api eth,web3,net,txpool --ws.addr 127.0.0.1 --ws.port 8546
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sleep 2

# Create story service file
echo "Creating story service file..."
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=root
WorkingDirectory=$HOME/.story/story
ExecStart=$(which story) run

Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sleep 2

# Enable and start geth
echo "Enabling and starting geth service..."
sudo systemctl daemon-reload
sudo systemctl enable geth
sudo systemctl restart geth
sleep 2

# Enable and start story
echo "Enabling and starting story service..."
sudo systemctl daemon-reload
sudo systemctl enable story
sudo systemctl restart story
sleep 2

# Download and update snapshoot
echo "Downloading and running update script..."
wget https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Story/updatestory.sh
chmod +x updatestory.sh && dos2unix updatestory.sh && ./updatestory.sh
sleep 2

echo "Installation and setup complete."
