<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1775529113102561281/y4D30_VO_400x400.jpg">
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
  <a href="https://namada-explorer.0xgen.online">Explorer2</a> |
  <a href="https://faucet.heliax.click">Faucet</a>
</p>

### Public Services
#### Official
~~~
https://namada.catsmile.tech
~~~
#### RPC `crew`
~~~
https://rpc-namada.catsmile.tech
~~~
#### Indexer `crew`
~~~
https://namada-indexer.catsmile.tech/block/last
~~~
#### Addrbook 
~~~
wget -O $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/config/addrbook.json https://files-namada.catsmile.tech/testnet/addrbook.json
~~~
####  Genesis 
~~~
wget -O $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/config/genesis.json https://files-namada.catsmile.tech/testnet/genesis.json
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
####  Validator Address
~~~
VALIDATOR_ADDRESS="tnam1q8g740srs0s29vqus9elppzaadey3yhung6xakul" # catsmile
~~~
`address of validator you want to stake to tnam1q8g740srs0s29vqus9elppzaadey3yhung6xakul`
####  Alias
~~~
catsmile
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

### Manual installation
~~~
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler jq
~~~

Install Go
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
NAMADA_PORT=30
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

### Wallet Operation
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

- Request1 [faucet1](https://faucet.housefire.luminara.icu/)
- Request2 [faucet2](https://faucet.heliax.click/)

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
send payment from one address to another
~~~
namadac transfer --source $WALLET --target ${WALLET}1 --token NAAN --amount 1 --signing-keys $WALLET --memo $MEMO
~~~
Check Sync status
~~~
curl http://127.0.0.1:26657/status | jq 
~~~

### Validator
Initiate a validator
~~~
namadac init-validator \
		--commission-rate 0.07 \
		--max-commission-rate-change 1 \
		--signing-keys $WALLET \
		--alias $ALIAS \
		--email <EMAIL_ADDRESS> \
		--website <WEBSITE> \ 
		--discord-handle <DISCORD> \
		--account-keys $WALLET \
		--memo $MEMO
~~~
Find your validator address
~~~
namadaw list | grep -A 1 ""$ALIAS"" | grep "Established"
~~~
Replace your Validator address, save and import variables into system
~~~
VALIDATOR_ADDRESS=$(namadaw list | grep -A 1 "\"$ALIAS\"" | grep "Established" | awk '{print $3}') 
echo "export VALIDATOR_ADDRESS="$VALIDATOR_ADDRESS"" >> $HOME/.bash_profile 
source $HOME/.bash_profile
~~~
Restart the node and wait for 2 epochs
~~~
sudo systemctl restart namadad && sudo journalctl -u namadad -f
~~~
Check epoch
~~~
namada client epoch
~~~
Delegate tokens
~~~
namadac bond --validator $ALIAS --source $WALLET --amount 1000 --memo $MEMO
~~~
Wait for 3 epochs and check validator is in the consensus set
~~~
namadac validator-state --validator $ALIAS
~~~
Check your validator bond status
~~~
namada client bonds --owner $WALLET
~~~
Find your validator status
~~~
namada client validator-state --validator $VALIDATOR_ADDRESS
~~~
### Stake
add a variable with the validator address:
~~~
VALIDATOR_ADDRESS="tnam1q8g740srs0s29vqus9elppzaadey3yhung6xakul" # catsmile
~~~
export the variable:
~~~
echo "export VALIDATOR_ADDRESS="$VALIDATOR_ADDRESS"" >> $HOME/.bash_profile \
source $HOME/.bash_profile
~~~
delegate tokens
~~~
namadac bond --source $WALLET --validator VALIDATOR_ADDRESS --amount 500 --memo $MEMO
~~~
check your user bonds
~~~
namadac bonds --owner $WALLET 
~~~
check all bonded nodes
~~~
namadac bonded-stake 
~~~
Add stake `crew`
~~~
namadac bond --source $WALLET --validator $VALIDATOR_ADDRESS --amount 1000
~~~
Query the set of validators
~~~
namadac bonded-stake
~~~
Unbond the tokens
~~~
namadac unbond --source $WALLET --validator $VALIDATOR_ADDRESS --amount 1000
~~~
Wait for 6 epochs, then check when the unbonded tokens can be withdrawed
~~~
namadac bonds --owner $WALLET
~~~
Withdraw the unbonded tokens
~~~
namadac withdraw --source $WALLET --validator $VALIDATOR_ADDRESS --memo $MEMO
~~~
redelegate
~~~
namadac redelegate --owner $WALLET --source-validator $VAL_ADDRESS --destination-validator <destination-validator-address> --amount 10 --memo $MEMO
~~~
claim rewards `crew`
~~~
namadac claim-rewards --source $WALLET --validator $VAL_ADDRESS --memo $MEMO 
~~~
query the pending reward tokens without claiming
~~~
namadac rewards --source $WALLET --validator $VAL_ADDRESS 
~~~

### Multisign

generate key_1
~~~
namadaw gen --alias $WALLET
~~~
generate key_2
~~~
namadaw gen --alias ${WALLET}1
~~~
chech your public key
~~~
namadaw find --alias $WALLET | awk '/Public key:/ {print $3}'
~~~
init non-multisig account (single signer)
~~~
namadac init-account --alias ${WALLET}-multisig --public-keys $WALLET --signing-keys $WALLET --memo $MEMO
~~~
init multisig account (at least 2 signers)
~~~
namadac init-account --alias ${WALLET}1-multisig --public-keys $WALLET,${WALLET}1 --signing-keys $WALLET,${WALLET}1 --threshold 2 --memo $MEMO
~~~
create a folder for a transaction
~~~
mkdir tx_dumps
~~~
create transaction
~~~
namadac transfer --source ${WALLET}1-multisig --target ${WALLET}1 --token NAAN --amount 10 --signing-keys $WALLET,${WALLET}1 --dump-tx --output-folder-path tx_dumps --memo $MEMO
~~~
sign the transaction
~~~
namadac sign-tx --tx-path "<path-to-.tx-file>" --signing-keys $WALLET,${WALLET}1 --owner ${WALLET}1-multisig --memo $MEMO
~~~
save as a variable offline_signature 1
~~~
export SIGNATURE_ONE="<signature-file-name>"
~~~
save as a variable offline_signature 2:
~~~
export SIGNATURE_TWO="<signature-2-file-name>"
~~~
submit transaction
~~~
namadac tx --tx-path "<path-to-.tx-file>" --signatures $SIGNATURE_ONE,$SIGNATURE_TWO --owner ${WALLET}1-multisig --gas-payer $WALLET --memo $MEMO
~~~
changing the multisig threshold
~~~
namadac update-account --address ${WALLET}1-multisig --threshold 1 --signing-keys $WALLET,${WALLET}1 --memo $MEMO
~~~
check that the threshold has been updated correctly by running
~~~
namadac query-account --owner ${WALLET}1-multisig
~~~
changing the public keys of a multisig account
~~~
namadac update-account --address ${WALLET}1-multisig --public-keys ${WALLET}2,${WALLET}3,${WALLET}4 --signing-keys $WALLET,${WALLET}1 --memo $MEMO
~~~
initialize an established account
~~~
namadac init-account --alias ${WALLET}1-multisig --public-keys ${WALLET}2,${WALLET}3,${WALLET}4  --signing-keys $WALLET,${WALLET}1  --threshold 1 --memo $MEMO
~~~

### MASP

randomly generate a new spending key
~~~
namadaw gen --shielded --alias ${WALLET}-shielded
~~~
create a new payment address
~~~
namadaw gen-payment-addr --key ${WALLET}-shielded --alias ${WALLET}-shielded-addr
~~~
send a shielding transfer `crew`
~~~
namadac transfer --source $WALLET --target ${WALLET}-shielded-addr --token NAAN --amount 10 --memo $MEMO
~~~
view balance
~~~
namadac balance --owner ${WALLET}-shielded
~~~
generate another spending key
~~~
namadaw gen --shielded --alias ${WALLET}1-shielded
~~~
create a payment address
~~~
namadaw gen-payment-addr --key ${WALLET}1-shielded --alias ${WALLET}1-shielded-addr
~~~
shielded transfers (once the user has a shielded balance, it can be transferred to another shielded address) `crew`
~~~
namadac transfer  --source ${WALLET}-shielded --target ${WALLET}1-shielded-addr --token NAAN --amount 4 --signing-keys <your-implicit-account-alias> --memo $MEMO
~~~
unshielding transfers (from a shielded to a transparent account) `crew`
~~~
namadac transfer --source ${WALLET}-shielded --target $WALLET --token NAAN --amount 4 --signing-keys <your-implicit-account-alias> --memo $MEMO
~~~
IBC shielded transfers `crew`
~~~
namadac ibc-transfer --amount xxxx --source $WALLET --receiver <Wallet Chain IBC> --token naan --channel-id <channel-ChainIBC> --memo $MEMO
~~~
### Validator operations

check sync status and node info
~~~
curl http://127.0.0.1:26657/status | jq
~~~
check balance
~~~
namadac balance --owner $ALIAS
~~~
check keys
~~~
namadaw list
~~~
find your validator address
~~~
namadac find-validator --tm-address=$(curl -s localhost:26657/status | jq -r .result.validator_info.address) --node localhost:26657
~~~
stake funds
~~~
namadac bond --source $WALLET --validator $VALIDATOR_ADDRESS --amount 10 --memo $MEMO
~~~
self-bonding
~~~
namadac bond --validator $VALIDATOR_ADDRESS --amount 10 --memo $MEMO
~~~
check your validator bond status
~~~
namadac bonds --owner $ALIAS
~~~
check your user bonds
~~~
namadac bonds --owner $WALLET
~~~
check all bonded nodes
~~~
namadac bonded-stake
~~~
find all the slashes
~~~
namadac slashes
~~~
non-self unbonding (validator alias can be used instead of address)
~~~
namadac unbond --source $WALLET --validator $VALIDATOR_ADDRESS --amount 1.5 --memo $MEMO
~~~
self-unbonding
~~~
namadac unbond --validator $VALIDATOR_ADDRESS --amount 1.5 --memo $MEMO
~~~
withdrawing unbonded tokens (available 6 epochs after unbonding)
~~~
namadac withdraw --source $WALLET --validator $VALIDATOR_ADDRESS --memo $MEMO
~~~
find your validator status
~~~
namadac validator-state --validator $VALIDATOR_ADDRESS
~~~
check epoch
~~~
namada client epoch
~~~
unjail, you need to wait 2 epochs
~~~
namada client unjail-validator --validator $VALIDATOR_ADDRESS --node tcp://127.0.0.1:26657 --memo $MEMO
~~~
change validator commission rate
~~~
namadac change-commission-rate --validator $VALIDATOR_ADDRESS --commission-rate <commission-rate> --memo $MEMO
~~~
change validator metadata
~~~
namadac change-metadata --validator $VALIDATOR_ADDRESS --memo $MEMO
~~~
deactivate validator
~~~
namadac deactivate-validator --validator $VALIDATOR_ADDRESS --memo $MEMO
~~~
reactivate validator
~~~
namadac reactivate-validator --validator $VALIDATOR_ADDRESS --memo $MEMO
~~~

### Governance
all proposals list
~~~
namadac query-proposal
~~~
edit proposal
~~~
namadac query-proposal --proposal-id <PROPOSAL_ID>
~~~
save wallet address
~~~
WALLET_ADDRESS=$(namadaw find --alias $WALLET | grep "Implicit" | awk '{print $3}')
~~~
import the variable into system
~~~
echo "export WALLET_ADDRESS="$WALLET_ADDRESS"" >> $HOME/.bash_profile source $HOME/.bash_profile
~~~
vote
~~~
namadac vote-proposal --proposal-id <proposal-id> --vote yay --address $WALLET_ADDRESS --memo $MEMO
~~~
vote for PGF proposal
~~~
namadac vote-proposal --proposal-id <proposal-id-of-steward-proposal> --vote yay --signing-keys $WALLET --memo $MEMO
~~~

### Consensus
check logs
~~~
sudo journalctl -u namadad -f
~~~
check sync status and node info
~~~
curl http://127.0.0.1:26657/status | jq
~~~
check consensus state
~~~
curl -s localhost:26657/consensus_state | jq .result.round_state.height_vote_set[0].prevotes_bit_array
~~~
full consensus state
~~~
curl -s localhost:12657/dump_consensus_state
~~~
your validator votes (prevote)
~~~
curl -s http://localhost:26657/dump_consensus_state | jq '.result.round_state.votes[0].prevotes' | grep $(curl -s http://localhost:26657/status | jq -r '.result.validator_info.address[:12]')
~~~
### Snapshot
- `updates every 4h`

Download snapshot
~~~
cd $HOME
wget -O namada-snapshot.tar https://files-namada.catsmile.tech/testnet/namada-snapshot.tar.lz4
~~~
Stop node and unpack snapshot
~~~
sudo systemctl stop namadad
cp $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/data/priv_validator_state.json $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/priv_validator_state.json.backup
rm -rf $HOME/.local/share/namada/shielded-expedition.88f17d1d14/db $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/data
tar -xvf $HOME/snap_namada.tar -C $HOME/.local/share/namada/shielded-expedition.88f17d1d14
mv $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/priv_validator_state.json.backup $HOME/.local/share/namada/shielded-expedition.88f17d1d14/cometbft/data/priv_validator_state.json
~~~
Restart node
~~~
sudo systemctl restart namadad && sudo journalctl -u namadad -f
~~~
Delete snap file
~~~
rm -rf $HOME/namada-snapshot.tar
~~~

### Upgrade
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
sudo systemctl restart namadad && sudo journalctl -u namadad -f
~~~

### Grafana
Download the Grafana installation 
~~~
curl -o grafana.sh https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Namada%20Shielded%20Epedition/grafana.sh
~~~
Grant execute permission to the script:
~~~
chmod +x grafana.sh
~~~
Run the Grafana 
~~~
./grafana.sh
~~~
Install the necessary packages:
~~~
sudo apt-get install -y apt-transport-https software-properties-common wget
~~~
Create a directory for the apt keys
~~~
sudo mkdir -p /etc/apt/keyrings/
~~~
Download the Grafana public key and place it in the apt key directory
~~~
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
~~~
Add the Grafana repository to the package source list
~~~
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
~~~
Update the package list
~~~
sudo apt-get update
~~~
Install the Grafana package
~~~
sudo apt-get install grafana
~~~
Reload the Systemd daemon
~~~
sudo systemctl daemon-reload
~~~
Start the Grafana service
~~~
sudo systemctl start grafana-server
~~~
Check the status of the Grafana service
~~~
sudo systemctl status grafana-server
~~~
- `Your Grafana should be working now`
- `Log to your grafana dashboard on port 3000*`

Link in Browser
~~~
http://SERVER_IP:3000/
~~~
- go to grafana [dashboard](https://grafana.com/grafana/dashboards)
- `search for namada , or chose ID 19014 then import it to your grafana dashboard`
- [Here](https://grafana.com/grafana/dashboards/19014-namada-blockchains)

### Cheat-Sheet
Reload services
~~~
sudo systemctl daemon-reload
~~~
Enable Service
~~~
sudo systemctl enable namadad
~~~
Disable Service
~~~
sudo systemctl disable namadad
~~~
Start service
~~~
sudo systemctl start namadad
~~~
Stop service
~~~
sudo systemctl stop namadad
~~~
Restart service
~~~
sudo systemctl restart namadad
~~~
Check service status
~~~
sudo systemctl status namadad
~~~
Check logs
~~~
sudo journalctl -u namadad -f
~~~
Sync info
~~~
curl http://127.0.0.1:26657/status | jq
~~~
Check Balance
~~~
namadac balance --owner $WALLET
~~~
find validator status
~~~
namadac validator-state --validator $VALIDATOR_ADDRESS
~~~
check epoch
~~~
namada client epoch
~~~

### Delete node
~~~
sudo systemctl stop namadad
sudo systemctl disable namadad
sudo rm -rf /etc/systemd/system/namadad.service
sudo systemctl daemon-reload
sudo rm $(which namada)
sudo rm -rf $HOME/root/.local/share/namada/shielded-expedition.88f17d1d14
~~~
### Progress
  1. Namada SE `RPC` status: `completed` implementation public ✅
  2. Namada SE `Snapshoot` status: `completed` implementation public ✅
  3. Namada SE `Indexer` status: `completed` implementation public ✅
  4. Namada SE `Services` status: `completed` implementation public ✅
  5. Namada SE `Interface-SDK` status: `completed` implementation public 🛠
  6. Namada SE `Relayler` status: `completed` implementation public 🛠
  7. Namada SE `Interface Osmo` status: `completed` implementation public 🛠
  8. Namada SE `Explorer` status: `Build & Setup` implementation public 🛠
  9. Namada SE `Tool` status: `completed` implementation public 🛠
