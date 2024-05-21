<p align="center">
  <img height="350" height="350" src="https://github.com/catsmile100/Validator-Testnet/assets/85368621/497141eb-d744-40ab-86b7-0098904c46cf">
</p>
<h1>
<p align="center"> MANTRA Chain </p>
</h1>

##### Documentation
> - [Documentation](https://docs.mantrachain.io/operate-a-node/initial-setup)
> - [Explorer](https://explorer.testnet.mantrachain.io/mantrachain)
> - [Phase 2]

### Minimum Hardware Requirements
- Ubuntu 20.04 LTS
- CPU: 2vCPU (1 core)
- Memory: 4 GB
- Storage: 200 - 500 GB

### Recommended Hardware Requirements
- CPU: 4vCPU (2 cores)
- Memory: 8 - 16GB
- Storage: 500 - 1000 GB

## 1. Automatic Installation
```
wget -O autoinstall.sh https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Mantra%20Chain/autoinstall.sh && chmod +x autoinstall.sh && ./autoinstall.sh
```

## 2. Check Sync Log
```
journalctl -fu mantrachaind -o cat
```

## 3. Check Node Status
```
mantrachaind status 2>&1 | jq .SyncInfo
```

## 4. Load the System
```
source $HOME/.bash_profile
```

## 5. Create Wallet
```
mantrachaind keys add $WALLET
```

```
mantrachaind keys add $WALLET --recover
```

## 6. Save Wallet Info
```
MANTRA_WALLET_ADDRESS=$(mantrachaind keys show $WALLET -a)
MANTRA_VALOPER_ADDRESS=$(mantrachaind keys show $WALLET --bech val -a)
echo 'export MANTRA_WALLET_ADDRESS='${MANTRA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MANTRA_VALOPER_ADDRESS='${MANTRA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## 7. Claim Faucet

- Open Link : https://faucet.testnet.mantrachain.io/
- Paste Address
- Done

## 8. Check Balance 
```
mantrachaind q bank balances $MANTRA_WALLET_ADDRESS
```

## 9. Create Validator
```
mantrachaind tx staking create-validator \
  --amount 10000000uaum \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.10" \
  --min-self-delegation "1" \
  --pubkey  $(mantrachaind tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $MANTRA_CHAIN_ID
  --gas-adjustment 1.4 \
  --gas=auto \
  -y
```

## 10. Update Node
```
mantrachaind tx staking edit-validator \
--new-moniker=$NODENAME \
--identity=<id> \
--website="<link>" \
--details="<desc>" \
--chain-id=$MANTRA_CHAIN_ID \
--from=$WALLET
```

## 11. Unjail
```
mantrachaind tx slashing unjail --broadcast-mode sync --from $WALLET --chain-id $MANTRA_CHAIN_ID --gas auto --gas-adjustment 1.4
```

## 12. Remove Node
```
sudo systemctl stop mantrachaind
sudo systemctl disable mantrachaind
sudo rm /etc/systemd/system/mantrachaind.service
sudo systemctl daemon-reload
rm -f $(which mantrachaind)
rm -rf .mantrachain
rm -rf mantrachaind
```

## 13. Command
Delegate
```
mantrachaind tx staking delegate $VALOPER_ADDRESS 10000000uaum --from $WALLET --chain-id $MANTRA_CHAIN_ID --fees 5000uaum
```
Redelegate
```
mantrachaind tx staking redelegate $VALOPER_ADDRESS <dst-validator-operator-addr> 100000000uaum --from=$WALLET --chain-id=$MANTRA_CHAIN_ID
```
Withdraw
```
mantrachaind tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$MANTRA_CHAIN_ID
```
