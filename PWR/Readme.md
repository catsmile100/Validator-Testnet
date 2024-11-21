<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/cc17213c-168f-41e8-a4e1-20e3a3ef636b">
</p>

<h1>
<p align="center"> PWR </p>
</h1>

<p align="center">
  <a href="https://www.pwrlabs.io/">Official</a> |
  <a href="https://x.com/pwrlabs">Twitter</a> |
  <a href="https://github.com/pwrlabs/PWR-Validator">Github</a> |
  <a href="https://discord.com/invite/DJkcuy9SAg">Discord</a> |
  <a href="https://explorer.pwrlabs.io/">Explorer</a>
  
</p>

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| PWR | 2          | 4         | 200 MB  | Ubuntu 22.04 LTS  |

### Install Dependencies
```
sudo apt install curl wget ufw openjdk-19-jre-headless -y
```
### Configure Firewall
```
sudo ufw allow 22/tcp
sudo ufw allow 8231/tcp
sudo ufw allow 8085/tcp
sudo ufw allow 7621/udp
sudo ufw enable
```
### Binary
```
latest_version=$(curl -s https://api.github.com/repos/pwrlabs/PWR-Validator/releases/latest | grep -Po '"tag_name": "\K.?(?=")')
wget "https://github.com/pwrlabs/PWR-Validator/releases/download/$latest_version/validator.jar"
wget "https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json"
```

### Create Password File
```
echo "YOUR_PASSWORD" > password
chmod 600 password
```
### Import Private Key
```
java -jar validator.jar --import-key YOUR_PRIVATE_KEY password YOUR_SERVER_IP --compression-level 0
```

### Create Systemd Service
```
sudo tee /etc/systemd/system/pwr.service > /dev/null <<EOF
[Unit]
Description=PWR node
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=java -jar validator.jar password $SERVER_IP --compression-level 0
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start Service  
```
sudo systemctl daemon-reload
```
sudo systemctl enable pwr.service
```
sudo systemctl start pwr.service
```

### Check Status
```
sudo systemctl status pwr
```
### View Logs
```
sudo journalctl -u pwr -f
```
### Restart Service
```
sudo systemctl restart pwr
```
### Stop service
```
sudo systemctl stop pwr.service
```
### Upgrade
```
sudo systemctl stop pwr.service
```
```
sudo rm -rf validator.jar config.json blocks rocksdb
```
```
latest_version=$(curl -s https://api.github.com/repos/pwrlabs/PWR-Validator/releases/latest | grep -Po '"tag_name": "\K.?(?=")')
wget "https://github.com/pwrlabs/PWR-Validator/releases/download/$latest_version/validator.jar"
wget "https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json"
```
