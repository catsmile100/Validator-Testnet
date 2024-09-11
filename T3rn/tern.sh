#!/bin/bash

echo "Selamat datang di Setup t3rn Executor!"

# Fungsi untuk menghentikan dan menghapus service lama
remove_old_service() {
    echo "Menghentikan dan menghapus service lama jika ada..."
    sudo systemctl stop executor.service
    sudo systemctl disable executor.service
    sudo rm -f /etc/systemd/system/executor.service
    sudo systemctl daemon-reload
    echo "Service lama telah dihapus."
}

# Fungsi untuk update dan upgrade sistem
update_system() {
    echo "Memperbarui dan meningkatkan sistem..."
    sudo apt update -q && sudo apt upgrade -qy
}

# Fungsi untuk mengunduh dan mengekstrak binary
download_and_extract_binary() {
    LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4)
    EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/${LATEST_VERSION}/executor-linux-${LATEST_VERSION}.tar.gz"
    EXECUTOR_FILE="executor-linux-${LATEST_VERSION}.tar.gz"

    echo "Versi terbaru terdeteksi: $LATEST_VERSION"
    echo "Mengunduh binary Executor dari $EXECUTOR_URL..."
    curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

    if [ $? -ne 0 ]; then
        echo "Gagal mengunduh binary Executor. Silakan periksa koneksi internet Anda dan coba lagi."
        exit 1
    fi

    echo "Mengekstrak binary..."
    tar -xzvf $EXECUTOR_FILE
    rm -rf $EXECUTOR_FILE
    cd executor/executor/bin

    echo "Binary berhasil diunduh dan diekstrak."
}

# Fungsi untuk mengatur variabel lingkungan
set_environment_variables() {
    export NODE_ENV=testnet
    export LOG_LEVEL=debug
    export LOG_PRETTY=false
    echo "Variabel lingkungan diatur: NODE_ENV=$NODE_ENV, LOG_LEVEL=$LOG_LEVEL, LOG_PRETTY=$LOG_PRETTY"
}

# Fungsi untuk mengatur private key
set_private_key() {
    read -p "Masukkan Private Key dari Metamask Anda (dengan atau tanpa awalan 0x): " PRIVATE_KEY_LOCAL
    # Pastikan private key selalu dimulai dengan 0x
    PRIVATE_KEY_LOCAL=$(echo $PRIVATE_KEY_LOCAL | sed 's/^0x//;s/^/0x/')
    export PRIVATE_KEY_LOCAL
    echo "Private key telah diatur."
}

# Fungsi untuk mengatur jaringan yang diaktifkan
set_enabled_networks() {
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
    echo "Jaringan yang diaktifkan: $ENABLED_NETWORKS"
}

# Fungsi untuk membuat service systemd
create_systemd_service() {
    SERVICE_FILE="/etc/systemd/system/executor.service"
    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Executor Service
After=network.target

[Service]
User=root
WorkingDirectory=/root/executor/executor
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=$ENABLED_NETWORKS"
ExecStart=/root/executor/executor/bin/executor
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL
}

# Fungsi untuk memulai service
start_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable executor.service
    sudo systemctl start executor.service
    echo "Setup selesai! Service Executor telah dibuat dan dijalankan."
    echo "Anda dapat memeriksa status service menggunakan: sudo systemctl status executor.service"
}

# Fungsi untuk menampilkan log
display_log() {
    echo "Menampilkan log dari service executor:"
    sudo journalctl -u executor.service -f
}

# Menjalankan semua fungsi
remove_old_service
update_system
download_and_extract_binary
set_environment_variables
set_private_key
set_enabled_networks
create_systemd_service
start_service
display_log
