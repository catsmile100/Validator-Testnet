#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function: Display header
print_header() {
  echo -e "\n============================================================"
  echo -e "                         INITIA WEAVE                         "
  echo -e "============================================================\n"
}

# Function: Update system and install dependencies
install_dependencies() {
  echo -e "\n[1/6] Updating system and installing dependencies...\n"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y htop ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
  tmux iptables curl nvme-cli git wget make jq libleveldb-dev build-essential pkg-config \
  ncdu tar clang bsdmainutils lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4
}

# Function: Check if Go is installed
check_go_installed() {
  if command -v go &> /dev/null; then
    echo -e "\n[2/6] Go is already installed. Skipping Go installation...\n"
  else
    install_go
  fi
}

# Function: Install Go
install_go() {
  local GO_VERSION="1.23.0"
  echo -e "\n[2/6] Installing Go version $GO_VERSION...\n"
  wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm "go${GO_VERSION}.linux-amd64.tar.gz"

  # Configure PATH for Go
  [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
  echo "export PATH=\$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
  mkdir -p ~/go/bin
}

# Function: Clone and install Initia Weave
install_weave() {
  echo -e "\n[3/6] Downloading and installing Initia Weave...\n"
  git clone https://github.com/initia-labs/weave.git
  cd weave
  git checkout tags/v0.1.1
  make install
  cd ..
}

# Function: Create a wallet
setup_wallet() {
  echo -e "\n[4/6] Creating a new wallet with Initia Weave...\n"
  weave gas-station setup
  echo -e "\nSave the seed phrase securely."
  echo -e "Type 'continue' to proceed after noting the seed phrase.\n"
}

# Function: Initialize and run the node
start_node() {
  echo -e "\n[5/6] Initializing Weave...\n"
  weave init
  echo -e "\nSelect the appropriate L1 node.\n"

  # Create a systemd service file for Initia
  echo -e "\n[6/6] Creating a service to run Initia Weave...\n"
  sudo tee /etc/systemd/system/initia.service > /dev/null <<EOL
[Unit]
Description=Initia Weave Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=$(which weave) initia start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOL

  # Reload systemd and start the service
  sudo systemctl daemon-reload
  sudo systemctl enable initia
  sudo systemctl start initia
  echo -e "The node is running as a service named 'initia'.\n"
}

# Function: Display wallet balance
show_balance() {
  echo -e "\nDisplaying wallet balance...\n"
  weave gas-station show
}

# Main menu
main() {
  print_header
  install_dependencies
  check_go_installed
  install_weave
  setup_wallet
  show_balance
  start_node

  echo -e "\n============================================================"
  echo -e "                            INITIA WEAVE                      "
  echo -e "============================================================\n"
}

# Execute the main function
main
