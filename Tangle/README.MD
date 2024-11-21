<p align="center">
  <img height="350" height="350" src="https://bafkreid6e5xvw5cjhm2vag5kfpg7hjb6vyhp427xsrujqn7uolrx6e4ley.ipfs.nftstorage.link">
</p>

<h1>
<p align="center"> Tangle </p>
</h1>

<p align="center">
  <a href="https://www.tangle.tools/">Official</a> |
  <a href="https://discord.gg/7Y975exY">Discord</a> |
  <a href="https://twitter.com/tangle_network">Twitter</a> |
  <a href="https://leaderboard.tangle.tools/">Dashboard</a> |
  <a href="https://telemetry.polkadot.io/#/0x3d22af97d919611e03bbcbda96f65988758865423e89b2d99547a6bb61452db3">Telemetry</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Tangle | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

## Installation
Auto Install
```
sudo apt install curl -y && curl -o tangle-install.sh https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Tangle/tangle-install.sh && chmod +x tangle-install.sh && ./tangle-install.sh
chmod +x tangle-install.sh
./tangle-install.sh
```
Check Status
```
sudo systemctl status tangle
```
Restart
```
sudo systemctl restart tangle
```
Check Logs
```
sudo journalctl -u tangle -f -o cat
```
Check node
```
https://telemetry.polkadot.io/#list/0x3d22af97d919611e03bbcbda96f65988758865423e89b2d99547a6bb61452db3
```
Delete
```
systemctl stop tangle
systemctl disable tangle 
rm /etc/systemd/system/tangle.service 
systemctl daemon-reload 
cd 
rm -r .tangle
```
