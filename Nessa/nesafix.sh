#!/bin/bash

# Function to print message in green color
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Function to get Node ID and IP
get_node_info() {
    NODE_ID=$(cat $HOME/.nesa/identity/node_id.id)
    IP_ADDRESS=$(curl -s ifconfig.me)
    print_green "Node ID and IP information retrieved successfully"
}

# Function to increase UDP buffer size
increase_udp_buffer_size() {
    print_green "Increasing UDP buffer size..."
    echo "net.core.rmem_max=2500000" | sudo tee -a /etc/sysctl.conf
    echo "net.core.rmem_default=2500000" | sudo tee -a /etc/sysctl.conf
    echo "net.core.wmem_max=2500000" | sudo tee -a /etc/sysctl.conf
    echo "net.core.wmem_default=2500000" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}

# Function to check IPFS connection
check_ipfs_connection() {
    print_green "Checking IPFS connection..."
    if docker exec ipfs ipfs swarm peers >/dev/null 2>&1; then
        print_green "IPFS connected."
        PEER_COUNT=$(docker exec ipfs ipfs swarm peers | wc -l)
        print_green "Connected peers: $PEER_COUNT"
        PEER_ID=$(docker exec ipfs ipfs id -f="<id>")
        print_green "Peer ID: $PEER_ID"
        BANDWIDTH_INFO=$(docker exec ipfs ipfs stats bw)
        print_green "Bandwidth info:"
        print_green "$BANDWIDTH_INFO"
        REPO_SIZE=$(docker exec ipfs ipfs repo stat | grep "RepoSize" | awk '{print $2}')
        print_green "Hosted data size: $REPO_SIZE"
        return 0
    else
        print_green "IPFS not connected."
        return 1
    fi
}

# Function to fix IPFS
fix_ipfs() {
    print_green "Fixing IPFS using Docker Compose..."
    
    # Stop and remove IPFS containers and volumes
    cd ~/.nesa/docker
    docker compose -f compose.community.yml down ipfs
    docker rm -f ipfs_node 2>/dev/null
    docker volume rm docker_ipfs-data docker_ipfs-staging

    # Increase UDP buffer size if needed
    if ! grep -q "net.core.rmem_max=2500000" /etc/sysctl.conf; then
        increase_udp_buffer_size
    fi

    # Start IPFS container
    docker compose -f compose.community.yml up -d ipfs
    sleep 30

    # Check if IPFS container started successfully
    if ! docker ps | grep -q "ipfs"; then
        print_green "Failed to start IPFS container. Please check manually."
        return 1
    fi
}

# Function to check node status
check_node_status() {
    local status=$(curl -s http://localhost:31333/status | jq -r '.status')
    if [ "$status" != "UP" ]; then
        print_green "Node status: Down"
        return 1
    else
        print_green "Node status: Up"
        return 0
    fi
}

# Main function
main() {
    print_green "Starting IPFS node check and repair..."
    get_node_info

    # Check initial IPFS connection
    if check_ipfs_connection; then
        print_green "IPFS is already connected and working properly."
    else
        # Attempt to fix IPFS connection
        for i in {1..3}; do
            print_green "Attempt $i: IPFS is not connected. Attempting to fix IPFS..."
            fix_ipfs
            sleep 30
            if check_ipfs_connection; then
                print_green "IPFS is connected and working properly."
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
    
    # Check node status
    if check_node_status; then
        print_green "Node status: Up"
    else
        print_green "Node status: Down"
    fi

    print_green "✅ Repairs completed. IPFS is running well."
    print_green "Please check the IPFS WebUI at:"
    print_green "http://$IP_ADDRESS:5001/webui"
    print_green "Make sure the reported status matches what you see on the dashboard."
    print_green "Node status link: https://node.nesa.ai/nodes/$NODE_ID"
}

# Run main function
main

print_green ""
print_green "Script completed. Please check the IPFS status manually."
