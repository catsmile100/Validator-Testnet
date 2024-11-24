#!/bin/bash

# Update and install dependencies
echo "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip pv -y

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

# Install Story-Geth binary v0.10.1
cd $HOME
wget https://github.com/piplabs/story-geth/releases/download/v0.10.1/geth-linux-amd64
chmod +x geth-linux-amd64
mv $HOME/geth-linux-amd64 $HOME/go/bin/story-geth

# Install Story binary v0.12.1
cd $HOME
wget https://github.com/piplabs/story/releases/download/v0.12.1/story-linux-amd64
chmod +x story-linux-amd64
mv $HOME/story-linux-amd64 $HOME/go/bin/story

# Create directories
mkdir -p ~/.story/story
mkdir -p ~/.story/geth

# Init Story
story init --network odyssey --moniker "moniker"

# Create story-geth service
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --odyssey --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Create story service
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Download and apply snapshots
echo "Downloading and applying snapshots..."

# Story snapshot
cd $HOME
rm -f Story_snapshot.lz4
curl -o Story_snapshot.lz4 https://files-story.catsmile.tech/story/story-snapshot.tar.lz4

# Geth snapshot
cd $HOME
rm -f Geth_snapshot.lz4
curl -o Geth_snapshot.lz4 https://files-story.catsmile.tech/geth/geth-snapshot.tar.lz4

# Backup
cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup

# Remove old data
rm -rf ~/.story/story/data
rm -rf ~/.story/geth/odyssey/geth/chaindata

# Decompress Geth snapshot
sudo mkdir -p /root/.story/geth/odyssey/geth/chaindata
lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/odyssey/geth/ > /dev/null

# Restore priv_validator_state.json
cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json

echo "Installation and snapshot setup complete!"
echo "Start services with:"
echo "sudo systemctl start story-geth story"
echo "Check logs with:"
echo "sudo journalctl -u story-geth -f"
