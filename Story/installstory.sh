#!/usr/bin/env bash

function install_node() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY NODE INSTALLER          ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    # Stop and cleanup existing installation
    echo "Checking for existing installation..."
    if systemctl is-active --quiet story-geth || systemctl is-active --quiet story; then
        echo "Stopping existing Story services..."
        sudo systemctl stop story-geth story
        sudo systemctl disable story-geth story
        sudo rm /etc/systemd/system/story-geth.service
        sudo rm /etc/systemd/system/story.service
        sudo systemctl daemon-reload
    fi

    if [ -d "$HOME/.story" ]; then
        echo "Removing old Story data..."
        rm -rf $HOME/.story
    fi

    if [ -d "/usr/local/go" ]; then
        echo "Removing old Go installation..."
        sudo rm -rf /usr/local/go
    fi

    # Get moniker from user input
    echo -e "\n\e[35m=== Please set your Story validator name ===\e[0m"
    echo -e "\e[32mNote: Use only letters, numbers, and underscore\e[0m"
    read -p "Enter validator name: " MONIKER

    # Validate moniker
    if [ -z "$MONIKER" ]; then
        echo -e "\e[31mError: Validator name cannot be empty\e[0m"
        exit 1
    fi

    if [[ ! $MONIKER =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "\e[31mError: Validator name can only contain letters, numbers, and underscore\e[0m"
        exit 1
    fi

    echo -e "\n\e[32mValidator Name: $MONIKER\e[0m\n"
    sleep 2

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
    story init --network odyssey --moniker "$MONIKER"

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

    # Enable and start services
    echo "Enabling and starting services..."
    sudo systemctl daemon-reload
    sudo systemctl enable story-geth
    sudo systemctl start story-geth
    sudo systemctl enable story
    sudo systemctl start story

    # Download and apply snapshots
    echo "Downloading and applying snapshots..."

    # Stop services for snapshot
    sudo systemctl stop story-geth story

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

    # Restart services
    sudo systemctl restart story-geth story

    echo "Installation complete!"
    echo "Check logs with:"
    echo "sudo journalctl -u story-geth -f"
}

function check_sync() {
    clear
    echo "Checking sync status..."
    
    RPC_PORT=$(cat $HOME/.story/story/config/config.toml | grep "laddr = \"tcp" | head -n1 | cut -d: -f3 | tr -d '"')
    
    while true; do
        local_height=$(curl -s localhost:$RPC_PORT/status | jq -r '.result.sync_info.latest_block_height' 2>/dev/null)
        network_height=$(curl -s https://odyssey.storyrpc.io/status | jq -r '.result.sync_info.latest_block_height' 2>/dev/null)
        
        if [ -z "$local_height" ] || [ -z "$network_height" ]; then
            echo -e "\e[31mError: Node is not running or cannot connect to RPC\e[0m"
            break
        fi
        
        blocks_left=$((network_height - local_height))
        echo -e "\033[1;38mYour node height:\033[0m \033[1;34m$local_height\033[0m | \033[1;35mNetwork height:\033[0m \033[1;36m$network_height\033[0m | \033[1;29mBlocks left:\033[0m \033[1;31m$blocks_left\033[0m"
        echo -e "\nPress Ctrl+C to return to menu"
        sleep 5
        clear
    done
}

function delete_node() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY NODE DELETE             ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"
    
    echo -e "\n\e[31mWarning: This will completely remove Story node from your system!\e[0m"
    echo -e "\e[33mAre you sure you want to continue? (y/n)\e[0m"
    read -p "" choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -e "\n\e[33mStopping and removing Story services...\e[0m"
        sudo systemctl stop story-geth
        sudo systemctl stop story
        sudo systemctl disable story-geth
        sudo systemctl disable story
        sudo rm /etc/systemd/system/story-geth.service
        sudo rm /etc/systemd/system/story.service
        sudo systemctl daemon-reload

        echo -e "\e[33mRemoving Story directories and binaries...\e[0m"
        sudo rm -rf $HOME/.story
        sudo rm $HOME/go/bin/story-geth
        sudo rm $HOME/go/bin/story

        echo -e "\n\e[32mStory node has been completely removed!\e[0m"
        sleep 3
    else
        echo -e "\n\e[33mOperation cancelled.\e[0m"
        sleep 2
    fi
}

# Tambahkan fungsi upgrade
function upgrade_node() {
    clear
    echo "╔═══════════════════════════════╗"
    echo "║        STORY NODE UPGRADE     ║"
    echo "║          catsmile.tech        ║"
    echo "╚═══════════════════════════════╝"

    echo -e "\n\e[33mPreparing Cosmovisor upgrade to v0.13.0...\e[0m"
    
    # Confirmation
    echo -e "\n\e[31mWarning: Please make sure your node is fully synced before upgrading!\e[0m"
    echo -e "\e[33mDo you want to continue? (y/n)\e[0m"
    read -p "" choice

    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo -e "\n\e[33mUpgrade cancelled.\e[0m"
        sleep 2
        return
    fi

    echo -e "\n\e[32mStarting upgrade process...\e[0m"
    
    # Install/upgrade Cosmovisor
    source $HOME/.bash_profile
    go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
    
    # Create upgrade directory
    mkdir -p $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin
    
    # Create upgrade info
    echo '{"name":"v0.13.0","time":"0001-01-01T00:00:00Z","height":858000}' > $HOME/.story/story/cosmovisor/upgrades/v0.13.0/upgrade-info.json
    
    # Install tree and show structure
    sudo apt install tree -y
    tree $HOME/.story/story/cosmovisor
    
    # Download and prepare new binary
    cd $HOME
    rm -f story-linux-amd64
    wget https://github.com/piplabs/story/releases/download/v0.13.0/story-linux-amd64
    chmod +x story-linux-amd64
    sudo cp $HOME/story-linux-amd64 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story
    
    # Show version info
    echo -e "\n\e[32mChecking versions:\e[0m"
    echo -e "\nCurrent symlink:"
    ls -l /root/.story/story/cosmovisor/current
    
    echo -e "\nCurrent version (should be v0.12.1):"
    $HOME/.story/story/cosmovisor/upgrades/v0.12.1/bin/story version
    
    echo -e "\nNew version in upgrade folder:"
    $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story version
    
    echo -e "\nUpgrade info:"
    cat $HOME/.story/story/cosmovisor/upgrades/v0.13.0/upgrade-info.json
    
    # Add upgrade to Cosmovisor
    source $HOME/.bash_profile
    cosmovisor add-upgrade v0.13.0 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story --force --upgrade-height 858000
    
    echo -e "\n\e[32mUpgrade preparation completed!\e[0m"
    echo -e "\e[33mNode will automatically upgrade at block height 858000\e[0m"
    sleep 3
}

# Add restart function
function restart_services() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY NODE RESTART            ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    echo -e "\n\e[33mStopping Story services...\e[0m"
    sudo systemctl stop story-geth
    sudo systemctl stop story
    sleep 2

    echo -e "\n\e[33mStarting Story services...\e[0m"
    sudo systemctl start story-geth
    sudo systemctl start story
    sleep 2

    echo -e "\n\e[32mChecking services status:\e[0m"
    echo -e "\nStory-Geth status:"
    sudo systemctl status story-geth | grep "Active:"
    echo -e "\nStory status:"
    sudo systemctl status story | grep "Active:"

    echo -e "\n\e[32mServices have been restarted!\e[0m"
    echo -e "Press Enter to return to menu"
    read
}

# Add version check function
function check_version() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY VERSION CHECK           ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    echo -e "\n\e[1;33mStory-Geth Version:\e[0m"
    if command -v story-geth &> /dev/null; then
        story-geth version
    else
        echo -e "\e[31mStory-Geth is not installed\e[0m"
    fi

    echo -e "\n\e[1;33mStory Version:\e[0m"
    if command -v story &> /dev/null; then
        story version
    else
        echo -e "\e[31mStory is not installed\e[0m"
    fi

    echo -e "\nPress Enter to return to menu"
    read
}

# Add balance check function
function check_balance() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY BALANCE CHECK           ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    # Get EVM Address
    EVM_ADDRESS=$(story validator export --export-evm-key 2>/dev/null | grep "EVM Address:" | cut -d: -f2 | tr -d ' ')
    
    if [ ! -z "$EVM_ADDRESS" ]; then
        echo -e "\n\e[1;33mEVM Address:\e[0m $EVM_ADDRESS"
        BALANCE=$(story-geth --exec "eth.getBalance('$EVM_ADDRESS')" attach ~/.story/geth/odyssey/geth.ipc)
        echo -e "\e[1;33mBalance:\e[0m $BALANCE wei"
    else
        echo -e "\e[31mError: Could not get EVM address\e[0m"
    fi

    echo -e "\nPress Enter to return to menu"
    read
}

function create_validator() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY CREATE VALIDATOR        ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    # Get private key and check balance first
    if [ -f "$HOME/.story/story/config/private_key.txt" ]; then
        PRIVATE_KEY=$(cat $HOME/.story/story/config/private_key.txt | grep -oP 'PRIVATE_KEY=\K.*')
        MONIKER=$(story status | jq -r .NodeInfo.moniker)
        EVM_ADDRESS=$(story validator export --export-evm-key 2>/dev/null | grep "EVM Address:" | cut -d: -f2 | tr -d ' ')
        BALANCE=$(story-geth --exec "eth.getBalance('$EVM_ADDRESS')" attach ~/.story/geth/odyssey/geth.ipc)
        
        echo -e "\n\e[1;33mWallet Info:\e[0m"
        echo -e "EVM Address: $EVM_ADDRESS"
        echo -e "Current Balance: $BALANCE wei"
        echo -e "Required Balance: 1024000000000000000000 wei\n"
        
        if [ "$BALANCE" -lt 1024000000000000000000 ]; then
            echo -e "\e[31mError: Insufficient balance. Need at least 1024 IP to create validator\e[0m"
        else
            echo -e "\e[1;33mCreating validator with:\e[0m"
            echo -e "Moniker: $MONIKER"
            echo -e "Stake Amount: 1024 IP (1024000000000000000000 wei)\n"
            
            story validator create --stake 1024000000000000000000 \
                --private-key "$PRIVATE_KEY" \
                --moniker "$MONIKER" \
                --chain-id 1516

            echo -e "\n\e[32mValidator creation completed!\e[0m"
        fi
    else
        echo -e "\e[31mError: Private key file not found\e[0m"
    fi

    echo -e "\nPress Enter to return to menu"
    read
}

function create_staking() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY CREATE STAKING          ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    # Get validator public key and check balance first
    if [ -f "$HOME/.story/story/config/private_key.txt" ]; then
        VALIDATOR_PUBKEY=$(story validator export --export-evm-key 2>/dev/null | grep "Compressed Public Key (hex):" | cut -d: -f2 | tr -d ' ')
        PRIVATE_KEY=$(cat $HOME/.story/story/config/private_key.txt | grep -oP 'PRIVATE_KEY=\K.*')
        EVM_ADDRESS=$(story validator export --export-evm-key 2>/dev/null | grep "EVM Address:" | cut -d: -f2 | tr -d ' ')
        BALANCE=$(story-geth --exec "eth.getBalance('$EVM_ADDRESS')" attach ~/.story/geth/odyssey/geth.ipc)
        
        echo -e "\n\e[1;33mWallet Info:\e[0m"
        echo -e "EVM Address: $EVM_ADDRESS"
        echo -e "Current Balance: $BALANCE wei"
        echo -e "Required Balance: 1024000000000000000000 wei\n"
        
        if [ "$BALANCE" -lt 1024000000000000000000 ]; then
            echo -e "\e[31mError: Insufficient balance. Need at least 1024 IP to create staking\e[0m"
        else
            echo -e "\e[1;33mCreating staking with:\e[0m"
            echo -e "Validator Public Key: $VALIDATOR_PUBKEY"
            echo -e "Stake Amount: 1024 IP (1024000000000000000000 wei)\n"
            
            story validator stake \
                --validator-pubkey "$VALIDATOR_PUBKEY" \
                --stake 1024000000000000000000 \
                --private-key "$PRIVATE_KEY" \
                --chain-id 1516

            echo -e "\n\e[32mStaking creation completed!\e[0m"
        fi
    else
        echo -e "\e[31mError: Private key file not found\e[0m"
    fi

    echo -e "\nPress Enter to return to menu"
    read
}

function install_cosmovisor() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║      STORY COSMOVISOR SETUP          ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    echo -e "\n\e[33mChecking Go version...\e[0m"
    GO_VERSION=$(go version | cut -d " " -f 3)
    if [[ "${GO_VERSION}" < "go1.22" ]]; then
        echo -e "\e[31mError: Go version must be 1.22 or higher\e[0m"
        return
    fi

    echo -e "\n\e[33m1. Installing Cosmovisor v1.7...\e[0m"
    source $HOME/.bash_profile
    go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
    
    echo -e "\n\e[33m2. Setting up environment variables...\e[0m"
    export DAEMON_NAME=story
    echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
    export DAEMON_HOME=$HOME/.story/story
    echo "export DAEMON_HOME=$HOME/.story/story" >> $HOME/.bash_profile
    
    echo -e "\n\e[33m3. Initializing Cosmovisor...\e[0m"
    cosmovisor init $(which story)
    
    echo -e "\n\e[33m4. Creating backup directory...\e[0m"
    mkdir -p $DAEMON_HOME/cosmovisor/backup
    echo "export DAEMON_DATA_BACKUP_DIR=$DAEMON_HOME/cosmovisor/backup" >> $HOME/.bash_profile
    echo "export DAEMON_ALLOW_DOWNLOAD_BINARIES=false" >> $HOME/.bash_profile
    
    echo -e "\n\e[33m5. Creating upgrade directories...\e[0m"
    mkdir -p $HOME/.story/story/cosmovisor/genesis/bin
    mkdir -p $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin
    
    echo -e "\n\e[33m6. Stopping Story service...\e[0m"
    sudo systemctl stop story
    
    echo -e "\n\e[33m7. Downloading and setting up v0.13.0 binary...\e[0m"
    cd $HOME
    rm -f story-linux-amd64
    wget https://github.com/piplabs/story/releases/download/v0.13.0/story-linux-amd64
    chmod +x story-linux-amd64
    sudo cp $HOME/story-linux-amd64 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story
    
    echo -e "\n\e[33m8. Adding upgrade information...\e[0m"
    echo '{"name":"v0.13.0","time":"0001-01-01T00:00:00Z","height":858000}' > $HOME/.story/story/cosmovisor/upgrades/v0.13.0/upgrade-info.json
    
    echo -e "\n\e[33m9. Updating service file...\e[0m"
    sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=/root/.story/story"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=/root/.story/story/data"
Environment="UNSAFE_SKIP_BACKUP=true"
ExecStart=/root/go/bin/cosmovisor run run
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

    echo -e "\n\e[33m10. Reloading and starting service...\e[0m"
    sudo systemctl daemon-reload
    sudo systemctl start story
    
    echo -e "\n\e[33m11. Setting upgrade schedule...\e[0m"
    source $HOME/.bash_profile
    cosmovisor add-upgrade v0.13.0 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story --force --upgrade-height 858000

    echo -e "\n\e[32mCosmovisor setup completed!\e[0m"
    echo -e "\e[33mIMPORTANT: Do not stop or restart node before block 858,000\e[0m"
    
    echo -e "\nPress Enter to return to menu"
    read
}

# Update main menu
while true; do
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        STORY NODE INSTALLER          ║"
    echo "║          catsmile.tech               ║"
    echo "╚══════════════════════════════════════╝"

    echo -e "\n\e[1;35mSelect an option:\e[0m"
    echo -e "\e[1;32m1)\e[0m Install Story Node"
    echo -e "\e[1;32m2)\e[0m Check Sync Status"
    echo -e "\e[1;31m3)\e[0m Delete Node"
    echo -e "\e[1;33m4)\e[0m Upgrade Node"
    echo -e "\e[1;36m5)\e[0m Check Version"
    echo -e "\e[1;35m6)\e[0m Restart Services"
    echo -e "\e[1;34m7)\e[0m Check Balance"
    echo -e "\e[1;33m8)\e[0m Create Validator"
    echo -e "\e[1;32m9)\e[0m Create Staking"
    echo -e "\e[1;31m10)\e[0m Install Cosmovisor"
    echo -e "\e[1;31m11)\e[0m Exit\n"
    read -p "Enter your choice (1-11): " choice

    case $choice in
        1)
            install_node
            ;;
        2)
            check_sync
            ;;
        3)
            delete_node
            ;;
        4)
            upgrade_node
            ;;
        5)
            check_version
            ;;
        6)
            restart_services
            ;;
        7)
            check_balance
            ;;
        8)
            create_validator
            ;;
        9)
            create_staking
            ;;
        10)
            install_cosmovisor
            ;;
        11)
            echo -e "\n\e[1;31mExiting...\e[0m"
            exit 0
            ;;
        *)
            echo -e "\n\e[1;31mInvalid option. Please try again.\e[0m"
            sleep 2
            ;;
    esac
done
