#!/bin/bash

echo "Welcome to the t3rn Executor Setup!"

# Update dan upgrade sistem
echo "Updating and upgrading the system..."
sudo apt update -q
sudo apt upgrade -qy

# Mendapatkan versi terbaru dari Executor
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4)
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/${LATEST_VERSION}/executor-linux-${LATEST_VERSION}.tar.gz"
EXECUTOR_FILE="executor-linux-${LATEST_VERSION}.tar.gz"

echo "Latest version detected: $LATEST_VERSION"
echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

if [ $? -ne 0 ]; then
    echo "Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

# Extract the binary
echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE
rm -rf $EXECUTOR_FILE
cd executor/executor/bin

echo "Binary downloaded and extracted successfully."
echo

# Set Node Environment
export NODE_ENV=testnet
echo "Node Environment set to: $NODE_ENV"
echo

# Set log settings
export LOG_LEVEL=debug
export LOG_PRETTY=false
echo "Log settings configured: LOG_LEVEL=$LOG_LEVEL, LOG_PRETTY=$LOG_PRETTY"
echo

# Set Private Key
read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
# Hapus "0x" jika ada
PRIVATE_KEY_LOCAL=${PRIVATE_KEY_LOCAL#0x}
export PRIVATE_KEY_LOCAL
echo -e "\nPrivate key has been set."
echo

# Set enabled networks
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'
echo "Enabled Networks set to: $ENABLED_NETWORKS"
echo

# Menambahkan pengaturan untuk jumlah (amount) acak dalam rentang 0.01 - 0.01111
MIN_AMOUNT=0.01
MAX_AMOUNT=0.01111
TRANSACTION_AMOUNT=$(awk -v min=$MIN_AMOUNT -v max=$MAX_AMOUNT 'BEGIN{srand(); print min+rand()*(max-min)}')
export TRANSACTION_AMOUNT
echo "Transaction amount set to: $TRANSACTION_AMOUNT"
echo

# Membuat service systemd untuk executor
SERVICE_FILE="/etc/systemd/system/executor.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/executor/executor/bin
Environment=NODE_ENV=$NODE_ENV
Environment=LOG_LEVEL=$LOG_LEVEL
Environment=LOG_PRETTY=$LOG_PRETTY
Environment=PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
Environment=ENABLED_NETWORKS=$ENABLED_NETWORKS
Environment=TRANSACTION_AMOUNT=$TRANSACTION_AMOUNT
ExecStart=$HOME/executor/executor/bin/executor
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable executor.service
sudo systemctl start executor.service

echo "Setup complete! The Executor service has been created and started."
echo "You can check the status of the service using: sudo systemctl status executor.service"
echo

# Menampilkan log dari service executor
echo "Displaying the log of the executor service:"
sudo journalctl -u executor.service -f
