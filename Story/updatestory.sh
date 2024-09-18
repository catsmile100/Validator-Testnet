#!/bin/bash

# Install tools
sudo apt-get install wget lz4 aria2 pv -y

# Stop node
sudo systemctl stop story
sudo systemctl stop story-geth

# Download Story-data
cd $HOME
rm -f Story_snapshot.lz4
wget --show-progress https://files.josephtran.cc/story/Story_snapshot.lz4

# Download Geth-data
cd $HOME
rm -f Geth_snapshot.lz4
wget --show-progress https://files.josephtran.cc/story/Geth_snapshot.lz4

# Backup priv_validator_state.json
mv $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Remove old data
rm -rf ~/.story/story/data
rm -rf ~/.story/geth/iliad/geth/chaindata

# Extract Story-data
sudo mkdir -p /root/.story/story/data
lz4 -d Story_snapshot.lz4 | pv | sudo tar xv -C /root/.story/story/

# Extract Geth-data
sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
lz4 -d Geth_snapshot.lz4 | pv | sudo tar xv -C /root/.story/geth/iliad/geth/

# Move priv_validator_state.json back
mv $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Restart node
sudo systemctl start story
sudo systemctl start story-geth
