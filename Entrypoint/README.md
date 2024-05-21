<p align="center">
  <img height="350" height="350" src="https://github.com/catsmile100/Validator-Testnet/assets/85368621/7e151689-7730-4d07-9a03-2de5e03a913d">

</p>
<h1>
<p align="center"> Entrypoint </p>
</h1>

### Documentation
> - [Site](https://entrypoint.zone)
> - [X](https://twitter.com/entrypointzone)
> - [Discord](https://discord.com/invite/6Ec9jDwVnB)
> - [Explorer](https://testnet.itrocket.net/entrypoint/staking)

### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 4          | 8         | 400 GB  | 


### Install Dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

### Install GO
```
cd $HOME
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```

### Set Vars
```
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export ENTRY_CHAIN_ID="entrypoint-pubtest-2"" >> $HOME/.bash_profile
echo "export ENTRY_PORT="34"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Download Binary
```
cd $HOME
mkdir -p $HOME/entrypoint && cd entrypoint
wget -O entrypointd https://github.com/entrypoint-zone/testnets/releases/download/v1.3.0/entrypointd-1.3.0-linux-amd64
chmod +x entrypointd
cp entrypointd $HOME/go/bin/entrypointd
```

### Config and init app
```
entrypointd config node tcp://localhost:${ENTRY_PORT}657
entrypointd config keyring-backend os
entrypointd config chain-id entrypoint-pubtest-2
entrypointd init "test" --chain-id entrypoint-pubtest-2
```
### Download Genesis and addrbook
```
wget -O $HOME/.entrypoint/config/genesis.json https://testnet-files.itrocket.net/entrypoint/genesis.json
wget -O $HOME/.entrypoint/config/addrbook.json https://testnet-files.itrocket.net/entrypoint/addrbook.json
```
### Set seeds and peers
```
SEEDS="e1b2eddac829b1006eb6e2ddbfc9199f212e505f@entrypoint-testnet-seed.itrocket.net:34656"
PEERS="7048ee28300ffa81103cd24b2af3d1af0c378def@entrypoint-testnet-peer.itrocket.net:34656,05419a6f8cc137c4bb2d717ed6c33590aaae022d@213.133.100.172:26878,f7af71e7f32516f005192b21f1a83ca3f4fef4da@142.132.202.92:32256,b91b03c8e7089c265b14dba36c5a61da6ea40f4c@37.120.191.47:61056,c9168142f4989fcd96bbc52b9493b3089fa8862c@65.109.49.56:34656,d201ee4ab3390b09f088a0e04c4e45219f3e9deb@146.19.24.175:26756,75e83d67504cbfacdc79da55ca46e2c4353816e7@65.109.92.241:3106,6e38397e09a2755841e2f350ba1ff8883a66551a@[2a01:4f9:4a:2864::2]:11556,c23442b197a2408a8c6e383e989b4a11343009db@176.9.110.12:60856,615481f262ab5862580e6e2c6aeb03a7af75f18c@45.67.216.220:12956,7e7159e60b26508ad7b592605a79489f6c6281a0@194.163.179.176:36156"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.entrypoint/config/config.toml
```

### Set custom ports in app.toml
```
sed -i.bak -e "s%:1317%:${ENTRY_PORT}317%g;
s%:8080%:${ENTRY_PORT}080%g;
s%:9090%:${ENTRY_PORT}090%g;
s%:9091%:${ENTRY_PORT}091%g;
s%:8545%:${ENTRY_PORT}545%g;
s%:8546%:${ENTRY_PORT}546%g;
s%:6065%:${ENTRY_PORT}065%g" $HOME/.entrypoint/config/app.toml
```

### Set custom ports in config.toml file
```
sed -i.bak -e "s%:26658%:${ENTRY_PORT}658%g;
s%:26657%:${ENTRY_PORT}657%g;
s%:6060%:${ENTRY_PORT}060%g;
s%:26656%:${ENTRY_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${ENTRY_PORT}656\"%;
s%:26660%:${ENTRY_PORT}660%g" $HOME/.entrypoint/config/config.toml
```
### Config pruning
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.entrypoint/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.entrypoint/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.entrypoint/config/app.toml
```
### Set minimum gas price, enable prometheus and disable indexing
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.01ibc/8A138BC76D0FB2665F8937EC2BF01B9F6A714F6127221A0E155106A45E09BCC5"|g' $HOME/.entrypoint/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.entrypoint/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.entrypoint/config/config.toml
```
### Create service file
```
sudo tee /etc/systemd/system/entrypointd.service > /dev/null <<EOF
[Unit]
Description=Entrypoint node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.entrypoint
ExecStart=$(which entrypointd) start --home $HOME/.entrypoint
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
### Reset and download snapshot
```
entrypointd tendermint unsafe-reset-all --home $HOME/.entrypoint
if curl -s --head curl https://testnet-files.itrocket.net/entrypoint/snap_entrypoint.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/entrypoint/snap_entrypoint.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.entrypoint
    else
  echo no have snap
fi
```
### Enable and start service
```
sudo systemctl daemon-reload
sudo systemctl enable entrypointd
sudo systemctl restart entrypointd && sudo journalctl -u entrypointd -f
```
### Create a new wallet
```
entrypointd keys add $WALLET
```
### Restore wallet
```
entrypointd keys add $WALLET --recover
```
### Save wallet and validator address
```
WALLET_ADDRESS=$(entrypointd keys show $WALLET -a)
VALOPER_ADDRESS=$(entrypointd keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Create Validator
```
entrypointd tx staking create-validator \
--amount 1000000uentry \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(entrypointd tendermint show-validator) \
--moniker "$MONIKER" \
--identity "" \
--details "I love blockchain ❤️" \
--chain-id entrypoint-pubtest-2 \
--gas auto --gas-adjustment 1.4 --gas-prices 0.01ibc/8A138BC76D0FB2665F8937EC2BF01B9F6A714F6127221A0E155106A45E09BCC5 \
-y
```
### Edit Validator
```
entrypointd tx staking edit-validator \
--commission-rate 0.1 \
--new-moniker "$MONIKER" \
--identity "" \
--details "I love blockchain ❤️" \
--from $WALLET \
--chain-id entrypoint-pubtest-2 \
--gas auto --gas-adjustment 1.4 --gas-prices 0.01ibc/8A138BC76D0FB2665F8937EC2BF01B9F6A714F6127221A0E155106A45E09BCC5 \
-y
```

### Unjail Validator
```
entrypointd tx slashing unjail --from $WALLET --chain-id entrypoint-pubtest-2 --gas auto --gas-adjustment 1.4 --gas-prices 0.01ibc/8A138BC76D0FB2665F8937EC2BF01B9F6A714F6127221A0E155106A45E09BCC5 -y
```
### Vote
```
entrypointd tx gov vote 1 yes --from $WALLET --chain-id entrypoint-pubtest-2  --gas auto --gas-adjustment 1.4 --gas-prices 0.01ibc/8A138BC76D0FB2665F8937EC2BF01B9F6A714F6127221A0E155106A45E09BCC5 -y
```

### Cheat-Sheet
```
sudo journalctl -u entrypointd -f
```
```
sudo systemctl status entrypointd
```
```
entrypointd status 2>&1 | jq .SyncInfo
```
```
sudo systemctl start entrypointd
```
```
sudo systemctl daemon-reload
```
```
entrypointd status 2>&1 | jq .NodeInfo
```
```
sudo systemctl stop entrypointd
```
```
sudo systemctl enable entrypointd
```
```
sudo systemctl restart entrypointd
```
```
sudo systemctl disable entrypointd
```
```
entrypointd keys list
```
```
entrypointd query bank balances $WALLET_ADDRESS
```

### Delete 
```
sudo systemctl stop entrypointd
sudo systemctl disable entrypointd
sudo rm -rf /etc/systemd/system/entrypointd.service
sudo rm $(which entrypointd)
sudo rm -rf $HOME/.entrypoint
sed -i "/ENTRY_/d" $HOME/.bash_profile
```
