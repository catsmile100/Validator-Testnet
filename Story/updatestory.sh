#!/bin/bash

# Install necessary packages
sudo apt-get install wget dos2unix lz4 aria2 pv -y

# Removed old files
rm -rf Geth_snapshot.lz4 Story_snapshot.lz4

# Stop geth and story services
sudo systemctl stop geth
sudo systemctl stop story

# Sleep for 5 seconds
sleep 5

# Download Geth snapshot
cd $HOME
rm -f Geth_snapshot.lz4
if curl -s --head https://vps6.josephtran.xyz/Story/Geth_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps6.josephtran.xyz/Story/Geth_snapshot.lz4 -o Geth_snapshot.lz4
else
    echo "No snapshot found."
fi

# Sleep for 5 seconds
sleep 5

# Download Story snapshot
cd $HOME
rm -f Story_snapshot.lz4
if curl -s --head https://vps6.josephtran.xyz/Story/Story_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps6.josephtran.xyz/Story/Story_snapshot.lz4 -o Story_snapshot.lz4
else
    echo "No snapshot found."
fi

# Sleep for 5 seconds
sleep 5

# Backup priv_validator_state.json
mv $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Sleep for 5 seconds
sleep 5

# Extract Geth snapshot
sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
lz4 -d Geth_snapshot.lz4 | pv | sudo tar xv -C /root/.story/geth/iliad/geth/

# Sleep for 5 seconds
sleep 5

# Extract Story snapshot
sudo mkdir -p /root/.story/story/data
lz4 -d Story_snapshot.lz4 | pv | sudo tar xv -C /root/.story/story/

# Sleep for 5 seconds
sleep 5

# Restore priv_validator_state.json
mv $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Sleep for 5 seconds
sleep 5

# Start geth and story services
sudo systemctl start geth
sudo systemctl start story
