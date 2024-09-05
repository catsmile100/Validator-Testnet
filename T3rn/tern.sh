#!/bin/bash

# Update and install dependencies
echo "Updating and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl wget tar build-essential jq unzip -y
sleep 2

# Download Executor Binary
echo "Downloading Executor Binary..."
cd $HOME
wget https://github.com/t3rn/executor-release/releases/download/v0.1.0/executor-linux-amd64.tar.gz
sleep 2

# Verify the download (optional)
# echo "Verifying download..."
# wget https://github.com/t3rn/executor-release/releases/download/v0.1.0/sha256sum.txt
# sha256sum -c sha256sum.txt

# Extract the binary
echo "Extracting Executor Binary..."
tar -xvf executor-linux-amd64.tar.gz
cd executor-linux-amd64
sleep 2

# Set environment variables
echo "Setting environment variables..."
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export PRIVATE_KEY_LOCAL=dead93c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56dbeef
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'

# Optional: Set custom RPC URLs
# export EXECUTOR_ARBITRUM-SEPOLIA_RPC_URLS='url1,url2'

# Start the Executor
echo "Starting the Executor..."
./executor

echo "Executor setup complete."