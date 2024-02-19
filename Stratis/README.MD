<p align="center">
  <img height="350" height="350" src="">
</p>
<h1>
<p align="center"> Stratis </p>
</h1>


<p align="center">
  <a href="https://www.stratisplatform.com/">Official</a> |
  <a href="https://discord.com/invite/9tDyfZs">Discord</a> |
  <a href="https://twitter.com/stratisplatform">Twitter</a> |
  <a href="https://www.stratisplatform.com/2024/02/07/500k-strax-airdrop-staking-quick-start-guide/">Docs</a> |
  <a href="https://pactusscan.com/">Explorer</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| StratisEVM | 4          | 8         | 1 TB  | Ubuntu 22.04 LTS  |

## Installation

-. 	user 	: root 
	default : root@xxxxxx:~#


1. **Install Docker & Dependencies**
	```
	sudo apt update && sudo apt upgrade -y
	sudo apt install git build-essential curl jq wget tar ufw -y
	```

2. **Open Port**
	```
	sudo ufw allow ssh
	sudo ufw allow 30303/tcp
	sudo ufw allow 13000
	sudo ufw allow 12000
	sudo ufw enable
	```

3. **Install go**
	```
	VER="1.21.5"
	wget "https://go.dev/dl/go$VER.linux-amd64.tar.gz"
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
	rm "go$VER.linux-amd64.tar.gz"

	echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
	source ~/.bash_profile
	```

4. **`check go**
	```
	go version 
	```

5. **Create ~/go/bin dir**
	```
	cd $HOME
	mkdir -p go/bin
	```

6. **Get ( geth )**
	```
	cd $HOME &&\
	wget https://github.com/stratisproject/go-stratis/releases/download/0.1.1/geth-linux-amd64-5c4504c.tar.gz &&\
	tar -xzf geth-linux-amd64-5c4504c.tar.gz &&\
	rm -r geth-linux-amd64-5c4504c.tar.gz &&\
	mv ./geth ./go/bin
	```

7 **Create geth service**
	```
	sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
	[Unit]
	Description="geth client"
	After=network-online.target

	[Service]
	User=$USER
	ExecStart=$(which geth) --auroria --http --http.api eth,net,engine,admin --datadir=$HOME/.geth --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=jwtsecret --syncmode=full
	Restart=always
	RestartSec=3
	LimitNOFILE=65535

	[Install]
	WantedBy=multi-user.target
	EOF
	```

8 **RUN geth**
	```
	sudo systemctl daemon-reload
	sudo systemctl enable geth
	sudo systemctl restart geth
	journalctl -fu geth -o cat
	```

9 **Get beacon-chain**
	```
	cd $HOME
	wget https://github.com/stratisproject/prysm-stratis/releases/download/0.1.1/beacon-chain-linux-amd64-0ebd251.tar.gz
	tar -xzf beacon-chain-linux-amd64-0ebd251.tar.gz
	rm -r beacon-chain-linux-amd64-0ebd251.tar.gz
	mv ./beacon-chain ~/go/bin
	```

10 **Create beacon service**
	```
	tee /etc/systemd/system/beacon-chain.service > /dev/null <<EOF
	[Unit]
	Description="Beacon client"
	After=network-online.target

	[Service]
	User=$USER
	ExecStart=$(which beacon-chain) --auroria --datadir=$HOME/.beacon-chain --execution-endpoint=http://localhost:8551 --jwt-secret=jwtsecret --accept-terms-of-use
	Restart=always
	RestartSec=3
	LimitNOFILE=65535

	[Install]
	WantedBy=multi-user.target
	EOF
	```

11 **RUN beacon**
	```
	sudo systemctl daemon-reload
	sudo systemctl enable beacon-chain
	sudo systemctl restart beacon-chain
	journalctl -fu beacon-chain -o cat
	```
	
