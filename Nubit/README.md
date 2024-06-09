<p align="center">
  <img height="350" height="350" src="https://github.com/catsmile100/Validator-Testnet/assets/85368621/00e41002-b3ee-4358-8033-5ccadc31dc48">
</p>
<h1>
<p align="center"> Nubit Light Node </p>
</h1>

<p align="center">
  <a href="https://www.nubit.org/">Link</a> |
  <a href="https://discord.com/invite/nubit">Discord</a> |
  <a href="https://x.com/Nubit_org">Twitter</a> |
  <a href="https://docs.nubit.org/">Docs</a> |
  <a href="https://explorer.nubit.org/">Explorer</a> |
  <a href="https://points.nubit.org/">Dashboard</a> |
  <a href="https://faucet.nubit.org/">Faucet</a>
  </p>

Minimum Hardware :
OS  | CPU     | RAM      | SSD     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 2          | 2         | 500 GB  | 

### Update 
```
sudo apt update && sudo apt upgrade -y
```
### Install Node package
```
curl -sL1 https://nubit.sh | bash
```
### Create Service
```
sudo tee /etc/systemd/system/nubit.service > /dev/null <<EOF                                                              
[Unit]
Description=Nubit Light Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/nubit-node
ExecStart=/root/nubit-node/start.sh
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nubit-node

[Install]
WantedBy=multi-user.target
EOF

```
### Enable Service
```
sudo systemctl daemon-reload
```
```
sudo systemctl enable nubit
```
```
sudo systemctl start nubit
```

### Check Log
```
sudo journalctl -u nubit -f --no-hostname -o cat
```
### Save mnemonic
```
cd nubit-node
```
```
sudo cat mnemonic.txt
```
***Import to Keplr add Chain Nubit & Request  <a ref="https://faucet.nubit.org/">Faucet</a> Faucet***

### Delete
```
sudo systemctl stop nubit
sudo systemctl disable nubit
sudo rm /etc/systemd/system/nubit.service
rm -rf nubit-node
rm -rf $HOME/.nubit-light-nubit-alphatestnet-1 
```
