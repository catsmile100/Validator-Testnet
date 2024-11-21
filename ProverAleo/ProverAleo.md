<p align="center">
  <img height="350" height="350" src="https://github.com/user-attachments/assets/033d0d45-4e09-41ec-b806-1ee76c4fcb96">
</p>
<h1>
<p align="center"> Aleo </p>
</h1>

Requirements Provers

| No. | Requirements                                 | Specifications                                      |
|----:|----------------------------------------------|-----------------------------------------------------|
|  1. | Operating System                             | Ubuntu 22.04 (LTS)                                  |
|  2. | CPU                                          | 32-cores (64-cores preferred)                       |
|  3. | RAM                                          | 32GB of memory (64GB or larger preferred)           |
|  4. | Storage                                      | 128GB of disk space                                 |
|  5. | Network Bandwidth                            | 250Mbps of upload and download bandwidth            |
|  6. | GPU (optional)                               | CUDA-enabled GPU (optional)                         |

Install Dependency
```
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install ufw
```
```
sudo apt install git -y && sudo apt install screen -y
```
Open Port
```
sudo ufw allow 4133/tcp && sudo ufw allow 3033/tcp && sudo ufw allow 22
```
```
sudo ufw enable && sudo ufw status
```
Cloning Repository
```
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
```
Directory
```
cd snarkOS
```
Build
```
./build_ubuntu.sh
```
Setting Screen
```
screen -S aleo
```
Install
```
cargo install --path .
```
Run an Aleo Client
```
./run-client.sh
```
Wait For Synchronize
```
2023-12-05T00:50:50.779308Z  INFO Synced up to block 36299 of 803850 - 4% complete (est. 374 minutes remaining)
2023-12-05T00:50:50.779506Z DEBUG Requesting blocks 42650 to 42700 (of 803850)
2023-12-05T00:50:51.464397Z  INFO Synced up to block 36349 of 803850 - 4% complete (est. 374 minutes remaining)
2023-12-05T00:50:51.464648Z DEBUG Requesting blocks 42700 to 42750 (of 803850)
2023-12-05T00:50:52.136740Z  INFO Synced up to block 36399 of 803850 - 4% complete (est. 374 minutes remaining)
2023-12-05T00:50:52.136872Z DEBUG Requesting blocks 42750 to 42800 (of 803850)
```
Create Account
```
snarkos account new
```
Save
```
Attention - Remember to store this account private key and view key.
Private Key  APrivateKey1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  <-- Save Me And Use In The Next Step
View Key  AViewKey1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  <-- Save Me
Address  aleo1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  <-- Save Me
```
Run Prover
```
./run-prover.sh
```
Input Privatekey
```
Enter the Aleo Prover account private key: APrivateKey1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
Check Prover
```
https://explorer.hamp.app/address?a=<wallet_aleo>
```
Detacth Sesion
```
CTRL A D
```
Back Screen
```
screen -r aleo
```
DELETE
```
cd ~
rm -rf snarkOS
sudo apt-get remove --purge ufw
sudo apt-get remove --purge git
sudo apt-get remove --purge screen
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --uninstall
sudo rm -rf /etc/ufw
rm -rf ~/.gitconfig
```
