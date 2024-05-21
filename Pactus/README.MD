<p align="center">
  <img height="350" height="350" src="">
</p>
<h1>
<p align="center"> Pactus chain </p>
</h1>


<p align="center">
  <a href="https://discord.com/invite/H5vZkNnXCu">Discord</a> |
  <a href="https://twitter.com/pactuschain">Twitter</a> |
  <a href="https://pactus.org/user-guides/">Docs</a> |
  <a href="https://pactusscan.com/">Explorer</a>
</p>

<p align="center">
  <h1>Validator Installation</h1>
</p>


## Pactus Description
Pactus is a decentralized blockchain platform that aims to create a user-friendly ecosystem by eliminating centralization and manipulation. It utilizes a percentage-based fee model, offers dedicated decentralized storage, and focuses on simplicity and accessibility for all users. Pactus aims to provide a secure and scalable infrastructure for various decentralized applications and services. By leveraging blockchain technology, Pactus seeks to empower individuals and businesses to participate in a decentralized economy while ensuring transparency and trust. Through its innovative features and user-centric approach, Pactus strives to revolutionize the way we interact with digital assets and establish a more inclusive and decentralized future.

## Minimum Spec Hardware
NODE  | CPU     | RAM      | SSD     | OS     |
| ------------- | ------------- | ------------- | -------- | -------- |
| Pactus | 2          | 4         | 250  | Ubuntu 20.04 LTS  |

## Installation

1. **Update**
	```
	sudo apt update; sudo apt upgrade
	```
2. **Install Docker & Dependencies**
	```
	sudo apt-get update && sudo apt install jq git && sudo apt install apt-transport-https ca-certificates curl software-properties- common -y && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin && sudo apt-get install docker-compose-plugin
	```
3. **Download PACTUS Image**
	```
	docker pull pactus/pactus
	```
4. **Run Docker Container**
	```
	docker run -it --rm -v ~/pactus/testnet:/pactus pactus/pactus init -w /pactus --testnet
	```
5. **`SAVE`Seed & Input Password**

6. **Run Node**
	```
        docker run -it -v ~/pactus/testnet:/pactus -p 8080:8080 -p 21777:21777 -d --name pactus-testnet pactus/pactus start -w /pactus -p {Password}
	```
## Useful Commands
- **Stop Node**
	```
	docker stop pactus-testnet 
	```
- **Start Node**
	```
	docker start pactus-testnet 
	```
- **Check Logs**
	```
	docker logs pactus-testnet --tail 1000 -f
	```
## Faucet
[Request Faucet](https://discord.com/channels/795592769300987944/1164022915205972050) - Command: `faucet <address>`

## Explorer
[Explorer Link](https://explorer.codeblocklabs.com/pactus/) 

- **Error `Failed to Open Stream`**

  To resolve this error, follow these steps:

  1. Stop the Docker container named `pactus-testnet`:

     ```bash
     docker stop pactus-testnet
     ```

  2. Remove the Docker container:

     ```bash
     docker rm pactus-testnet
     ```

  3. Open the `config.toml` file using nano:

     ```bash
     nano config.toml
     ```

  4. Update the following configurations:

     - Change `Min connections` from 8 to 128.

     - Change `Max connections` from 16 to 256.

     - Change `enable_relay` from `true` to `false`.

  5. Run the Docker container again with the updated configurations:

     ```bash
     docker run -it -v ~/pactus/testnet:/pactus -p 8080:8080 -p 21777:21777 -d --name pactus-testnet pactus/pactus start -w /pactus -p {Password}
     ```


