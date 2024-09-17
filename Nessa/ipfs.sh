#!/bin/bash

print_green() {
    echo -e "\e[32m$1\e[0m"
}

get_node_info() {
    NODE_ID=$(cat $HOME/.nesa/identity/node_id.id)
    IP_ADDRESS=$(curl -s ifconfig.me)
    print_green "Node ID and IP information retrieved successfully"
}

check_ipfs_connection() {
    if docker exec ipfs ipfs swarm peers >/dev/null 2>&1; then
        print_green "IPFS is connected."
        return 0
    else
        print_green "IPFS is not connected."
        return 1
    fi
}

fix_ipfs() {
    print_green "Fixing IPFS using Docker Compose..."
    
    cd ~/.nesa/docker
    docker compose -f compose.community.yml down ipfs
    docker rm -f ipfs_node 2>/dev/null
    docker volume rm docker_ipfs-data docker_ipfs-staging

    docker compose -f compose.community.yml up -d ipfs
    sleep 30

    if ! docker ps | grep -q "ipfs"; then
        print_green "Failed to start IPFS container. Please check manually."
        return 1
    fi
}

main() {
    print_green "Starting IPFS node check..."
    get_node_info

    if check_ipfs_connection; then
        print_green "IPFS is already connected and working properly."
        print_green "No repairs needed."
    else
        print_green "IPFS is not connected. Starting repair process..."
        for i in {1..3}; do
            print_green "Attempt $i: Fixing IPFS..."
            fix_ipfs
            sleep 30
            if check_ipfs_connection; then
                print_green "IPFS has been successfully repaired and is now connected."
                break
            fi
        done
        
        if ! check_ipfs_connection; then
            print_green "Failed to fix IPFS after 3 attempts. Please check manually."
            print_green "Please check the IPFS WebUI at:"
            print_green "http://$IP_ADDRESS:5001/webui"
            return 1
        fi
    fi

    print_green "✅ Check and repair (if needed) completed."
    print_green "Please check the IPFS WebUI at:"
    print_green "http://$IP_ADDRESS:5001/webui"
    print_green "Make sure the reported status matches what you see on the dashboard."
    print_green "Node status link: https://node.nesa.ai/nodes/$NODE_ID"
}

main

print_green ""
print_green "Script completed. Please check the IPFS status manually."
