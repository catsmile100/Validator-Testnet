<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/70396c7b-13f3-4d4a-95a2-38623b917abd">
</p>
<h1>
<p align="center"> Union </p>
</h1>

<p align="center">
  <a href="https://union.build">Link</a> |
  <a href="https://discord.com/invite/union-build">Discord</a> |
  <a href="https://twitter.com/union_build">Twitter</a> |
  <a href="https://docs.union.build">Docs</a> 
</p>

Minimum Hardware Requirements
- Ubuntu 20.04 LTS
- CPU: 2vCPU (4 cores)
- Memory: 8
- Storage: 250 GB

Docker Installation
```
sudo apt update
sudo apt install -y docker.io
```
```
sudo systemctl start docker
sudo systemctl enable docker
```
Obtain Union Testnet Binary
```
export UNIOND_VERSION='v0.14.0'
docker pull ghcr.io/unionlabs/uniond:$UNIOND_VERSION
```
Run uniond
```
mkdir ~/.union
```
```
docker run -u $(id -u):$(id -g) -v ~/.union:/.union -it ghcr.io/unionlabs/uniond:$UNIOND_VERSION init $MONIKER bn254 --home /.union
```
Issue Sub-Commands to uniond
```
export UNIOND_VERSION='v0.14.0'
alias uniond='docker run -v ~/.union:/.union -it ghcr.io/unionlabs/uniond:$UNIOND_VERSION --home /.union'
```
Start Node
```
touch compose.yml
nano compose.yml
```
Paste the code below in compose.yml
```
cat <<EOF > compose.yml
services:
  node:
    image: ghcr.io/unionlabs/uniond:${UNIOND_VERSION}
    volumes:
      - ~/.union:/.union
      - /tmp:/tmp
    network_mode: "host"
    restart: unless-stopped
    command: start --home /.union
EOF
```
Press CTRL X, then Yes
```
docker-compose up -f path/to/compose.yml -d
```
Obtain Genesis Testnet
```
curl https://rpc.cryptware.io/genesis | jq '.result.genesis' > ~/.union/config/genesis.json
```
Create Account
```
uniond keys add $KEY_NAME
```
```
uniond keys add $KEY_NAME --recover
```
Receive Testnet Tokens
```
uniond keys show $KEY_NAME --address
```
State Sync (Optional)
```
curl -s https://rpc.cryptware.io/block | jq -r '.result.block.header.height + "\n" + .result.block_id.hash'
```
```
# Edit the TOML file ~/.union/config/config.toml and set the fields under [statesync]
# [statesync]
# enable = true
# rpc_servers = "https://rpc.cryptware.io:443,https://rpc.purmuzlu.cc:443"
# trust_height = 11143 # Replace with trusted_height
# trust_hash = "DAD8FE1231B030B27D36634C52DEAECCABDB6AA0AFDECC9459E507A254D4D6C9" # Replace with trusted_hash
# trust_period = "400s"
```
Start
```
uniond start
```
Create Validator
```
uniond tx staking create-validator \
  --amount 1000000muno \
  --pubkey $(uniond tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id union-testnet-4 \
  --from $KEY_NAME \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.20" \
  --commission-rate "0.1" \
  --min-self-delegation "1"
```
