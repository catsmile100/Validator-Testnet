#!/bin/bash

# Fungsi untuk menampilkan judul
print_title() {
    echo "=================================="
    echo "    Zenrock Node Auto-Installer   "
    echo "=================================="
    echo
    sleep 2
}

# Fungsi untuk memeriksa apakah paket sudah terinstal
is_package_installed() {
    dpkg -s "$1" &> /dev/null
}

# Meminta input moniker
read -p "Masukkan nama moniker Anda: " MONIKER

# Menampilkan judul
print_title

echo "Memulai instalasi..."
sleep 2

# Memeriksa dan menginstal dependensi
echo "Memeriksa dan menginstal dependensi..."
sleep 1

if ! is_package_installed curl || ! is_package_installed git || ! is_package_installed jq || ! is_package_installed lz4 || ! is_package_installed build-essential; then
    sudo apt -q update
    sudo apt -qy install curl git jq lz4 build-essential
else
    echo "Semua dependensi sudah terinstal. Melanjutkan..."
fi

echo "Memperbarui sistem..."
sudo apt -qy upgrade

# Menginstal Go
echo "Memeriksa instalasi Go..."
if ! command -v go &> /dev/null; then
    echo "Menginstal Go..."
    sudo rm -rf /usr/local/go
    curl -Ls https://go.dev/dl/go1.23.2.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
    echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh
    echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile
    source $HOME/.profile
else
    echo "Go sudah terinstal. Melanjutkan..."
fi

# Mengunduh binari
echo "Mengunduh binari proyek..."
mkdir -p $HOME/.zrchain/cosmovisor/genesis/bin
wget -O $HOME/.zrchain/cosmovisor/genesis/bin/zenrockd https://releases.gardia.zenrocklabs.io/zenrockd-4.7.1
chmod +x $HOME/.zrchain/cosmovisor/genesis/bin/zenrockd

# Membuat symlink aplikasi
echo "Membuat symlink aplikasi..."
sudo ln -s $HOME/.zrchain/cosmovisor/genesis $HOME/.zrchain/cosmovisor/current -f
sudo ln -s $HOME/.zrchain/cosmovisor/current/bin/zenrockd /usr/local/bin/zenrockd -f

# Menginstal Cosmovisor dan membuat layanan
echo "Menginstal Cosmovisor..."
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0

echo "Membuat layanan..."
sudo tee /etc/systemd/system/zenrock-testnet.service > /dev/null << EOF
[Unit]
Description=zenrock node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.zrchain"
Environment="DAEMON_NAME=zenrockd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.zrchain/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable zenrock-testnet.service

# Mengatur konfigurasi node
echo "Mengatur konfigurasi node..."
zenrockd config set client chain-id gardia-2
zenrockd config set client keyring-backend test
zenrockd config set client node tcp://localhost:18257

# Menginisialisasi node
echo "Menginisialisasi node..."
zenrockd init $MONIKER --chain-id gardia-2

# Mengunduh genesis dan addrbook
echo "Mengunduh genesis dan addrbook..."
curl -Ls https://snapshots.kjnodes.com/zenrock-testnet/genesis.json > $HOME/.zrchain/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/zenrock-testnet/addrbook.json > $HOME/.zrchain/config/addrbook.json

# Menambahkan seeds
echo "Menambahkan seeds..."
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@zenrock-testnet.rpc.kjnodes.com:18259\"|" $HOME/.zrchain/config/config.toml

# Mengatur harga gas minimum
echo "Mengatur harga gas minimum..."
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0urock\"|" $HOME/.zrchain/config/app.toml

# Mengatur pruning
echo "Mengatur pruning..."
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.zrchain/config/app.toml

# Mengatur port kustom
echo "Mengatur port kustom..."
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:18258\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:18257\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:18260\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:18256\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":18266\"%" $HOME/.zrchain/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:18217\"%; s%^address = \":8080\"%address = \":18280\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:18290\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:18291\"%; s%:8545%:18245%; s%:8546%:18246%; s%:6065%:18265%" $HOME/.zrchain/config/app.toml

# Mengunduh snapshot terbaru
echo "Mengunduh snapshot terbaru..."
curl -L https://snapshots.kjnodes.com/zenrock-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.zrchain
[[ -f $HOME/.zrchain/data/upgrade-info.json ]] && cp $HOME/.zrchain/data/upgrade-info.json $HOME/.zrchain/cosmovisor/genesis/upgrade-info.json

# Memulai layanan
echo "Memulai layanan..."
sudo systemctl start zenrock-testnet.service

echo "Instalasi selesai!"
echo "Untuk memeriksa log, jalankan: sudo journalctl -u zenrock-testnet.service -f --no-hostname -o cat"
