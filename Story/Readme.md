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
| Story | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

# Auto Installation
```
rm -f installstory.sh && wget https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Story/installstory.sh
```
```
dos2unix installstory.sh && chmod +x installstory.sh && ./installstory.sh && rm -rf installstory.sh
```
# Manual Install
## Install dependencies
```
udo apt update
sudo apt-get update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y
```
## Download Story-Geth binary `v0.10.1`
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
