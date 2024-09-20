#!/bin/bash

# Stop the services
sudo systemctl stop story
sudo systemctl stop story-geth

# Delete 
rm -rf Story_snapshot.lz4
rm -rf Geth_snapshot.lz4

# Download Story-data
cd $HOME
rm -f Story_snapshot.lz4
wget --show-progress https://josephtran.co/Story_snapshot.lz4

# Download Geth-data
cd $HOME
rm -f Geth_snapshot.lz4
wget --show-progress https://josephtran.co/Geth_snapshot.lz4

# Backup priv_validator_state.json
cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup

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
cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json

# Restart the services
sudo systemctl start story
sudo systemctl start story-geth

echo "Update completed successfully!"
