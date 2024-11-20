<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/b6405d54-9ea3-443f-b920-e2a717fdf499">
</p>

</h2>
<p align="center"> Zenrock </p>
<p align="center"> Zenrock is a permissionless MPC (Multi-Party Computation) infrastructure that enables decentralized key management for cross-chain protocols and wallet builders, eliminating single points of failure through distributed private keys. Through its zrSign technology, it provides developers with tools to build secure omnichain applications that can control assets across any blockchain while maintaining institutional-grade security with hot wallet convenience </p>
</h2>

<p align="center">
  <a href="https://www.zenrocklabs.io">Home</a> |
  <a href="https://discord.com/invite/zenrockfoundation">Discord</a> |
  <a href="https://x.com/OfficialZenrock">Twitter</a> |
  <a href="https://github.com/zenrocklabs/">Github</a> 
</p>

### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 8          | 64         | 1 TB  | 

### Install required packages
```
### install dependencies, if needed
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```
### Install Go
```
cd $HOME
VER="1.23.1"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```
### set vars
```
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export ZENROCK_CHAIN_ID="gardia-2"" >> $HOME/.bash_profile
echo "export ZENROCK_PORT="56"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### download binary
```
curl -o zenrockd https://releases.gardia.zenrocklabs.io/zenrockd-latest
chmod +x $HOME/zenrockd
mv $HOME/zenrockd $HOME/go/bin/
```

### config and init app
```
zenrockd init $MONIKER --chain-id $ZENROCK_CHAIN_ID
zenrockd config set client chain-id $ZENROCK_CHAIN_ID
zenrockd config set client node tcp://localhost:${ZENROCK_PORT}657
```

### download genesis and addrbook
```
wget -O $HOME/.zrchain/config/genesis.json https://server-5.itrocket.net/testnet/zenrock/genesis.json
wget -O $HOME/.zrchain/config/addrbook.json  https://server-5.itrocket.net/testnet/zenrock/addrbook.json
```

### set seeds and peers
```
SEEDS="50ef4dd630025029dde4c8e709878343ba8a27fa@zenrock-testnet-seed.itrocket.net:56656"
PEERS="5458b7a316ab673afc34404e2625f73f0376d9e4@zenrock-testnet-peer.itrocket.net:11656,87165cdb26ad60dc35de2eda0397234929a8b942@65.109.144.116:18256,3e68a389ea37f829f8e2b78170deb1993a9e112e@135.181.139.249:20656,509ff76d4c3750b1a6615266e51e474c4795b41c@37.27.126.230:60656,0332addfafcde52169b3a2784bee689775f1a9d5@95.214.53.70:18256,6ef43e8d5be8d0499b6c57eb15d3dd6dee809c1e@52.30.152.47:26656,e54acd63a6593d1861c77100b30cbdc78272bfe1@194.163.137.66:18256,995f222d9ae541e5b143ef1eb35c6499737ff203@84.247.129.215:18256,f51b87bc31b34d6e1a91d6a9b412e0a22164d26e@65.109.115.15:18256,773c4336bff45637ced68a43aeeedd2ec0762d29@167.172.109.30:26656,956edc3da80d4f858fd9dbce3651d369b3deb7d6@157.173.196.60:18256,637077d431f618181597706810a65c826524fd74@176.9.120.85:29556,63f0bb65cfc5f6b22795e657c7d9db69a4a85b16@89.58.61.137:18256,137b929413201c793910b351a6f38586d1efefd1@160.25.233.228:18256,01e97f00f48a917dc45853ce131125e39bf3db94@147.124.222.42:18256,f8f231e231fbd9547f6af74caaeef8cd9e68b2db@158.220.96.82:56656,e0b3dca981c062de699402ce56f56b6adea6a286@194.163.178.114:13656,10100d10c3bbbbfc4bd9c607b24802657cbd5709@69.67.150.107:56656,f1ded278bfb659857a67493422bc2a08bc7e61f9@45.159.228.23:56656,6ab0fb1b2d1df2e6aa0a1efe171a1e27e4d79188@65.108.199.62:56656,679e513d8f9734018d6019da66c54e19971ff1c3@65.109.22.211:26656,793a1e7cf62a269844e59e3af73e92ae6e2ad4a6@65.109.80.26:26656,35d331a3d7140323f00e75482d9f50b65425d365@188.166.50.186:56656,025a4537bfeeac4a08061f89cceb0ddeecc8d209@46.38.232.181:18256,b7364a035c67ece18398e8887f876502821a7e4d@152.53.65.185:18256,9916279a88d61e2651ea659ff58b213aa323ea76@195.3.223.119:39656,b2fcfb25245b7052b9e9d937ad064b422c9bac67@[2a0e:dc0:2:2f71::1]:14156,37fe5ec62a2f9291b7d6793e6d185651a6979a13@207.244.239.154:18256,4b93920f1827ddc102c2aa46c1fb2e15ad60de2b@88.209.197.222:18256,f88ab213529551805636ca0d8b103e953e3717f3@152.53.34.201:18256,431bbfb4b7cc3432aeea7a41779364fbeee6c057@5.252.227.86:18256,15928f383262b3fc9e4e640ac2da7a3840e18b78@152.53.66.190:18256,39bf4210b1e47b9df1de0d30a6ab94e18b7c4e9f@[2a03:cfc0:8000:13::b910:277f]:14156,ff3a2623fa1cd2eb8133715b6a143bede814f453@152.53.65.180:18256,41055f2e31cb2a15a1d33403c736f24e28acd021@152.53.0.33:18256,b8a72a8896fc131349fa59dfa9f6527e1c44a1a5@89.117.61.98:56656,d882a9e1d602bb4090575b69e6f04d913b5e8d78@65.109.84.235:57656,a46347993cf0ebd44877b865dfc0f1024c0181ac@109.205.181.193:56656,0ef0644a4f23037f3226d700c500620e8203b77f@94.72.114.43:18256,436d0f1b24e4231774b35e8bd924f6de9728007a@158.160.2.235:26656,20643744e926aa2b0b3a5e84c33bd3abe15673db@185.184.68.35:18256,ff8476546e30596fb92aab5edac1effa822c1c52@212.47.66.218:18256"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.zrchain/config/config.toml
```

### set custom ports in app.toml
```
sed -i.bak -e "s%:1317%:${ZENROCK_PORT}317%g;
s%:8080%:${ZENROCK_PORT}080%g;
s%:9090%:${ZENROCK_PORT}090%g;
s%:9091%:${ZENROCK_PORT}091%g;
s%:8545%:${ZENROCK_PORT}545%g;
s%:8546%:${ZENROCK_PORT}546%g;
s%:6065%:${ZENROCK_PORT}065%g" $HOME/.zrchain/config/app.toml
```
### set custom ports in config.toml file
```
sed -i.bak -e "s%:26658%:${ZENROCK_PORT}658%g;
s%:26657%:${ZENROCK_PORT}657%g;
s%:6060%:${ZENROCK_PORT}060%g;
s%:26656%:${ZENROCK_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${ZENROCK_PORT}656\"%;
s%:26660%:${ZENROCK_PORT}660%g" $HOME/.zrchain/config/config.toml
```
### config pruning
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.zrchain/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.zrchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.zrchain/config/app.toml
```
### set minimum gas price, enable prometheus and disable indexing
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0urock"|g' $HOME/.zrchain/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.zrchain/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.zrchain/config/config.toml
```
### create service file
```
sudo tee /etc/systemd/system/zenrockd.service > /dev/null <<EOF
[Unit]
Description=Zenrock node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.zrchain
ExecStart=$(which zenrockd) start --home $HOME/.zrchain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
### reset and download snapshot
```
zenrockd tendermint unsafe-reset-all --home $HOME/.zrchain
if curl -s --head curl https://server-5.itrocket.net/testnet/zenrock/zenrock_2024-11-20_1022715_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-5.itrocket.net/testnet/zenrock/zenrock_2024-11-20_1022715_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.zrchain
    else
  echo "no snapshot found"
fi
```
### enable and start service
```
sudo systemctl daemon-reload
sudo systemctl enable zenrockd
sudo systemctl restart zenrockd && sudo journalctl -u zenrockd -f
```
### Create wallet
```
zenrockd keys add $WALLET
```
```
zenrockd keys add $WALLET --recover
```

### Create validator
```
cd $HOME
### Create validator.json file
echo "{\"pubkey\":{\"@type\":\"/cosmos.crypto.ed25519.PubKey\",\"key\":\"$(zenrockd comet show-validator | grep -Po '\"key\":\s*\"\K[^"]*')\"},
    \"amount\": \"1000000urock\",
    \"moniker\": \"test\",
    \"identity\": \"\",
    \"website\": \"\",
    \"security\": \"\",
    \"details\": \"I love blockchain ❤️\",
    \"commission-rate\": \"0.1\",
    \"commission-max-rate\": \"0.2\",
    \"commission-max-change-rate\": \"0.01\",
    \"min-self-delegation\": \"1\"
}" > validator.json
### Create a validator using the JSON configuration
zenrockd tx staking create-validator validator.json \
    --from $WALLET \
    --chain-id gardia-2 \
	--fees 30urock	
```

### Check balance
```
zenrockd query bank balances $WALLET_ADDRESS
```

### Delegate to Yourself
```
zenrockd tx staking delegate $(zenrockd keys show $WALLET --bech val -a) 1000000urock --from $WALLET --chain-id gardia-2 --fees 30urock -y 
```

### Delete node
```
sudo systemctl stop zenrockd
sudo systemctl disable zenrockd
sudo rm -rf /etc/systemd/system/zenrockd.service
sudo rm $(which zenrockd)
sudo rm -rf $HOME/.zrchain
sed -i "/ZENROCK_/d" $HOME/.bash_profile
```
