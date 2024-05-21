<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1604751287618113536/ayyW6i94_400x400.jpg">
</p>
<h1>
<p align="center"> Initia </p>
</h1>

### Documentation
> - [Site](https://initia.xyz/)
> - [X](https://x.com/initiaFDN)
> - [Discord](https://discord.com/invite/initia)

### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 4          | 16         | 1 TB  | 

# install dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```
# install go, if needed
```
cd $HOME
VER="1.22.2"
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
echo "export INITIA_CHAIN_ID="initiation-1"" >> $HOME/.bash_profile
echo "export INITIA_PORT="51"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# download binary
```
cd $HOME
rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.14
make install
```
# config and init app
```
initiad init $MONIKER
initiad config set client chain-id initiation-1
initiad config set client node tcp://localhost:${INITIA_PORT}657
sed -i -e "s|^node *=.*|node = \"tcp://localhost:${INITIA_PORT}657\"|" $HOME/.initia/config/client.toml
```
# download genesis and addrbook
```
wget -O $HOME/.initia/config/genesis.json https://testnet-files.itrocket.net/initia/genesis.json
wget -O $HOME/.initia/config/addrbook.json https://testnet-files.itrocket.net/initia/addrbook.json
```

# set seeds and peers
```
SEEDS="cd69bcb00a6ecc1ba2b4a3465de4d4dd3e0a3db1@initia-testnet-seed.itrocket.net:51656"
PEERS="aee7083ab11910ba3f1b8126d1b3728f13f54943@initia-testnet-peer.itrocket.net:11656,a8f3e2d4197b34c11228809d0f785a952905b262@43.131.12.180:26656,9c0417a610846b3a7fd27ac3afbf3b52b527807c@43.157.82.7:26656,3eddd5b0180cd365d9ced92113fcfc6a734a12f6@194.146.13.37:51656,1d7d2d2cdb62df2a59aae536047d17f554e58bc3@154.38.181.13:656,7317b8c930c52a8183590166a7b5c3599f40d4db@185.187.170.186:26656,35e4b461b38107751450af25e03f5a61e7aa0189@43.133.229.136:26656,6a64518146b8c902ef5930dfba00fe61a15ec176@43.133.44.152:26656,a45314423c15f024ff850fad7bd031168d937931@162.62.219.188:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.initia/config/config.toml
```
# set custom ports in app.toml
```
sed -i.bak -e "s%:1317%:${INITIA_PORT}317%g;
s%:8080%:${INITIA_PORT}080%g;
s%:9090%:${INITIA_PORT}090%g;
s%:9091%:${INITIA_PORT}091%g;
s%:8545%:${INITIA_PORT}545%g;
s%:8546%:${INITIA_PORT}546%g;
s%:6065%:${INITIA_PORT}065%g" $HOME/.initia/config/app.toml
```

# set custom ports
```
sed -i.bak -e "s%:26658%:${INITIA_PORT}658%g;
s%:26657%:${INITIA_PORT}657%g;
s%:6060%:${INITIA_PORT}060%g;
s%:26656%:${INITIA_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${INITIA_PORT}656\"%;
s%:26660%:${INITIA_PORT}660%g" $HOME/.initia/config/config.toml
```
# config pruning
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.initia/config/app.toml
```
# set minimum gas price
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.initia/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml
```
# create service file
```
sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
[Unit]
Description=Initia node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.initia
ExecStart=$(which initiad) start --home $HOME/.initia
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
# reset and download snapshot
```
initiad tendermint unsafe-reset-all --home $HOME/.initia
if curl -s --head curl https://testnet-files.itrocket.net/initia/snap_initia.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/initia/snap_initia.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.initia
    else
  echo no have snap
fi
```
# enable and start service
```
sudo systemctl daemon-reload
sudo systemctl enable initiad
sudo systemctl restart initiad && sudo journalctl -u initiad -f
```

# Create a new wallet
```
initiad keys add $WALLET
```
# Restore 
```
initiad keys add $WALLET --recover
```
# save wallet and validator address
```
WALLET_ADDRESS=$(initiad keys show $WALLET -a)
VALOPER_ADDRESS=$(initiad keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
source $HOME/.bash_profile
```
# check sync status
```
initiad status 2>&1 | jq 
```
# Check balance
```
initiad query bank balances $WALLET_ADDRESS 
```
# Create validator
```
initiad tx staking create-validator \
--amount 1000000uinit \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(initiad tendermint show-validator) \
--moniker "test" \
--identity "" \
--website "" \
--details "Fast & Run" \
--chain-id initiation-1 \
--gas auto --fees 80000uinit \
-y
```
# Delegate to Yourself
```
initiad tx staking delegate $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y 
```
# Delete node
```
sudo systemctl stop initiad
sudo systemctl disable initiad
sudo rm -rf /etc/systemd/system/initiad.service
sudo rm $(which initiad)
sudo rm -rf $HOME/.initia
sed -i "/INITIA_/d" $HOME/.bash_profile
```
