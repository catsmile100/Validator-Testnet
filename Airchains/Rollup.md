# Rollup

## System Requirements (Minimum-Recommended)
| Ram | CPU     | Disk                      |
| :-------- | :------- | :-------------------------------- |
| `2 GB`      | `4 Core` | `200 GB ` |

<h1 align="center">Steps</h1>

# 1- Install Dependecies
```console
# Update Packages
sudo apt update && sudo apt upgrade -y

sudo apt install -y curl git jq lz4 build-essential cmake perl automake autoconf libtool wget libssl-dev

# Install Go
sudo rm -rf /usr/local/go

curl -L https://go.dev/dl/go1.22.3.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local

echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile

source .bash_profile

go version
```
```console
# Clone Airchains repositories
git clone https://github.com/airchains-network/evm-station.git
git clone https://github.com/airchains-network/tracks.git
```

# 2- Install Evmos (EVM Station)
```console
# Go to directory
cd evm-station

# Install
go mod tidy
/bin/bash ./scripts/local-setup.sh
```

## Config Evmos systemD
```console
# Create env file
nano ~/.rollup-env
```
> Copy and Paste below codes in the env file
```console
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
HOMEDIR="$HOME/.evmosd"
TRACE=""
BASEFEE=1000000000
CONFIG=$HOMEDIR/config/config.toml
APP_TOML=$HOMEDIR/config/app.toml
GENESIS=$HOMEDIR/config/genesis.json
TMP_GENESIS=$HOMEDIR/config/tmp_genesis.json
VAL_KEY="mykey"
```
> We use root user of vps but if you use wsl or a custom user you must change user by replacing `root` in the code
```console
sudo tee /etc/systemd/system/rolld.service > /dev/null << EOF
[Unit]
Description=ZK
After=network.target

[Service]
User=root
EnvironmentFile=/root/.rollup-env
ExecStart=/root/evm-station/build/station-evm start --metrics "" --log_level info --json-rpc.api eth,txpool,personal,net,debug,web3 --chain-id "stationevm_1234-1"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

## Start Evmos
```console
sudo systemctl daemon-reload
sudo systemctl enable rolld
sudo systemctl start rolld
sudo journalctl -u rolld -f --no-hostname -o cat
```

## Get Private-key of Evmos (EVM Station)
> Save the private key!
```console
cd evm-station
/bin/bash ./scripts/local-keys.sh
```
### Update Port
```console
sed -i -e 's/address = "127.0.0.1:8545"/address = "0.0.0.0:8545"/' -e 's/ws-address = "127.0.0.1:8546"/ws-address = "0.0.0.0:8546"/' $HOME/.evmosd/config/app.toml
```
```console
sudo ufw allow 8545
sudo ufw allow 8546
```
* Restart Evmos systemD
```console
sudo systemctl restart rolld
```
# 3- Install Avail DA
Avail Turing as the DA layer
#
```console
cd $HOME
git clone https://github.com/availproject/availup.git
cd availup
/bin/bash availup.sh --network "turing" --app_id 36
```

* Close it with `Ctrl+C`

## Config systemD for Avail DA
> Copy Paste All the code below in the terminal and Enter!
```console
sudo tee /etc/systemd/system/availd.service > /dev/null <<'EOF'
[Unit]
Description=Avail Light Node
After=network.target
StartLimitIntervalSec=0

[Service]
User=root
Type=simple
Restart=always
RestartSec=120
ExecStart=/root/.avail/turing/bin/avail-light --network turing --app-id 36 --identity /root/.avail/identity/identity.toml

[Install]
WantedBy=multi-user.target
EOF
```
> We use root user of vps but if you use wsl or a custom user you must change user by replacing `root` in the code

## Start Avail DA systemD
```console
systemctl daemon-reload 
sudo systemctl enable availd
sudo systemctl start availd
sudo journalctl -u availd -f --no-hostname -o cat
```
Exit: `Ctrl+C`

## Save Avail DA Seed Phrase (Mnemonic)
```console
cat ~/.avail/identity/identity.toml
```

## Get Faucet
> Import your Avail DA Mnemonic to the [Subwallet](https://www.subwallet.app/download.html) to create a `polkadot` wallet
>
> Get your address in subwallet and get Avail faucet with `$faucet` in the [discord](https://discord.gg/airchains)
>
> You can also get Avail faucet [here](https://faucet.avail.tools/) (Turing)

# 4- Install Tracks
## Go to tracks directory
```console
cd $HOME
cd tracks
go mod tidy
```

## Initiate Tracks
* Replace `Avail-Wallet-Address` with your Avail DA wallet
* Replace `moniker-name` with your name
```console
go run cmd/main.go init --daRpc "http://127.0.0.1:7000" --daKey "Avail-Wallet-Address" --daType "avail" --moniker "moniker-name" --stationRpc "http://127.0.0.1:8545" --stationAPI "http://127.0.0.1:17545" --stationType "evm"
```

## Create Tracks Address
* Replace `moniker-name`
```console
go run cmd/main.go keys junction --accountName moniker-name --accountPath $HOME/.tracks/junction-accounts/keys
```
> Save the output of this command (Mnemonic & Address)
>
> Use wallet address with perfix `air` and get faucet with `$faucet` in `switchyard-faucet` in the [discord](https://discord.gg/airchains)

## Run Prover
```console
go run cmd/main.go prover v1EVM
```

## Find node_id
* Find node_id with this command and save it
```console
cat ~/.tracks/config/sequencer.toml
```

## Create Station
* Replace `moniker-name`
* Replace `WALLET_ADDRESS` with air... wallet you saved before
* Replace `IP` with your VPS server IP
* Replace `node_id` with your node id you saved
```console
go run cmd/main.go create-station --accountName moniker-name --accountPath $HOME/.tracks/junction-accounts/keys --jsonRPC "https://airchains-testnet-rpc.cosmonautstakes.com/" --info "EVM Track" --tracks WALLET_ADDRESS --bootstrapNode "/ip4/IP/tcp/2300/p2p/node_id"
```

## Create Station systemD file
```console
sudo tee /etc/systemd/system/stationd.service > /dev/null << EOF
[Unit]
Description=station track service
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/tracks/
ExecStart=/usr/local/go/bin/go run cmd/main.go start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Run Station Node with systemD
```console
sudo systemctl daemon-reload
sudo systemctl enable stationd
sudo systemctl restart stationd
sudo journalctl -u stationd -f --no-hostname -o cat
```
Exit: `Ctrl+C`

## Check Pod Tracker Logs
```console
sudo journalctl -u stationd -f --no-hostname -o cat
```
