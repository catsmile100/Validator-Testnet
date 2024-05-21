<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1674417594194079747/xWQbhp9N_400x400.jpg">
</p>
<h1>
<p align="center"> Galactica </p>
</h1>

### Documentation
> - [Site](https://galactica.com/)
> - [X](https://x.com/GalacticaNet)
> - [Discord](https://discord.com/invite/galactica)

### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 4          | 16         | 500 GB  | 

# install dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

# install go
```
cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```

# set vars
```
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export GALACTICA_CHAIN_ID="galactica_9302-1"" >> $HOME/.bash_profile
echo "export GALACTICA_PORT="46"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
# download binary
```
cd $HOME
rm -rf galactica
git clone https://github.com/Galactica-corp/galactica
cd galactica
git checkout v0.1.2
make build
mv $HOME/galactica/build/galacticad $HOME/go/bin
```
# config and init
```
galacticad config node tcp://localhost:${GALACTICA_PORT}657
galacticad config keyring-backend os
galacticad config chain-id galactica_9302-1
galacticad init "test" --chain-id galactica_9302-1
```

# download genesis and addrbook
```
wget -O $HOME/.galactica/config/genesis.json https://testnet-files.itrocket.net/galactica/genesis.json
wget -O $HOME/.galactica/config/addrbook.json https://testnet-files.itrocket.net/galactica/addrbook.json
```
# set seeds and peers
```
SEEDS="52ccf467673f93561c9d5dd4434def32ef2cd7f3@galactica-testnet-seed.itrocket.net:46656"
PEERS="c9993c738bec6a10cfb8bb30ac4e9ae6f8286a5b@galactica-testnet-peer.itrocket.net:11656,2dd4375e2f6026916f9880f88170f0debdd22315@195.26.248.124:17656,6b846b316d704d78f3f9ca46d86cebc5a22de8ae@161.97.111.249:26656,d572caf3a63d6c730fe0a5c586fd93e70683b727@167.86.127.19:656,e926f2e20568e61646558a2b8fd4a4e46d77903f@141.95.110.124:26656,f3cd6b6ebf8376e17e630266348672517aca006a@46.4.5.45:27456,8949fb771f2859248bf8b315b6f2934107f1cf5a@168.119.241.1:26656,9990ab130eac92a2ed1c3d668e9a1c6e811e8f35@148.251.177.108:27456,dc4ed6e614725dffc41874e762a1b1ce4cdc3304@161.97.74.20:46656,c722e6dc5f762b0ef19be7f8cc8fd67cdf988946@49.12.96.14:26656,e38c22e44893e75e388f3bcea2a075124d75ccd3@89.110.89.244:26656,3afb7974589e431293a370d10f4dcdb73fa96e9b@157.90.158.222:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.galactica/config/config.toml
```

# set custom ports in app.toml
```
sed -i.bak -e "s%:1317%:${GALACTICA_PORT}317%g;
s%:8080%:${GALACTICA_PORT}080%g;
s%:9090%:${GALACTICA_PORT}090%g;
s%:9091%:${GALACTICA_PORT}091%g;
s%:8545%:${GALACTICA_PORT}545%g;
s%:8546%:${GALACTICA_PORT}546%g;
s%:6065%:${GALACTICA_PORT}065%g" $HOME/.galactica/config/app.toml
```
# set custom ports
```
sed -i.bak -e "s%:26658%:${GALACTICA_PORT}658%g;
s%:26657%:${GALACTICA_PORT}657%g;
s%:6060%:${GALACTICA_PORT}060%g;
s%:26656%:${GALACTICA_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${GALACTICA_PORT}656\"%;
s%:26660%:${GALACTICA_PORT}660%g" $HOME/.galactica/config/config.toml
```
# config pruning
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.galactica/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.galactica/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.galactica/config/app.toml
```

# set minimum gas price
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "10agnet"|g' $HOME/.galactica/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.galactica/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.galactica/config/config.toml
```
# create service file
```
sudo tee /etc/systemd/system/galacticad.service > /dev/null <<EOF
[Unit]
Description=Galactica node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.galactica
ExecStart=$(which galacticad) start --home $HOME/.galactica --chain-id galactica_9302-1
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
# Download snapshot
```
galacticad tendermint unsafe-reset-all --home $HOME/.galactica
if curl -s --head curl https://testnet-files.itrocket.net/galactica/snap_galactica.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/galactica/snap_galactica.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.galactica
    else
  echo no have snap
fi
```
# enable and start service
```
sudo systemctl daemon-reload
sudo systemctl enable galacticad
sudo systemctl restart galacticad && sudo journalctl -u galacticad -f
```

# reate a new wallet
```
galacticad keys add $WALLET
```

# Restore wallet
```
galacticad keys add $WALLET --recover
```

# save wallet and validator address
```
WALLET_ADDRESS=$(galacticad keys show $WALLET -a)
VALOPER_ADDRESS=$(galacticad keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
source $HOME/.bash_profile
```
# check sync status
```
galacticad status 2>&1 | jq 
```

# Check balance
```
galacticad query bank balances $WALLET_ADDRESS 
```

# Create validator
```
galacticad tx staking create-validator \
--amount 1000000agnet \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(galacticad tendermint show-validator) \
--moniker "test" \
--identity "" \
--website "" \
--details "Fast & Run" \
--chain-id galactica_9302-1 \
--gas 200000 --gas-prices 10agnet \
-y
```

# Delegate to Yourself
```
galacticad tx staking delegate $(galacticad keys show $WALLET --bech val -a) 1000000agnet --from $WALLET --chain-id galactica_9302-1 --gas 200000 --gas-prices 10agnet -y 
```

# Delete
```
sudo systemctl stop galacticad
sudo systemctl disable galacticad
sudo rm -rf /etc/systemd/system/galacticad.service
sudo rm $(which galacticad)
sudo rm -rf $HOME/.galactica
sed -i "/GALACTICA_/d" $HOME/.bash_profile
```
