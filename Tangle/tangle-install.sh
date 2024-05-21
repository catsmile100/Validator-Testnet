#!/bin/bash
clear

if [[ ! -f "$HOME/.bash_profile" ]]; then
    touch "$HOME/.bash_profile"
fi

if [ -f "$HOME/.bash_profile" ]; then
    source $HOME/.bash_profile
fi

logo_catsmile(){

clear

 cat << "EOF"
=========================================================================
  ####      ##     ######    ####    ##   ##   ####    ##       ######  
 ##  ##    ####      ##     ##  ##   ### ###    ##     ##       ##      
 ##       ##  ##     ##     ##       #######    ##     ##       ##      
 ##       ######     ##      ####    ## # ##    ##     ##       ####    
 ##       ##  ##     ##         ##   ##   ##    ##     ##       ##      
 ##  ##   ##  ##     ##     ##  ##   ##   ##    ##     ##       ##      
  ####    ##  ##     ##      ####    ##   ##   ####    ######   ######  
=========================================================================
             Developed by: https://catsmile.tech
=========================================================================
EOF

}

logo_catsmile;



echo "===========Tangle Network Install Easy======= " && sleep 1

read -p "Do you want run node Tangle Network? (y/n): " choice

if [ "$choice" == "y" ]; then

if [ "$choice" == "y" ]; then
    read -p "Set Node Name: " input_moniker
    if [ -z "$input_moniker" ]; then
    echo "Node Name cannot be empty!"
    exit 1
     fi
     MONIKER="$input_moniker"
     echo "Node Name is: $MONIKER"
fi

sudo apt update && apt upgrade -y

sudo apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev libgmp3-dev tar clang bsdmainutils ncdu unzip llvm libudev-dev make protobuf-compiler -y

cd $HOME

sudo mkdir -p $HOME/.tangle && cd $HOME/.tangle

sudo wget -O tangle https://github.com/webb-tools/tangle/releases/download/v0.6.1/tangle-testnet-linux-amd64
sudo chmod 744 tangle
sudo mv tangle /usr/bin/
sudo tangle --version
# 0.5.0-e892e17-x86_64-linux-gnu

sudo wget -O $HOME/.tangle/tangle-standalone.json "https://raw.githubusercontent.com/webb-tools/tangle/main/chainspecs/testnet/tangle-testnet.json"

sudo chmod 744 ~/.tangle/tangle-standalone.json

sudo tee /etc/systemd/system/tangle.service > /dev/null << EOF
[Unit]
Description=Tangle Validator Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=/usr/bin/tangle \
  --base-path $HOME/.tangle/data/ \
  --name '$MONIKER' \
  --chain $HOME/.tangle/tangle-standalone.json \
  --node-key-file "$HOME/.tangle/node-key" \
  --port 30333 \
  --rpc-port 9933 \
  --prometheus-port 9615 \
  --auto-insert-keys \
  --validator \
  --telemetry-url "wss://telemetry.polkadot.io/submit 0" \
  --no-mdns
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable tangle
sudo systemctl restart tangle && sudo journalctl -u tangle -f -o cat

fi

sudo rm -rf tangle_install

echo "Check logs: sudo journalctl -u tangle -f -o cat"

echo "Check status: sudo systemctl status tangle"
