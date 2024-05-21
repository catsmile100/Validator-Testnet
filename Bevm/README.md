<p align="center">
  <img height="350" height="350" src="https://pbs.twimg.com/profile_images/1738138565874425856/xOG10LN0_400x400.jpg">

</p>
<h1>
<p align="center"> BEVM </p>
</h1>

### Documentation
> - [Documentation](https://documents.bevm.io/build/run-a-node)
> - [Discord](https://discord.com/invite/uSXmqaEZDB)
> - [Blog](https://medium.com/@BTClayer2/announcing-incentivized-bevm-testnet-fullnode-program-31cbc047b950)
> - [Telemetry](https://telemetry.bevm.io/#/0x41cfeafc7177775a0e838b3725a0178b89ebf5dde1b5f766becbf975a24e297b)


### Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 20.04 | 2          | 2         | 300 GB  | 

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











