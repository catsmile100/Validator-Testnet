<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1781168613661274112/DVPEQLrM_400x400.jpg">
</p>

<h1>
<p align="center"> Babylon </p>
</h1>

<p align="center">
  <a href="https://babylonchain.io/">Official</a> |
  <a href="https://discord.com/invite/babylonglobal">Discord</a> |
  <a href="https://twitter.com/babylon_chain">Twitter</a> |
  <a href="https://testnet.itrocket.net/babylon/staking">Explorer</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Babylon | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

## Installation
1. **Install Dependencies**
	```
	sudo apt update && sudo apt upgrade -y
	sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
	```
2. **Install GO**
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
3. **Set Vars**
	```
	echo "export WALLET="wallet"" >> $HOME/.bash_profile
	echo "export MONIKER="test"" >> $HOME/.bash_profile
	echo "export BABYLON_CHAIN_ID="bbn-test-2"" >> $HOME/.bash_profile
	echo "export BABYLON_PORT="39"" >> $HOME/.bash_profile
	source $HOME/.bash_profile
	```
4. **Download Binary**
	```
	cd $HOME
	rm -rf babylon
	git clone https://github.com/babylonchain/babylon.git
	cd babylon
	git checkout v0.7.2
	make install
	```
5. **Config and Init app**
	```
	babylond config node tcp://localhost:${BABYLON_PORT}657
	babylond config keyring-backend os
	babylond config chain-id bbn-test-2
	babylond init $MONIKER --chain-id $BABYLON_CHAIN_ID
	sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"10s\"/" $HOME/.babylond/config/config.toml
	```
6. **Download genesis and addrbook**
	```
	wget -O $HOME/.babylond/config/genesis.json https://testnet-files.itrocket.net/babylon/genesis.json
	wget -O $HOME/.babylond/config/addrbook.json https://testnet-files.itrocket.net/babylon/addrbook.json
	```
7. **Set Seeds and peers
	```
	SEEDS="cf36fd32c32e0bb89682e8b8e82c03049a0f0121@babylon-testnet-seed.itrocket.net:32656"
	PEERS="30191694cc7836642e7c98f63dc968dfcf453146@babylon-testnet-peer.itrocket.net:39656,3afdfebba5b28288a1dd7a525463e9b55978b0b9@95.217.197.190:16456,c40d705aaa3538c7c74ede08ae5cea90f01ae3e6@167.86.116.112:16456,b8eaf3cb86935bd27e457df0511cba8e45c0634b@144.91.69.96:16456,7a1e0c05beabc117a39037a7fc712b958a010a61@144.91.87.192:16456,ad891f5727cc1a3b548d6cce79da66d27bc19458@116.202.208.143:45656,a305c49968e7c2ac04da33614eecfb16d0d632aa@5.189.156.34:26656,32a1df5368af7cc9d20aa444068a95d99d246cf4@38.242.214.103:16456,eee4f0b2a354bd25893c023f385c65dd068af64e@207.180.217.180:16456,98e46dcbc3782eb3e21831c2b987baa004c5783c@173.249.44.91:16456"
	sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.babylond/config/config.toml
	```
8. **Set custom ports in app.toml**
	```
	sed -i.bak -e "s%:1317%:${BABYLON_PORT}317%g;
	s%:8080%:${BABYLON_PORT}080%g;
	s%:9090%:${BABYLON_PORT}090%g;
	s%:9091%:${BABYLON_PORT}091%g;
	s%:8545%:${BABYLON_PORT}545%g;
	s%:8546%:${BABYLON_PORT}546%g;
	s%:6065%:${BABYLON_PORT}065%g" $HOME/.babylond/config/app.toml
	```
9. **Set custom ports in config.toml file**
	```
	sed -i.bak -e "s%:26658%:${BABYLON_PORT}658%g;
	s%:26657%:${BABYLON_PORT}657%g;
	s%:6060%:${BABYLON_PORT}060%g;
	s%:26656%:${BABYLON_PORT}656%g;
	s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${BABYLON_PORT}656\"%;
	s%:26660%:${BABYLON_PORT}660%g" $HOME/.babylond/config/config.toml
	```
10. **Config pruning**
	```
	sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.babylond/config/app.toml
	ed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.babylond/config/app.toml
	sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.babylond/config/app.toml
	```
11. **Set minimum gas price, enable prometheus and disable indexing**
	```
	sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.00001ubbn"|g' $HOME/.babylond/config/app.toml
	sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.babylond/config/config.toml
	sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.babylond/config/config.toml
	```
12. **create service file**
	```
	sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
	[Unit]
	Description=Babylon node
	After=network-online.target
	[Service]
	User=$USER
	WorkingDirectory=$HOME/.babylond
	ExecStart=$(which babylond) start --home $HOME/.babylond
	Restart=on-failure
	RestartSec=5
	LimitNOFILE=65535
	[Install]
	WantedBy=multi-user.target
	EOF
	```
13. **Reset and download snapshot**
	```
	babylond tendermint unsafe-reset-all --home $HOME/.babylond
		if curl -s --head curl https://testnet-files.itrocket.net/babylon/snap_babylon.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
			curl https://testnet-files.itrocket.net/babylon/snap_babylon.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.babylond
				else
			echo no have snap
		fi
	```
14. **enable and start service**
	```
	sudo systemctl daemon-reload
	sudo systemctl enable babylond
	sudo systemctl restart babylond && sudo journalctl -u babylond -f
	```
15. **create a new wallet** 
	```
	babylond keys add $WALLET
	```
16. **restore wallet** 
	```
	babylond keys add $WALLET --recover
	```
17. **save wallet and validator address** 
	```
	WALLET_ADDRESS=$(babylond keys show $WALLET -a)
	VALOPER_ADDRESS=$(babylond keys show $WALLET --bech val -a)
	echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
	echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
	source $HOME/.bash_profile
	```
18. **check sync status** 
	```
	babylond status 2>&1 | jq .SyncInfo
	```
19. **check balance** 
	```
	babylond query bank balances $WALLET_ADDRESS
	```
20. **Create validator** 
	```
	babylond tx staking create-validator \
	--amount 1000000ubbn \
	--from $WALLET \
	--commission-rate 0.1 \
	--commission-max-rate 0.2 \
	--commission-max-change-rate 0.01 \
	--min-self-delegation 1 \
	--pubkey $(babylond tendermint show-validator) \
	--moniker "test" \
	--identity "" \
	--details "blockchain " \
	--chain-id bbn-test-2 \
	--gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn \
	-y
	```
21. **Edit Existing Validator** 
	```
	babylond tx staking edit-validator \
	--commission-rate 0.1 \
	--new-moniker "$MONIKER" \
	--identity "" \
	--details "blockchain " \
	--from $WALLET \
	--chain-id bbn-test-2 \
	--gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn \
	-y
	```
22. **Withdraw all rewards** 
	```
	babylond tx distribution withdraw-all-rewards --from $WALLET --chain-id bbn-test-2 --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn	
	```	
23. **Withdraw rewards and commission from your validator** 
	```
	babylond tx distribution withdraw-rewards $VALOPER_ADDRESS --from $WALLET --commission --chain-id bbn-test-2 --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn -y
	```	
24. **Delegate to Yourself** 
	```
	babylond tx staking delegate $(babylond keys show $WALLET --bech val -a) 1000000ubbn --from $WALLET --chain-id bbn-test-2 --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn -y
	```	
25. **Delegate** 
	```
	babylond tx staking delegate <TO_VALOPER_ADDRESS> 1000000ubbn --from $WALLET --chain-id bbn-test-2 --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn -y
	```	
26. **Validator info** 
	```
	babylond status 2>&1 | jq .ValidatorInfo
	```	
27. **Unjail validator** 
	```
	babylond tx slashing unjail --from $WALLET --chain-id bbn-test-2 --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn -y
	```	
28. **Vote** 
	```
	babylond tx gov vote 1 yes --from $WALLET --chain-id bbn-test-2  --gas auto --gas-adjustment 1.5 --gas-prices 0.0025ubbn -y
	```	
29. **Delete Node** 
	```
	sudo systemctl stop babylond
	sudo systemctl disable babylond
	sudo rm -rf /etc/systemd/system/babylond.service
	sudo rm $(which babylond)
	sudo rm -rf $HOME/.babylond
	sed -i "/BABYLON_/d" $HOME/.bash_profile
	```
