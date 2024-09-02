#!/bin/bash

# Banner ASCII
echo " ██████╗ █████╗ ████████╗███████╗███╗   ███╗██╗██╗     ███████╗"
echo "██╔════╝██╔══██╗╚══██╔══╝██╔════╝████╗ ████║██║██║     ██╔════╝"
echo "██║     ███████║   ██║   ███████╗██╔████╔██║██║██║     █████╗  "
echo "██║     ██╔══██║   ██║   ╚════██║██║╚██╔╝██║██║██║     ██╔══╝  "
echo "╚██████╗██║  ██║   ██║   ███████║██║ ╚═╝ ██║██║███████╗███████╗"
echo " ╚═════╝╚═╝  ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo "                                                               "

# Stop and disable existing services, remove old files
echo -e "\n\e[42mStopping and disabling existing services, removing old files...\e[0m\n"
{
    sudo systemctl stop story geth
    sudo systemctl disable story geth
    sudo rm /etc/systemd/system/story.service /etc/systemd/system/geth.service
    rm -rf $HOME/.story $HOME/bin $HOME/go/bin/story $HOME/go/bin/geth
    sudo systemctl daemon-reload
} &>/dev/null
echo -e "\n\e[42mExisting services stopped and old files removed.\e[0m\n"

# Input moniker
read -p "Enter your moniker: " MONIKER

# Function to check if a port is available
check_port() {
    local port=$1
    if sudo lsof -i -P -n | grep -q ":$port"; then
        return 1
    else
        return 0
    fi
}

# Default ports
DEFAULT_PORTS=(26656 26657 26658 1317 8545 8546 30303 8551)

# Check if default ports are available
echo -e "\n\e[42mChecking default ports...\e[0m\n"
all_ports_available=true
for port in "${DEFAULT_PORTS[@]}"; do
    if ! check_port $port; then
        all_ports_available=false
        break
    fi
done

# If default ports are not available, prompt for new port prefix
if [ "$all_ports_available" = false ]; then
    echo "Default ports are not available. Please enter a new port prefix."
    read -p "Enter new port prefix (2 digits, e.g., 14): " NEW_PREFIX

    # Validate input
    while [[ ! $NEW_PREFIX =~ ^[0-9]{2}$ ]]; do
        echo "Invalid input. Please enter 2 digits."
        read -p "Enter port prefix (2 digits, e.g., 14): " NEW_PREFIX
    done
else
    NEW_PREFIX=""
fi

# Install dependencies
echo -e "\n\e[42mInstalling dependencies...\e[0m\n"
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
echo -e "\n\e[42mDependencies installed.\e[0m\n"

# Install Go
echo -e "\n\e[42mInstalling Go...\e[0m\n"
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
echo -e "\n\e[42mGo installed.\e[0m\n"

# Download binaries
echo -e "\n\e[42mDownloading binaries...\e[0m\n"
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
echo -e "\n\e[42mBinaries downloaded.\e[0m\n"

# Initialize the story client
echo -e "\n\e[42mInitializing the story client...\e[0m\n"
story init --moniker "$MONIKER" --network iliad
echo -e "\n\e[42mStory client initialized.\e[0m\n"

# Create Geth service file
echo -e "\n\e[42mCreating Geth service file...\e[0m\n"
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 127.0.0.1 --http.port ${NEW_PREFIX}45 --ws --ws.api eth,web3,net,txpool --ws.addr 127.0.0.1 --ws.port ${NEW_PREFIX}46 --port ${NEW_PREFIX}03
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
echo -e "\n\e[42mGeth service file created.\e[0m\n"

# Create Story service file
echo -e "\n\e[42mCreating Story service file...\e[0m\n"
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/.story/story
ExecStart=$(which story) run
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
echo -e "\n\e[42mStory service file created.\e[0m\n"

# Enable and start Geth
echo -e "\n\e[42mEnabling and starting Geth...\e[0m\n"
sudo systemctl daemon-reload
sudo systemctl enable story-geth
sudo systemctl restart story-geth && sudo journalctl -u story-geth -f &
echo -e "\n\e[42mGeth enabled and started.\e[0m\n"

# Enable and start Story
echo -e "\n\e[42mEnabling and starting Story...\e[0m\n"
sudo systemctl enable story
sudo systemctl restart story && sudo journalctl -u story -f &
echo -e "\n\e[42mStory enabled and started.\e[0m\n"

# Configure peers
echo -e "\n\e[42mConfiguring peers...\e[0m\n"
PEERS="2f372238bf86835e8ad68c0db12351833c40e8ad@story-testnet-peer.itrocket.net:26656,00c495396dfee53a31476d7619d1cc252b9a47b9@89.58.62.213:26656,800bd9a3bb37a07d5c57c42a5de72d7ab370cfd1@100.42.189.22:26656,8e33fb7dfa20e61bf743cdea89f8ca909946a189@65.108.232.134:26656,6a1b35d7c8deae3f6b0588855300af1dfa8ebd17@49.12.172.31:13656,c82d2b5fe79e3159768a77f25eee4f22e3841f56@3.209.222.59:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.story/story/config/config.toml
echo -e "\n\e[42mPeers configured.\e[0m\n"

# Download addrbook and genesis
echo -e "\n\e[42mDownloading addrbook and genesis...\e[0m\n"
wget -O $HOME/.story/story/config/addrbook.json https://server-5.itrocket.net/testnet/story/addrbook.json
wget -O $HOME/.story/story/config/genesis.json https://server-5.itrocket.net/testnet/story/genesis.json
echo -e "\n\e[42mAddrbook and genesis downloaded.\e[0m\n"

# Restart services
echo -e "\n\e[42mRestarting services...\e[0m\n"
sudo systemctl restart story-geth
sudo systemctl restart story
echo -e "\n\e[42mServices restarted.\e[0m\n"

# Add enode peer
echo -e "\n\e[42mAdding enode peer...\e[0m\n"
geth --exec 'admin.addPeer("enode://499267340ce74fd95b56181b219fc1097b138156c961a38cce608cbd8e22dc02214644997a6fc84c49023e59a70d52ee10c3c40007bd1ccca06267d708fc4aeb@story-testnet-enode.itrocket.net:30301")' attach ~/.story/geth/iliad/geth.ipc
echo -e "\n\e[42mEnode peer added.\e[0m\n"

# Configure firewall rules
echo -e "\n\e[42mConfiguring firewall rules...\e[0m\n"
if [ -n "$NEW_PREFIX" ]; then
    sudo ufw allow ${NEW_PREFIX}45/tcp comment geth_http_port
    sudo ufw allow ${NEW_PREFIX}46/tcp comment geth_ws_port
    sudo ufw allow ${NEW_PREFIX}656/tcp comment story_p2p_port
    sudo ufw allow ${NEW_PREFIX}657/tcp comment story_rpc_port
    sudo ufw allow ${NEW_PREFIX}658/tcp comment story_grpc_port
    sudo ufw allow ${NEW_PREFIX}17/tcp comment story_api_port
    sudo ufw allow ${NEW_PREFIX}303/tcp comment geth_p2p_port
    sudo ufw allow ${NEW_PREFIX}51/tcp comment geth_engine_api_port
else
    sudo ufw allow 8545/tcp comment geth_http_port
    sudo ufw allow 8546/tcp comment geth_ws_port
    sudo ufw allow 26656/tcp comment story_p2p_port
    sudo ufw allow 26657/tcp comment story_rpc_port
    sudo ufw allow 26658/tcp comment story_grpc_port
    sudo ufw allow 1317/tcp comment story_api_port
    sudo ufw allow 30303/tcp comment geth_p2p_port
    sudo ufw allow 8551/tcp comment geth_engine_api_port
fi

# Allow SSH port through firewall
sudo ufw allow ssh

# Enable firewall
sudo ufw enable
echo -e "\n\e[42mFirewall rules configured.\e[0m\n"

# Snapshot
echo -e "\n\e[42mTaking snapshot...\e[0m\n"
sudo systemctl stop story story-geth
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup
rm -rf $HOME/.story/story/data
rm -rf $HOME/.story/geth/iliad/geth/chaindata
curl https://server-5.itrocket.net/testnet/story/story_2024-09-02_211110_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json
sudo systemctl restart story story-geth && sudo journalctl -u story -f
echo -e "\n\e[42mSnapshot taken.\e[0m\n"
