<p align="center">
  <img height="350" height="350" src="https://bafkreid6e5xvw5cjhm2vag5kfpg7hjb6vyhp427xsrujqn7uolrx6e4ley.ipfs.nftstorage.link">
</p>

<h1>
<p align="center"> Empeiria </p>
</h1>

<p align="center">
  <a href="https://empe.io/">Official</a> |
  <a href="https://t.me/web3Empeiria">Telegram</a> |
  <a href="https://x.com/empe_io">Twitter</a> |

</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Empe | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

## Installation
1. **Install**
	```
cd $HOME
VER="1.22.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# set vars
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export EMPED_CHAIN_ID="empe-testnet-2"" >> $HOME/.bash_profile
echo "export EMPED_PORT="28"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# download binary
cd $HOME
rm -rf bin
mkdir bin
cd $HOME/bin
curl -LO https://github.com/empe-io/empe-chain-releases/raw/master/v0.2.2/emped_v0.2.2_linux_amd64.tar.gz
tar -xvf emped_v0.2.2_linux_amd64.tar.gz
chmod +x $HOME/bin/emped
mv $HOME/bin/emped ~/go/bin

# config and init app
emped config node tcp://localhost:${EMPED_PORT}657
emped config keyring-backend os
emped config chain-id empe-testnet-2
emped init "test" --chain-id empe-testnet-2

# download genesis and addrbook
wget -O $HOME/.empe-chain/config/genesis.json https://server-5.itrocket.net/testnet/empeiria/genesis.json
wget -O $HOME/.empe-chain/config/addrbook.json  https://server-5.itrocket.net/testnet/empeiria/addrbook.json

# set seeds and peers
SEEDS="20ca5fc4882e6f975ad02d106da8af9c4a5ac6de@empeiria-testnet-seed.itrocket.net:28656"
PEERS="03aa072f917ed1b79a14ea2cc660bc3bac787e82@empeiria-testnet-peer.itrocket.net:28656,a9cf0ffdef421d1f4f4a3e1573800f4ee6529773@136.243.13.36:29056,cbe1bfc8ee1a15a5e32ba85e0944d17812b5b244@65.21.67.40:34656,78f766310a83b6670023169b93f01d140566db79@65.109.83.40:29056,fb0a0beeb42902053b526e0f2dd572305d89a26c@65.109.84.22:26656,e62b549646fee135cf010bc10641f728aba7fbd0@65.108.234.158:26626,2987c6802f3a227f2e423ec4548ae4f1a96cba9e@116.203.94.181:26656,4cb79afab8ff3912518af0fe630575cbad6c798e@95.217.61.32:7756,e058f20874c7ddf7d8dc8a6200ff6c7ee66098ba@65.109.93.124:29056,45bdc8628385d34afc271206ac629b07675cd614@65.21.202.124:25656,2db322b41d26559476f929fda51bce06c3db8ba4@65.109.24.155:11256,66ac611ba87753e92f1e5d792a2b19d4c5080f32@188.40.73.112:22656,1a260d047dc84b3f2b13d1b6a9f4c6295a2110f5@135.181.136.105:11156"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.empe-chain/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${EMPED_PORT}317%g;
s%:8080%:${EMPED_PORT}080%g;
s%:9090%:${EMPED_PORT}090%g;
s%:9091%:${EMPED_PORT}091%g;
s%:8545%:${EMPED_PORT}545%g;
s%:8546%:${EMPED_PORT}546%g;
s%:6065%:${EMPED_PORT}065%g" $HOME/.empe-chain/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${EMPED_PORT}658%g;
s%:26657%:${EMPED_PORT}657%g;
s%:6060%:${EMPED_PORT}060%g;
s%:26656%:${EMPED_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${EMPED_PORT}656\"%;
s%:26660%:${EMPED_PORT}660%g" $HOME/.empe-chain/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.empe-chain/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.empe-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.empe-chain/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0001uempe"|g' $HOME/.empe-chain/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.empe-chain/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.empe-chain/config/config.toml

# create service file
sudo tee /etc/systemd/system/emped.service > /dev/null <<EOF
[Unit]
Description=Empeiria node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.empe-chain
ExecStart=$(which emped) start --home $HOME/.empe-chain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset and download snapshot
emped tendermint unsafe-reset-all --home $HOME/.empe-chain
if curl -s --head curl https://server-5.itrocket.net/testnet/empeiria/empeiria_2024-11-19_2356187_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-5.itrocket.net/testnet/empeiria/empeiria_2024-11-19_2356187_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.empe-chain
    else
  echo "no snapshot found"
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable emped
sudo systemctl restart emped && sudo journalctl -u emped -f
	```
2. **Check Status**
	```
	sudo systemctl status tangle
	```
3. **Restart**
	```
	sudo systemctl restart tangle
	```
4. **Check Logs**
	```
	sudo journalctl -u tangle -f -o cat
	```
5. **Check node:**
	```
	https://telemetry.polkadot.io/#list/0x3d22af97d919611e03bbcbda96f65988758865423e89b2d99547a6bb61452db3
	```
<p align="center">
  <img height="350" height="350" src="https://bafkreiebgluunvrgjdsni5f7garf4ubxferobpa7nd2jdtosa4rhloy3su.ipfs.nftstorage.link">
</p>

6. **Create Wallet**
	```
	https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Ftestnet-rpc.tangle.tools#/staking
	```
7. **Requeest Faucet**
	- In DisCord `#🚰-faucet`

8. **Get Key Validator**
	```
	curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9933
	```
	- {"jsonrpc":"2.0","result":`HERE COPY`,"id":1} 
9. **Setting Validator**
	```
	https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Ftestnet-rpc.tangle.tools#/staking
	```
<p align="center">
  <img height="350" height="350" src="https://bafkreiazpvq3rnz7bnx547dknweeqmnjpv76lbzxz6mqozl7op37dik5be.ipfs.nftstorage.link/">
</p>

<p align="center">
  <img height="350" height="350" src="https://bafkreier6u2mmc2cmhsgd6otjvpxkzd2c7alghapwmmwz6dut53sgu5iem.ipfs.nftstorage.link/">
</p>
	
10. **Backup**
	- Save folder: `/root/.tangle/data/chains/tangle-standalone-testnet/keystore/`
	- Save file: `/root/.tangle/node-key`

11. **Monitor Dashboard**
	- https://leaderboard.tangle.tools/
<p align="center">
  <img height="350" height="350" src="https://bafkreiaws7yodavdznc3szyykdw4rmywvu6y6gxintsnkekvkufxy42hha.ipfs.nftstorage.link/">
</p>

12. **Delete**
	```
	systemctl stop tangle
	systemctl disable tangle 
	rm /etc/systemd/system/tangle.service 
	systemctl daemon-reload 
	cd 
	rm -r .tangle
	```
