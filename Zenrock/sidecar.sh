#!/bin/bash

echo "========================================"
echo " Sidecar Setup Script"
echo "========================================"
echo

# Input dari pengguna
read -p "Enter password for the keys: " key_pass
read -p "Enter TESTNET_HOLESKY_ENDPOINT: " TESTNET_HOLESKY_ENDPOINT
read -p "Enter MAINNET_ENDPOINT: " MAINNET_ENDPOINT
read -p "Enter ETH_RPC_URL: " ETH_RPC_URL
read -p "Enter ETH_WS_URL: " ETH_WS_URL

# Step 1: Clone zenrock-validators repository
echo "Step 1: Cloning zenrock-validators repository..."
cd $HOME
rm -rf zenrock-validators
git clone https://github.com/zenrocklabs/zenrock-validators
echo "Repository cloned successfully!"
echo
sleep 2

# Step 2: Generate keys
echo "Step 2: Generating keys..."

# Create sidecar directories
mkdir -p $HOME/.zrchain/sidecar/bin
mkdir -p $HOME/.zrchain/sidecar/keys

# Build ecdsa binary
cd $HOME/zenrock-validators/utils/keygen/ecdsa && go build

# Build bls binary
cd $HOME/zenrock-validators/utils/keygen/bls && go build

# Generate ecdsa key
ecdsa_output_file=$HOME/.zrchain/sidecar/keys/ecdsa.key.json
ecdsa_creation=$($HOME/zenrock-validators/utils/keygen/ecdsa/ecdsa --password $key_pass -output-file $ecdsa_output_file)
ecdsa_address=$(echo "$ecdsa_creation" | grep "Public address" | cut -d: -f2)

# Generate bls key
bls_output_file=$HOME/.zrchain/sidecar/keys/bls.key.json
$HOME/zenrock-validators/utils/keygen/bls/bls --password $key_pass -output-file $bls_output_file

# Output
echo "Keys generated successfully!"
echo
sleep 2

# Step 3: Top up your wallet address
echo "Step 3: Top up your wallet address"
echo "Please fund your wallet addresses with Holesky $ETH before proceeding further."
echo
sleep 2

# Step 4: Set operator configuration
echo "Step 4: Setting operator configuration..."

# Declare variables
EIGEN_OPERATOR_CONFIG="$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
OPERATOR_VALIDATOR_ADDRESS_TBD=$(zenrockd keys show wallet --bech val -a)
OPERATOR_ADDRESS_TBU=$ecdsa_address
ECDSA_KEY_PATH=$ecdsa_output_file
BLS_KEY_PATH=$bls_output_file

# Copy initial configuration files
cp $HOME/zenrock-validators/configs/eigen_operator_config.yaml $HOME/.zrchain/sidecar/
cp $HOME/zenrock-validators/configs/config.yaml $HOME/.zrchain/sidecar/

# Replace variables in config.yaml
sed -i "s|EIGEN_OPERATOR_CONFIG|$EIGEN_OPERATOR_CONFIG|g" "$HOME/.zrchain/sidecar/config.yaml"
sed -i "s|TESTNET_HOLESKY_ENDPOINT|$TESTNET_HOLESKY_ENDPOINT|g" "$HOME/.zrchain/sidecar/config.yaml"
sed -i "s|MAINNET_ENDPOINT|$MAINNET_ENDPOINT|g" "$HOME/.zrchain/sidecar/config.yaml"

# Replace variables in eigen_operator_config.yaml
sed -i "s|OPERATOR_VALIDATOR_ADDRESS_TBD|$OPERATOR_VALIDATOR_ADDRESS_TBD|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
sed -i "s|OPERATOR_ADDRESS_TBU|$OPERATOR_ADDRESS_TBU|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
sed -i "s|ETH_RPC_URL|$ETH_RPC_URL|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
sed -i "s|ETH_WS_URL|$ETH_WS_URL|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
sed -i "s|ECDSA_KEY_PATH|$ECDSA_KEY_PATH|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
sed -i "s|BLS_KEY_PATH|$BLS_KEY_PATH|g" "$HOME/.zrchain/sidecar/eigen_operator_config.yaml"
echo "Configuration set successfully!"
echo
sleep 2

# Step 5: Download sidecar binary
echo "Step 5: Downloading sidecar binary..."
wget -O $HOME/.zrchain/sidecar/bin/validator_sidecar https://releases.gardia.zenrocklabs.io/validator_sidecar-1.2.3
chmod +x $HOME/.zrchain/sidecar/bin/validator_sidecar
echo "Sidecar binary downloaded and made executable!"
echo
sleep 2

# Step 6: Create and run sidecar service
echo "Step 6: Creating and running sidecar service..."
sudo tee /etc/systemd/system/zenrock-testnet-sidecar.service > /dev/null <<EOF
[Unit]
Description=Validator Sidecar
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/.zrchain/sidecar/bin/validator_sidecar
Restart=on-failure
RestartSec=30
LimitNOFILE=65535
Environment="OPERATOR_BLS_KEY_PASSWORD=$key_pass"
Environment="OPERATOR_ECDSA_KEY_PASSWORD=$key_pass"
Environment="SIDECAR_CONFIG_FILE=$HOME/.zrchain/sidecar/config.yaml"

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable zenrock-testnet-sidecar.service
sudo systemctl start zenrock-testnet-sidecar.service
echo "Service created and started successfully!"
echo
sleep 2

# Step 7: Display ECDSA address
echo "Step 7: Displaying ECDSA address..."
echo "Your ECDSA address is: $ecdsa_address"
echo "Silahkan isi Faucet Holesky, setelah itu lakukan restart"
echo "sudo systemctl restart zenrock-testnet-sidecar.service"
echo