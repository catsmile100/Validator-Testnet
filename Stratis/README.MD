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

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| StratisEVM | 4          | 8         | 1 TB  | Ubuntu 22.04 LTS  |

## Installation
1. **Request Faucet**
	- `Create New Wallet` <new_evm>
	- `Claim Faucet` https://auroria.faucet.stratisevm.com 

2. **Install Dependencies**
	```
  	sudo apt update && sudo apt upgrade -y
	sudo apt install git build-essential curl jq wget tar ufw -y unzip -y screen -y
	```
3. **Setting Deposit in Launcpad**
	- goto https://auroria.launchpad.stratisevm.com/en/overview
	- How many validators would you like to run? `1`	
	- Paste Address `<new_evm>`
	- Save `./deposit new-mnemonic --chain auroria --eth1_withdrawal_address <new_evm>`

4. **Open Port**
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
5. **Reload Port**
	```
	sudo ufw reload
	```

6. **Create Direktory**
	```
	mkdir stratis
	cd stratis
	```

7. **Download Binary**
	```
	wget https://github.com/stratisproject/go-stratis/releases/download/0.1.1/geth-linux-amd64-5c4504c.tar.gz && wget https://github.com/stratisproject/prysm-stratis/releases/download/0.1.1/beacon-chain-linux-amd64-0ebd251.tar.gz && wget https://github.com/stratisproject/prysm-stratis/releases/download/0.1.1/validator-linux-amd64-0ebd251.tar.gz && wget https://github.com/stratisproject/staking-deposit-cli/releases/download/0.1.0/staking-deposit-cli-linux-amd64.zip
	tar -xf geth-linux-amd64-5c4504c.tar.gz && tar -xf beacon-chain-linux-amd64-0ebd251.tar.gz && tar -xf validator-linux-amd64-0ebd251.tar.gz && unzip staking-deposit-cli-linux-amd64.zip
	rm geth-linux-amd64-5c4504c.tar.gz && rm beacon-chain-linux-amd64-0ebd251.tar.gz && rm validator-linux-amd64-0ebd251.tar.gz && rm staking-deposit-cli-linux-amd64.zip

	```
8. **Setting geth**
	```
	screen -S geth
	./geth --auroria --http --http.api eth,net,engine,admin --datadir=data\testnet\geth --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=jwtsecret --syncmode=full
	ctrl + a + d
	```

9. **Setting beacon**
	```
	screen -S beacon
	./beacon-chain --auroria --datadir=data\testnet\beacon --execution-endpoint=http://localhost:8551 --jwt-secret=jwtsecret
	ctrl + a + d
	```

10. **Create Deposit CLI**
	```
	cd staking-deposit-cli-linux-amd64
	tar -xf staking-deposit-cli-linux-amd64.tar.gz
	rm -rf staking-deposit-cli-linux-amd64.tar.gz
	./deposit new-mnemonic --num_validators 1 --chain auroria --eth1_withdrawal_address <address_evm>
	```
	- select  [english]
	- paste <new_evm>
	- select  [english]
	- Create Password 
	- repeat pass
	- save seed Validator 

11. **Download Keystore**
	Download Keystore in :  `/root/stratis/staking-deposit-cli-linux-amd64/validator_keys`

12. **Upload Data Deposit*
	- `Goto` https://auroria.launchpad.stratisevm.com/en/upload-deposit-data
	- `Import keys` file deposit_data-xxxx.json 
	- Deposit
	- Confirm Deposit

13. **Create Validator**
	```
	screen -S validator
	cd stratis
	./validator accounts import --keys-dir=$HOME/stratis/staking-deposit-cli-linux-amd64/validator_keys --auroria
	```
	- accept
	- input password
	- repeat pasword 
	```
	./validator --wallet-dir=$HOME/.eth2validators/prysm-wallet-v2 --auroria --suggested-fee-recipient=<address_evm>
	```
	- input password
	- ctrl + a + d

14. **Get PubKey**
	```
	cd stratis
	cat $HOME/stratis/staking-deposit-cli-linux-amd64/validator_keys/deposit* | jq '.[].pubkey
	```

15. **Check Validator** 
	- `Go to` https://auroria.beacon.stratisevm.com/validator/<YOUR_PUBKEY>
	- Deposit Active around 16-24 hours

16. **Create Moniker** 
	1. Access https://www.myetherwallet.com/wallet/sign using your Metamask wallet connected to the Stratis wallet <address_evm>
	2. Navigate to Message > Sign Message.
	3. Input the signature, for example: *<YOUR_VALIDATOR_NAME> beaconcha.in*
	4. Sign & Confirm Transaction in your wallet
	5. Copy and go to https://auroria.explorer.stratisevm.com/<YOUR_PUBKEY>
	6. Enter your validator name and paste the previously copied signature, then click Save Changes
