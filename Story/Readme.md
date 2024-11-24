<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/036ac877-a23d-4904-adff-162bc9157016">
</p>

</h2>
<p align="center"> Story </p>
<p align="center"> Story is the World's IP Blockchain platform designed to onramp Programmable IP for powering next-generation AI, DeFi, and consumer applications through tokenization of intellectual property. Through its Proof of Creativity mechanism and EVM-compatible L1 blockchain, it enables creators to tokenize, monetize, and distribute their IP while ensuring proper attribution and compensation across collaborative scenarios and AI-powered remixes </p>
</h2>

<p align="center">
  <a href="https://www.story.foundation/">Official</a> |
  <a href="https://discord.com/invite/storyprotocol">Discord</a> |
  <a href="https://x.com/StoryProtocol">Twitter</a> |
  <a href="https://testnet.itrocket.net/story/staking">Explorer</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>

Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Story | 4          | 16         | 400 GB  | Ubuntu 22.04 LTS  |

# Service
## RPC
```
https://rpc-story.catsmile.tech
```
## API
```
https://api-story.catsmile.tech
```
## peers 
```
dc4211675509d898f1b0acd39b532ba30f0d6bd3@peer-story.catsmile.tech:26656
```
## live peers 
```
PEERS=$(curl -s -X POST https://rpc-story.catsmile.tech -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"net_info","params":[],"id":1}' | jq -r '.result.peers[] | select(.connection_status.SendMonitor.Active == true) | "\(.node_info.id)@\(if .node_info.listen_addr | contains("0.0.0.0") then .remote_ip + ":" + (.node_info.listen_addr | sub("tcp://0.0.0.0:"; "")) else .node_info.listen_addr | sub("tcp://"; "") end)"' | tr '\n' ',' | sed 's/,$//' | awk '{print "\"" $0 "\""}')
sed -i "s/^persistent_peers *=.*/persistent_peers = $PEERS/" "$HOME/.story/story/config/config.toml"
    if [ $? -eq 0 ]; then
echo -e "\033[1;32mPeers updated successfully in config.toml\033[0m"
    else
echo -e "\033[1;31mError: Failed to update peers in config.toml\033[0m"
fi
```
## enode
```
enode://419ac3c5e1e5039525777d650ae98c6b782f63d9895c764defa59c5607bcc17c01f55e3c43fe5ea08c8d61131009df53f872804caf023c1063309a4fd346a219@enode-story.catsmile.tech:30303
```
## Snapshot
```
# Install dependencies and disable statesync
sudo apt install curl jq lz4 unzip -y
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.story/story/config/config.toml

# Stop node and backup priv_validator_state.json
sudo systemctl stop story-geth story
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup

# Remove old data and unpack Story snapshot
rm -rf $HOME/.story/story/data
curl https://files-story.catsmile.tech/story/story-snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/story

# Restore priv_validator_state.json
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Remove geth data and unpack Geth snapshot
rm -rf $HOME/.story/geth/odyssey/geth/chaindata
curl https://files-story.catsmile.tech/geth/geth-snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/geth/odyssey/geth

# restart node and check logs
sudo systemctl restart story story-geth
sudo journalctl -u story-geth -u story -f
```
# Auto Install
```
curl -O https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Story/installstory.sh && sed -i -e 's/\r//g' installstory.sh && chmod +x installstory.sh && ./installstory.sh
```

# Manual Install
## Install dependencies
```
udo apt update
sudo apt-get update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y
```
## Story-Geth binary v0.10.1
```
cd $HOME
wget https://github.com/piplabs/story-geth/releases/download/v0.10.1/geth-linux-amd64
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
fi
chmod +x geth-linux-amd64
mv $HOME/geth-linux-amd64 $HOME/go/bin/story-geth
source $HOME/.bash_profile
story-geth version
```
## Story binary v0.12.1
```
cd $HOME
rm -rf story-linux-amd64
wget https://github.com/piplabs/story/releases/download/v0.12.1/story-linux-amd64
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
fi
chmod +x story-linux-amd64
sudo cp $HOME/story-linux-amd64 $HOME/go/bin/story
source $HOME/.bash_profile
story version
```
## Init Story
```
story init --network odyssey --moniker "moniker"
```
## Create story-geth
```
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --odyssey --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```
## Create story
```
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```
## snapshot
```
# Story snapshot
cd $HOME
rm -f Story_snapshot.lz4
curl -o Story_snapshot.lz4 https://files-story.catsmile.tech/story/story-snapshot.tar.lz4

# Geth snapshot
cd $HOME
rm -f Geth_snapshot.lz4
curl -o Geth_snapshot.lz4 https://files-story.catsmile.tech/geth/geth-snapshot.tar.lz4

# backup
cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup

# remove old data
rm -rf ~/.story/story/data
rm -rf ~/.story/geth/odyssey/geth/chaindata

# decompress Geth snapshot
sudo mkdir -p /root/.story/geth/odyssey/geth/chaindata
lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/odyssey/geth/ > /dev/null

# restore priv_validator_state.json
cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json
```
## Restart story-geth
```
sudo systemctl daemon-reload
sudo systemctl start story-geth
sudo systemctl enable story-geth
sudo systemctl status story-geth
```
## Restart story
```
sudo systemctl daemon-reload 
sudo systemctl start story
sudo systemctl enable story
sudo systemctl status story
```
## Check logs story-geth
```
sudo journalctl -u story-geth -f -o cat
```
## Check logs story
```
sudo journalctl -u story -f -o cat
```
## Check sync
```
RPC_PORT=$(cat $HOME/.story/story/config/config.toml | grep "laddr = \"tcp" | head -n1 | cut -d: -f3 | tr -d '"')
curl localhost:$RPC_PORT/status | jq
```
## block sync left
```
RPC_PORT=$(cat $HOME/.story/story/config/config.toml | grep "laddr = \"tcp" | head -n1 | cut -d: -f3 | tr -d '"')

while true; do
    local_height=$(curl -s localhost:$RPC_PORT/status | jq -r '.result.sync_info.latest_block_height');
    network_height=$(curl -s https://odyssey.storyrpc.io/status | jq -r '.result.sync_info.latest_block_height');
    blocks_left=$((network_height - local_height));
    echo -e "\033[1;38mYour node height:\033[0m \033[1;34m$local_height\033[0m | \033[1;35mNetwork height:\033[0m \033[1;36m$network_height\033[0m | \033[1;29mBlocks left:\033[0m \033[1;31m$blocks_left\033[0m";
    sleep 5;
done
```
## Export validator Public Key & Private key
```
story validator export --export-evm-key
```
```
cat /root/.story/story/config/private_key.txt
```

## Check Balance
```
EVM_ADDRESS=$(story validator export --export-evm-key 2>/dev/null | grep "EVM Address:" | cut -d: -f2 | tr -d ' ')
story-geth --exec "eth.getBalance('$EVM_ADDRESS')" attach ~/.story/geth/odyssey/geth.ipc
```
## Create validator
```
story validator create --stake 1024000000000000000000 --private-key "private_key" --moniker "moniker"
```
## Create Staking
```
story validator stake \
   --validator-pubkey "VALIDATOR_PUB_KEY_IN_HEX" \
   --stake 1024000000000000000000 \
   --private-key xxxxxxxxxxxxxx
```
# Delete node
```
sudo systemctl stop story-geth
sudo systemctl stop story
sudo systemctl disable story-geth
sudo systemctl disable story
sudo rm /etc/systemd/system/story-geth.service
sudo rm /etc/systemd/system/story.service
sudo systemctl daemon-reload
sudo rm -rf $HOME/.story
sudo rm $HOME/go/bin/story-geth
sudo rm $HOME/go/bin/story
```
## Countdown Block upgrade Story v0.13.0
```
https://odyssey.storyscan.xyz/block/countdown/858000
```
## Cosmovisor tool upgrade 
```
# upgrade latest cosmovisor version v1.7.0
source $HOME/.bash_profile
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
cosmovisor version
```
```
mkdir -p $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin
echo '{"name":"v0.13.0","time":"0001-01-01T00:00:00Z","height":858000}' > $HOME/.story/story/cosmovisor/upgrades/v0.13.0/upgrade-info.json
```
```
sudo apt install tree
tree $HOME/.story/story/cosmovisor
```
```
# download binay v0.13.0
cd $HOME
rm story-linux-amd64
wget https://github.com/piplabs/story/releases/download/v0.13.0/story-linux-amd64
chmod +x story-linux-amd64
```
```
# binary to upgrade folder
sudo cp $HOME/story-linux-amd64 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story
```
```
# Check current symlink
ls -l /root/.story/story/cosmovisor/current
```
```
# Check the story version in current folder. It should be old version is v0.12.1
$HOME/.story/story/cosmovisor/upgrades/v0.12.1/bin/story version
```
```
# Check the binary version in upgrade folder
$HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story version
```
```
# Check upgrade info
cat $HOME/.story/story/cosmovisor/upgrades/v0.13.0/upgrade-info.json
```
```
source $HOME/.bash_profile
cosmovisor add-upgrade v0.13.0 $HOME/.story/story/cosmovisor/upgrades/v0.13.0/bin/story --force --upgrade-height 858000
```
