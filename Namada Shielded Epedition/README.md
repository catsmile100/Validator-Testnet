<p align="center">
  <img height="350" height="350" src="https://github.com/catsmile100/Validator-Testnet/assets/85368621/1de34c44-77d0-4f15-aabd-2e88f87ff81c">
</p>
<h1>
<p align="center"> NAMADA SHIELDED EXPEDITION </p>
</h1>

<p align="center">
  <a href="https://namada.net">Link</a> |
  <a href="https://discord.com/invite/namada">Discord</a> |
  <a href="https://twitter.com/namada">Twitter</a> |
  <a href="https://docs.namada.net/introduction">Docs</a> |
  <a href="https://namada.net/shielded-expedition">Dashboard</a> |
  <a href="https://namada.net/blog/namada-shielded-expedition-wanted-asteroids-roids-point-system-and-rankings">Task</a> |
  <a href="https://namada.explorers.guru/validators">Explorer1</a> |
  <a href="https://namada-explorer.0xgen.online">Explorer2</a> 
</p>

### Public Services
#### Link
~~~
https://namada.catsmile.tech/
~~~

#### RPC
~~~
https://rpc-namada.catsmile.tech
~~~
#### Addrbook 
~~~
https://rpc-namada.catsmile.tech](https://files-namada.catsmile.tech/testnet/addrbook.json
~~~
####  Genesis 
~~~
https://files-namada.catsmile.tech/testnet/genesis.json
~~~
####  Seed
~~~
tcp://37.60.236.83:26657
~~~
####  Peer 
~~~
tcp://37.60.236.83:26657
~~~
####  live peers
~~~
PEERS="tcp://37.60.236.83:26657" sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.local/share/namada/shielded-expedition.88f17d1d14/config.toml
~~~
####  Snapshot
~~~
https://files-namada.catsmile.tech/testnet/namada-snapshot.tar.lz4
~~~

### Minimum Hardware 

#### Validator
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 20.04 | 4         | 16 GB	         | 1 TB   | 

#### Full Node
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 20.04 | 4        | 8 GB	         | 1 TB  | 

#### Light Node
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 20.04 | TBD        | TBD         | TBD  | 

### Manual installation
### NOTE : 1 EPOCH ESTIMATE 6-10 HOURS

~~~
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler
~~~

Install Go, if needed
~~~
cd $HOME
! [ -x "$(command -v go)" ] && {
VER="1.20.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
}
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
~~~

Replace your Validator and Wallet name
~~~
NAMADA_PORT=26
echo "export NAMADA_PORT="$NAMADA_PORT"" >> $HOME/.bash_profile
echo "export ALIAS="CHOOSE_A_NAME_FOR_YOUR_VALIDATOR"" >> $HOME/.bash_profile
echo "export MEMO="CHOOSE_YOUR_tpknam_ADDRESS"" >> $HOME/.bash_profile
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export PUBLIC_IP=$(wget -qO- eth0.me)" >> $HOME/.bash_profile
echo "export TM_HASH="v0.1.4-abciplus"" >> $HOME/.bash_profile
echo "export CHAIN_ID="shielded-expedition.88f17d1d14"" >> $HOME/.bash_profile
echo "export BASE_DIR="$HOME/.local/share/namada"" >> $HOME/.bash_profile
source $HOME/.bash_profile
~~~

Install Rust & Cargo
~~~
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
~~~

Install CometBFT
~~~
cd $HOME
rm -rf cometbft
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout v0.37.2
make build
sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/
cometbft version
~~~

Build Namada binaries
~~~
cd $HOME
rm -rf namada
git clone https://github.com/anoma/namada
cd namada
wget https://github.com/anoma/namada/releases/download/v0.31.4/namada-v0.31.4-Linux-x86_64.tar.gz
tar -xvf namada-v0.31.4-Linux-x86_64.tar.gz
rm namada-v0.31.4-Linux-x86_64.tar.gz
cd namada-v0.31.4-Linux-x86_64
sudo mv namad* /usr/local/bin/
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
fi
~~~

Check Namada version
~~~
namada --version
~~~

Join-network as Full node
~~~
namada client utils join-network --chain-id $CHAIN_ID
~~~

Create Service file
~~~
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=YOUR_LINUX_USER
WorkingDirectory=$BASE_DIR
Environment="CMT_LOG_LEVEL=p2p:none,pex:error"
Environment="NAMADA_CMT_STDOUT=true"
ExecStart=$(which namada) node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
~~~

Enable and start service
~~~
sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl restart namadad && sudo journalctl -u namadad -f
~~~

Set Port
~~~
sudo ufw default allow outgoing 
sudo ufw default deny incoming 
sudo ufw allow ssh/tcp 
sudo ufw allow 26656/tcp
sudo ufw enable
~~~

Create wallet
~~~
namadaw gen --alias $WALLET
~~~
Restore existing wallet
~~~
namadaw derive --alias $WALLET
~~~
Find your wallet address
~~~
namadaw find --alias $WALLET
~~~

Request Faucet

- Fund your wallet from [faucet1](https://faucet.housefire.luminara.icu/)
- Fund your wallet from [faucet2](https://faucet.heliax.click/)

After a couple of minutes, the check the balance

Check Balance
~~~
namadac balance --owner $WALLET
~~~
List wallet
~~~
namadaw list
~~~
Delete wallet
~~~
namadaw remove --alias $WALLET --do-it
~~~
Check Sync status
~~~
curl http://127.0.0.1:26657/status | jq 
~~~


