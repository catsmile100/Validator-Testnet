<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1755661469926989824/dlA_4aUJ_400x400.jpg">
</p>

<h1>
<p align="center"> Stratis </p>
</h1>


<p align="center">
  <a href="https://www.stratisplatform.com/">Official</a> |
  <a href="https://discord.com/invite/9tDyfZs">Discord</a> |
  <a href="https://twitter.com/stratisplatform">Twitter</a> |
  <a href="https://auroria.launchpad.stratisevm.com/en/">Docs</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| StratisEVM | 4          | 8         | 1 TB  | Ubuntu 22.04 LTS  |


Install Dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install git build-essential curl jq wget tar ufw -y unzip -y screen -y
```
Open Port
```
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw deny 8545/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 13000/tcp
sudo ufw allow out 13000/udp
sudo ufw allow out 12000/tcp
sudo ufw allow out 12000/udp
sudo ufw allow 13000/tcp
sudo ufw allow 13000/udp
sudo ufw allow 12000/tcp
sudo ufw allow 12000/udp
sudo ufw deny 3500/tcp
sudo ufw deny 8551/tcp
sudo ufw deny 4000/tcp
sudo ufw allow 22
sudo ufw enable
```
Reload Port
```
sudo ufw reload
```
Create Direktory
```
mkdir stratis
cd stratis
```

Download Binary
```
wget https://github.com/stratisproject/go-stratis/releases/download/0.1.1/geth-linux-amd64-5c4504c.tar.gz && wget https://github.com/stratisproject/prysm-stratis/releases/download/0.1.1/beacon-chain-linux-amd64-0ebd251.tar.gz && wget https://github.com/stratisproject/prysm-stratis/releases/download/0.1.1/validator-linux-amd64-0ebd251.tar.gz && wget https://github.com/stratisproject/staking-deposit-cli/releases/download/0.1.0/staking-deposit-cli-linux-amd64.zip
tar -xf geth-linux-amd64-5c4504c.tar.gz && tar -xf beacon-chain-linux-amd64-0ebd251.tar.gz && tar -xf validator-linux-amd64-0ebd251.tar.gz && unzip staking-deposit-cli-linux-amd64.zip
rm geth-linux-amd64-5c4504c.tar.gz && rm beacon-chain-linux-amd64-0ebd251.tar.gz && rm validator-linux-amd64-0ebd251.tar.gz && rm staking-deposit-cli-linux-amd64.zip
```
Setting geth
```
screen -S geth
./geth --auroria --http --http.api eth,net,engine,admin --datadir=data\testnet\geth --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=jwtsecret --syncmode=full
ctrl + a + d
```

Setting beacon
```
screen -S beacon
./beacon-chain --auroria --datadir=data\testnet\beacon --execution-endpoint=http://localhost:8551 --jwt-secret=jwtsecret
ctrl + a + d
```

Create Deposit CLI
```
cd staking-deposit-cli-linux-amd64
tar -xf staking-deposit-cli-linux-amd64.tar.gz
rm -rf staking-deposit-cli-linux-amd64.tar.gz
./deposit new-mnemonic --num_validators 1 --chain auroria --eth1_withdrawal_address <address_evm>
```
Create Validator
```
screen -S validator
cd stratis
./validator accounts import --keys-dir=$HOME/stratis/staking-deposit-cli-linux-amd64/validator_keys --auroria
```
```
./validator --wallet-dir=$HOME/.eth2validators/prysm-wallet-v2 --auroria --suggested-fee-recipient=<address_evm>
```

