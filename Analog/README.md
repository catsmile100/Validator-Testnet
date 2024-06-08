<p align="center">
  <img height="350" height="350" src="https://github.com/catsmile100/Validator-Testnet/assets/85368621/d7cb2811-aea3-459a-9a04-c45b4f85bfc4">
</p>
<h1>
<p align="center"> Analog </p>
</h1>

<p align="center">
  <a href="https://pactus.org">Link</a> |
  <a href="https://discord.com/invite/H5vZkNnXCu">Discord</a> |
  <a href="https://twitter.com/pactuschain">Twitter</a> |
  <a href="https://pactus.org/user-guides">Docs</a> |
  <a href="https://pacscan.org">Explorer</a> 
</p>

Minimum Hardware :
OS  | CPU     | RAM      | NVMe     | 
| ------------- | ------------- | ------------- | -------- |
| Ubuntu 22.04 | 8          | 16         | 300 GB  | 


### Update and install necessary packages
```
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
### Add Docker GPG key and repository
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```
### Install Docker and related components
```
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
### Pull the Analog Timechain Docker image
```
docker pull analoglabs/timechain
```
### Create directory for Analog
```
mkdir -p $(pwd)/.analog
```
### Run the Analog Timechain Docker container
```
docker run -d -p 9944:9944 -p 30303:30303 -v $(pwd)/.analog:/.analog --name analog analoglabs/timechain --base-path /.analog --rpc-external --rpc-methods=Unsafe --unsafe-rpc-external --name <youe_moniker>
```
***Replace <your_moniker> with a unique name for your node***
### Install websocat
```
curl -LO https://github.com/vi/websocat/releases/download/v1.7.0/websocat_amd64-linux
chmod +x websocat_amd64-linux
sudo mv websocat_amd64-linux /usr/local/bin/websocat
```
### Verify websocat installation
```
websocat --version
```
### Test websocat with author_rotateKeys method
```
echo '{"id":1,"jsonrpc":"2.0","method":"author_rotateKeys","params":[]}' | websocat -n1 -B 99999999 ws://127.0.0.1:9944
```
### Check Telemetry
```
https://telemetry.analog.one/#/0x0614f7b74a2e47f7c8d8e2a5335be84bdde9402a43f5decdec03200a87c8b943
```
### Provide link to Polkadot.js apps for further actions
```
Visit : https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Frpc.testnet.analog.one###/accounts
```

