<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/b6405d54-9ea3-443f-b920-e2a717fdf499">
</p>

</h2>
<p align="center"> 0G </p>
<p align="center"> 0G is the first decentralized AI operating system designed to power the future of AI infrastructure. Built as the fastest modular AI blockchain, it provides unmatched scalability with 50,000x faster performance and 100x lower costs than competitors, enabling seamless integration of Web3 and AI applications </p>
</h2>

<p align="center">
  <a href="https://0g.ai/">Home</a> |
  <a href="https://discord.com/invite/0glabs">Discord</a> |
  <a href="https://twitter.com/0G_labs">Twitter</a> |
  <a href="https://github.com/0glabs">Github</a> 
</p>

### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 8          | 64         | 1 TB  | 

# Install required packages
```
sudo apt update && \
sudo apt install curl git jq build-essential gcc unzip wget lz4 -y
```
# Install Go
```
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```
# Build 0gchaind binary
```
git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
cd 0g-chain
make install
0gchaind version
```
# Set up variables
```
echo 'export MONIKER=""' >> ~/.bash_profile
echo 'export CHAIN_ID="zgtendermint_16600-1"' >> ~/.bash_profile
echo 'export WALLET_NAME="wallet"' >> ~/.bash_profile
echo 'export RPC_PORT="36657"' >> ~/.bash_profile
source $HOME/.bash_profile
```
# Initialize the node
```
cd $HOME
0gchaind init $MONIKER --chain-id $CHAIN_ID
0gchaind config chain-id $CHAIN_ID
0gchaind config node tcp://localhost:$RPC_PORT
0gchaind config keyring-backend os
```
# Download genesis
```
wget https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json -O $HOME/.0gchain/config/genesis.json
```
# Add seeds and peers to the config
```
SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"${SEEDS}\"/" $HOME/.0gchain/config/config.toml
```
# Change ports
```
EXTERNAL_IP=$(wget -qO- eth0.me)
PROXY_APP_PORT=36657
P2P_PORT=36656
PPROF_PORT=6062
API_PORT=1319
GRPC_PORT=9092
GRPC_WEB_PORT=9093
```
```
sed -i \
    -e "s/\(proxy_app = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$PROXY_APP_PORT\"/" \
    -e "s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$RPC_PORT\"/" \
    -e "s/\(pprof_laddr = \"\)\([^:]*\):\([0-9]*\).*/\1localhost:$PPROF_PORT\"/" \
    -e "/\[p2p\]/,/^\[/{s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$P2P_PORT\"/}" \
    -e "/\[p2p\]/,/^\[/{s/\(external_address = \"\)\([^:]*\):\([0-9]*\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/; t; s/\(external_address = \"\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/}" \
    $HOME/.0gchain/config/config.toml
```
```
sed -i \
    -e "/\[api\]/,/^\[/{s/\(address = \"tcp:\/\/\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$API_PORT\4/}" \
    -e "/\[grpc\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_PORT\4/}" \
    -e "/\[grpc-web\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_WEB_PORT\4/}" \
    $HOME/.0gchain/config/app.toml
```
# Configure pruning to save storage
```
sed -i \
    -e "s/^pruning *=.*/pruning = \"custom\"/" \
    -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
    -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" \
    "$HOME/.0gchain/config/app.toml"
```
# Set min gas price 
```
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ua0gi\"/" $HOME/.0gchain/config/app.toml
```
# Enable indexer (Optional)
```
sed -i "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.0gchain/config/config.toml
```
# Create a service file
```
sudo tee /etc/systemd/system/0gd.service > /dev/null <<EOF
[Unit]
Description=0G Node
After=network.target

[Service]
User=root
Type=simple
ExecStart=$(which 0gchaind) start --home $HOME/.0gchain
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
# Start the node
```
sudo systemctl daemon-reload && \
sudo systemctl enable 0gd && \
sudo systemctl restart 0gd && \
sudo journalctl -u 0gd -f -o cat
```
# Creae Validator
```
0gchaind tx staking create-validator \
  --amount=1000000ua0gi \
  --pubkey=$(0gchaind tendermint show-validator) \
  --moniker="your_moniker" \
  --identity="keybas" \
  --chain-id=zgtendermint_16600-1 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --details="the validator" \
  --min-self-delegation="1" \
  --from=<address> \
  --gas=auto \
  --gas-adjustment=1.4
```
# Delegate
```
0gchaind tx staking delegate \
  $(0gchaind keys show (your_address) --bech val -a) \
  x000000ua0gi \
  --from (your_address) \
  --chain-id zgtendermint_16600-1 \
  --gas=auto \
  --gas-adjustment=1.4
```
