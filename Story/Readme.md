<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/036ac877-a23d-4904-adff-162bc9157016">
</p>

<h1>
<p align="center"> Story </p>
</h1>

<p align="center">
  <a href="https://www.story.foundation/">Official</a> |
  <a href="https://discord.com/invite/storyprotocol">Discord</a> |
  <a href="https://x.com/StoryProtocol">Twitter</a> |
  <a href="https://testnet.itrocket.net/story/staking">Explorer</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Story | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

## Open port
```
sudo ufw enable
sudo ufw allow 22
sudo ufw allow 17656/tcp
sudo ufw allow 17657/tcp
sudo ufw allow 17658/tcp
sudo ufw allow 1717/tcp
sudo ufw allow 1745/tcp
sudo ufw allow 1746/tcp
sudo ufw enable
```
## verif
```
sudo ufw reload
```

## Auto Installation
```
wget https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Story/installstory.sh
```
dos2unix installstory.sh
chmod +x installstory.sh
./installstory.sh
```

#cheatsheet

## Geth Service Management Commands

## Check Geth status
```
sudo systemctl status geth
```
## Start Geth service
```
sudo systemctl start geth
```

## Stop Geth service
```
sudo systemctl stop geth
```
## Restart Geth service
```
sudo systemctl restart geth
```
## Enable Geth service to start on boot
```
sudo systemctl enable geth
```

## Disable Geth service from starting on boot
```
sudo systemctl disable geth
```

## View Geth logs in real-time
```
sudo journalctl -u geth -f
```

# Story Service Management Commands

## Check Story status
```
sudo systemctl status story
```
## Start Story service
```
sudo systemctl start story
```
## Stop Story service
```
sudo systemctl stop story
```

## Restart Story service
```
sudo systemctl restart story
```

## Enable Story service to start on boot
```
sudo systemctl enable story
```

## Disable Story service from starting on boot
```
sudo systemctl disable story
```

## View Story logs in real-time
```
sudo journalctl -u story -f
```

# Story Node Information and Management

## Get network information
```
curl localhost:17657/net_info | jq
```
## Get node status
```
curl localhost:17657/status
```
## Get validator address
```
curl -s localhost:17657/status | jq -r .result.validator_info.address
```
## Get latest block height
```
curl -s localhost:17657/status | jq .result.sync_info.latest_block_height
```
## Check if node is catching up
```
curl -s localhost:17657/status | jq .result.sync_info.catching_up
```
## Export validator EVM key
```
story validator export --export-evm-key
```
## Create validator
```
story validator create --stake 1000000000000000000 --private-key "your_private_key"
```
## Stake as validator
```
story validator stake \
   --validator-pubkey "VALIDATOR_PUB_KEY_IN_BASE64" \
   --stake 1000000000000000000 \
   --private-key xxxxxxxxxxxxxx
```
# Delete Node
```
sudo systemctl stop story geth
sudo systemctl disable story geth
sudo rm /etc/systemd/system/story.service /etc/systemd/system/geth.service
rm -rf $HOME/.story $HOME/bin $HOME/go/bin/story $HOME/go/bin/geth
sudo systemctl daemon-reload
```
