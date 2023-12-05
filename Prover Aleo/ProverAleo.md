# Prover Aleo Testnet3

## Requirements Provers
 1. Ubuntu 22.04 (LTS)
 2. 32-cores (64-cores preferred)
 3. 32GB of memory (64GB or larger preferred)
 4. 128GB of disk space
 5. 250Mbps of upload and download bandwidth
 6. CUDA-enabled GPU (optional)

## Dependecy
```
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install ufw
```
```
sudo apt install git -y && sudo apt install screen -y
```
## Open Port
```
sudo ufw allow 4133/tcp && sudo ufw allow 3033/tcp && sudo ufw allow 22
```
```
sudo ufw enable && sudo ufw status
```
## Cloning Repository
```
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
```
## Directory
```
cd snarkOS
```
## Build
```
./build_ubuntu.sh
```
## Sett Screen
```
screen -S aleo
```
## Install 
```
cargo install --path .
```
## Run an Aleo Client
```
./run-client.sh
```
## Wait For Synchronize
## Create Account
```
snarkos account new
```
## save
## Run Prover
```
./run-prover.sh
```
## Input Privatekey
```
Enter the Aleo Prover account private key:
```
CTRL AD

