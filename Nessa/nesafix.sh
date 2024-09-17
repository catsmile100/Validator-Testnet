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

# Function to check IPFS connection
check_ipfs_connection() {
    print_green "Checking IPFS connection..."
    if ipfs swarm peers >/dev/null 2>&1; then
        print_green "IPFS connected."
        PEER_COUNT=$(ipfs swarm peers | wc -l)
        print_green "Connected peers: $PEER_COUNT"
        PEER_ID=$(ipfs id -f="<id>")
        print_green "Peer ID: $PEER_ID"
        BANDWIDTH_INFO=$(ipfs stats bw)
        print_green "Bandwidth info:"
        print_green "$BANDWIDTH_INFO"
        REPO_SIZE=$(ipfs repo stat | grep "RepoSize" | awk '{print $2}')
        print_green "Hosted data size: $REPO_SIZE"
        return 0
    else
        print_green "IPFS not connected."
        return 1
    fi
}

# Function to fix IPFS
fix_ipfs() {
    print_green "Fixing IPFS..."
    
    # Stop IPFS daemon if running
    if pgrep -x "ipfs" > /dev/null; then
        print_green "Stopping IPFS daemon..."
        killall ipfs
    fi

    # Start IPFS daemon
    print_green "Starting IPFS daemon..."
    ipfs daemon --enable-pubsub-experiment &
    sleep 30

    # Configure CORS for IPFS
    print_green "Configuring CORS for IPFS..."
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://$IP_ADDRESS:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'
    
    print_green "Enabling Experimental Pubsub..."
    ipfs config --json Experimental.Pubsub true
    
    print_green "Adding bootstrap nodes..."
    ipfs bootstrap add --default
    ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN
    ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa
    ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb
    
    print_green "Adding peers..."
    ipfs swarm connect /ip4/104.131.131.82/tcp/4001/p2p/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm
    ipfs swarm connect /ip4/104.236.179.241/tcp/4001/p2p/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm
    ipfs swarm connect /ip4/128.199.219.111/tcp/4001/p2p/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm
    
    print_green "Restarting IPFS daemon..."
    killall ipfs
    ipfs daemon --enable-pubsub-experiment &
    sleep 30
}

# Main function
main() {
    print_green "Starting IPFS node check and repair..."
    get_node_info

    # Check and fix IPFS connection
    for i in {1..3}; do
        if check_ipfs_connection; then
            print_green "IPFS is connected and working properly."
            break
        else
            print_green "Attempt $i: IPFS is not connected. Attempting to fix IPFS..."
            fix_ipfs
            sleep 30
        fi
    done
    
    if ! check_ipfs_connection; then
        print_green "Failed to fix IPFS after 3 attempts. Please check manually."
        return 1
    fi
    
    print_green "✅ Repairs completed. IPFS is running well."
    print_green "Please check the IPFS WebUI at:"
    print_green "http://$IP_ADDRESS:5001/webui"
    print_green "Make sure the reported status matches what you see on the dashboard."
}

# Run main function
main

print_green ""
print_green "Script completed. Please check the IPFS status manually."
