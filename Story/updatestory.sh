#!/bin/bash

# List of required packages
packages=("wget" "dos2unix" "lz4" "aria2" "pv")

# Function to check and install packages
install_if_not_present() {
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            sudo apt-get install -y $package
        else
            echo "$package is already installed."
        fi
    done
}

# Call the function to check and install packages
install_if_not_present

# Remove old files if they exist
echo "Removing old files if they exist..."
[ -f Geth_snapshot.lz4 ] && rm -f Geth_snapshot.lz4
[ -f Story_snapshot.lz4 ] && rm -f Story_snapshot.lz4

# Stop geth and story services
echo "Stopping geth and story services..."
if systemctl list-units --full -all | grep -q "geth.service"; then
    sudo systemctl stop geth
else
    sudo systemctl stop story-geth
fi
sudo systemctl stop story

# Sleep for 5 seconds
echo "Waiting for 5 seconds..."
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
echo "Starting geth and story services..."
if systemctl list-units --full -all | grep -q "geth.service"; then
    sudo systemctl start geth
else
    sudo systemctl start story-geth
fi
sudo systemctl start story

echo "Done."
