#!/bin/bash

print_green() {
    echo -e "\e[32m$1\e[0m"
}

get_node_info() {
    NODE_ID=$(cat $HOME/.nesa/identity/node_id.id)
    IP_ADDRESS=$(curl -s ifconfig.me)
}

check_ipfs_status() {
    if docker ps | grep -q ipfs_node; then
        return 0
    else
        return 1
    fi
}

fix_ipfs() {
    print_green "Stopping and removing existing IPFS container..."
    docker stop ipfs_node
    docker rm ipfs_node

    print_green "Cleaning up IPFS volumes..."
    cd ~/.nesa/docker
    docker compose -f compose.community.yml down ipfs
    docker volume rm docker_ipfs-data docker_ipfs-staging

    print_green "Starting IPFS container..."
    docker compose -f compose.community.yml up -d ipfs

    print_green "Configuring CORS for IPFS..."
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://'$IP_ADDRESS':5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'

    print_green "Enabling Pubsub and updating bootstrap nodes..."
    docker exec ipfs_node ipfs config --json Experimental.Pubsub true
    docker exec ipfs_node ipfs bootstrap add --default
    docker exec ipfs_node ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN

    print_green "Restarting IPFS container..."
    docker restart ipfs_node

    print_green "Opening firewall ports..."
    sudo ufw allow 5001
    sudo ufw allow 4001
}

main() {
    get_node_info

    if check_ipfs_status; then
        print_green "IPFS is running. No fixes needed."
    else
        print_green "IPFS is not running. Starting fix process..."
        fix_ipfs
    fi

    print_green "IPFS WebUI: http://$IP_ADDRESS:5001/webui"
    print_green "Node status: https://node.nesa.ai/nodes/$NODE_ID"
}

main
