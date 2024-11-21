<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/01b020ef-2373-4af6-8627-7ee0137a3494">
</p>

<h2>
<p align="center"> BEVM </p>
</h2>

<p align="center" style="font-size: 14px; color: #c9d1d9; max-width: 800px; margin: 0 auto;">
  BEVM (Bitcoin Ethereum Virtual Machine) is a Bitcoin Layer-2 Network built on Substrate that's fully compatible with Ethereum Virtual Machine, allowing developers to use both Ethereum and Substrate APIs while maintaining compatibility with Ethereum wallets like MetaMask
</p>

<p align="center">
  <a href="https://documents.bevm.io/build/run-a-node">Home</a> |
  <a href="https://discord.com/invite/uSXmqaEZDB">Discord</a> 
</p>


Minimum Hardware:

| OS | CPU | RAM | SSD |
|:---|:---|:---|:---|
| Ubuntu 22.04 | 2 | 2 | 200 GB |


### Install
```
sudo apt-get update && sudo apt-get upgrade -y 
```
```
sudo apt install docker.io
```
```
curl -fsSL https://get.docker.com -o get-docker.sh
```
```
sudo sh get-docker.sh
```
```
cd /var/lib
```
```
mkdir node_bevm_test_storage
```
```
sudo docker pull btclayer2/bevm:v0.1.1
```

Create Wallet address ex: Metamsk or other Wallet

```
sudo docker run -d -v /var/lib/node_bevm_test_storage:/root/.local/share/bevm btclayer2/bevm:v0.1.1 bevm "--chain=testnet" "--name=your_node_name" "--pruning=archive" --telemetry-url "wss://telemetry.bevm.io/submit 0"

```
EDIT : "--name=your_node_name" =change with your Wallet ex: "--name=0xxxxxxxxxxxxxx"


```
sudo tee /etc/systemd/system/bevmd.service > /dev/null << EOF
[Unit]
Description=Tangle Validator Node
After=network-online.target
StartLimitIntervalSec=0

[Service]
Restart=always
WorkingDirectory=/home/bevm
RestartSec=3
LimitNOFILE=65535
ExecStart=/home/bevm/bevm --chain=testnet --name="name=your_node_name" --port 12044 --rpc-port 12033 --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"

[Install]
WantedBy=multi-user.target
EOF

```
EDIT : "--name=your_node_name" =change with your Wallet ex: "--name=0xxxxxxxxxxxxxx"
```
sudo systemctl daemon-reload
```
```
sudo systemctl enable bevmd.service
```
```
sudo systemctl start bevmd.service
```
```
sudo systemctl status bevmd.service

```
```
docker ps
```
```
docker logs -f YOUR-CONTAINER-ID
```


- https://telemetry.bevm.io/

- ctrl V + (input your wallet EVM)











