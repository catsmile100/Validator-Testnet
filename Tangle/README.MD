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

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Tangle | 4          | 8         | 200 GB  | Ubuntu 22.04 LTS  |

## Installation
1. **Auto Install**
	```
	sudo apt install curl -y && curl -o tangle-install.sh https://raw.githubusercontent.com/catsmile100/Validator-Testnet/main/Tangle/tangle-install.sh && chmod +x tangle-install.sh && ./tangle-install.sh
	chmod +x tangle-install.sh
	./tangle-install.sh
	```
2. **Check Status**
	```
	sudo systemctl status tangle
	```
3. **Restart**
	```
	sudo systemctl restart tangle
	```
4. **Check Logs**
	```
	sudo journalctl -u tangle -f -o cat
	```
5. **Check node:**
	```
	https://telemetry.polkadot.io/#list/0x3d22af97d919611e03bbcbda96f65988758865423e89b2d99547a6bb61452db3
	```
<p align="center">
  <img height="350" height="350" src="https://bafkreiebgluunvrgjdsni5f7garf4ubxferobpa7nd2jdtosa4rhloy3su.ipfs.nftstorage.link">
</p>

6. **Create Wallet**
	```
	https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Ftestnet-rpc.tangle.tools#/staking
	```
7. **Requeest Faucet**
	- In DisCord `#🚰-faucet`

8. **Get Key Validator**
	```
	curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9933
	```
	- {"jsonrpc":"2.0","result":`HERE COPY`,"id":1} 
9. **Setting Validator**
	```
	https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Ftestnet-rpc.tangle.tools#/staking
	```
<p align="center">
  <img height="350" height="350" src="https://bafkreiazpvq3rnz7bnx547dknweeqmnjpv76lbzxz6mqozl7op37dik5be.ipfs.nftstorage.link/">
</p>

<p align="center">
  <img height="350" height="350" src="https://bafkreier6u2mmc2cmhsgd6otjvpxkzd2c7alghapwmmwz6dut53sgu5iem.ipfs.nftstorage.link/">
</p>
	
10. **Backup**
	- Save folder: `/root/.tangle/data/chains/tangle-standalone-testnet/keystore/`
	- Save file: `/root/.tangle/node-key`

11. **Monitor Dashboard**
	- https://leaderboard.tangle.tools/
<p align="center">
  <img height="350" height="350" src="https://bafkreiaws7yodavdznc3szyykdw4rmywvu6y6gxintsnkekvkufxy42hha.ipfs.nftstorage.link/">
</p>

12. **Delete**
	```
	systemctl stop tangle
	systemctl disable tangle 
	rm /etc/systemd/system/tangle.service 
	systemctl daemon-reload 
	cd 
	rm -r .tangle
	```
