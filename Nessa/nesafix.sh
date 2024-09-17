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

# Function to fix Orchestrator
fix_orchestrator() {
    print_green "Fixing Orchestrator..."
    docker pull ghcr.io/nesaorg/orchestrator:devnet-latest
    
    # Stop and remove existing Orchestrator container if it exists
    if docker ps -a | grep -q orchestrator; then
        print_green "Stopping and removing existing Orchestrator container..."
        docker stop orchestrator
        docker rm orchestrator
    fi
    
    docker run -d --name orchestrator --network docker_nesa -v $HOME/.nesa:/root/.nesa ghcr.io/nesaorg/orchestrator:devnet-latest
    sleep 20
}

# Function to restart Docker service
restart_docker_service() {
    print_green "Restarting Docker service..."
    sudo systemctl restart docker
    sleep 30
}

# Function to check Orchestrator logs
check_orchestrator_logs() {
    print_green "Checking Orchestrator logs..."
    docker logs --tail 100 orchestrator
}

# Function to remove existing containers
remove_existing_containers() {
    print_green "Removing existing containers..."
    docker ps -aq | xargs docker rm -f
}

# Function to perform full reset
full_reset() {
    print_green "Performing full reset for NESA node..."
    cd ~/.nesa/docker
    docker compose -f compose.yml -f compose.community.yml down
    docker volume rm docker_ipfs-data docker_ipfs-staging
    docker compose -f compose.yml -f compose.community.yml up -d
    sleep 60

    # Run IPFS daemon with --enable-pubsub-experiment
    print_green "Enabling pubsub experiment for IPFS..."
    ipfs daemon --enable-pubsub-experiment &
    sleep 30

    # Configure CORS for IPFS
    print_green "Configuring CORS for IPFS..."
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://$IP_ADDRESS:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'

    # Open necessary ports
    print_green "Opening necessary ports..."
    open_ports

    # Check Orchestrator logs
    print_green "Checking Orchestrator logs..."
    check_orchestrator_logs
}

# Function to open necessary ports
open_ports() {
    print_green "Opening ports..."
    sudo ufw allow 31333/tcp
    sudo ufw allow 4001/tcp
    sudo ufw allow 5001/tcp
    sudo ufw allow 8080/tcp
    sudo ufw reload
}

# Function to check final status
check_final_status() {
    print_green "Checking final status..."
    if check_node_status && check_ipfs_connection; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    print_green "Starting NESA node check and repair..."
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
    
    # Check and fix node status
    for i in {1..3}; do
        if check_node_status; then
            print_green "Node is up and running properly."
            break
        else
            print_green "Attempt $i: Node is down. Attempting to fix node..."
            fix_orchestrator
            open_ports
            sleep 30
        fi
    done
    
    if ! check_node_status; then
        print_green "Failed to fix node after 3 attempts. Checking Orchestrator logs..."
        check_orchestrator_logs
        print_green "Restarting Docker service..."
        restart_docker_service
        print_green "Re-running Docker Compose..."
        cd ~/.nesa/docker
        remove_existing_containers
        docker compose -f compose.yml -f compose.community.yml down
        docker compose -f compose.yml -f compose.community.yml up -d
        sleep 60
        if ! check_node_status; then
            print_green "Failed to fix node after additional steps. Performing full reset for NESA node..."
            full_reset
            sleep 60

            # Re-check after full reset
            print_green "Re-checking IPFS connection after full reset..."
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
                print_green "Failed to fix IPFS after full reset. Please check manually."
                return 1
            fi

            print_green "Re-checking node status after full reset..."
            for i in {1..3}; do
                if check_node_status; then
                    print_green "Node is up and running properly."
                    break
                else
                    print_green "Attempt $i: Node is down. Attempting to fix node..."
                    fix_orchestrator
                    open_ports
                    sleep 30
                fi
            done
            if ! check_node_status; then
                print_green "Failed to fix node after full reset. Please check manually."
                return 1
            fi
        fi
    fi
    
    # Final check
    if check_final_status; then
        print_green "✅ Repairs completed. Node and IPFS are running well."
    else
        print_green "❌ Repairs completed, but there are still issues with Node or IPFS."
        print_green "Please check the system manually or consider running the NESA bootstrap script:"
        print_green "bash <(curl -s https://raw.githubusercontent.com/nesaorg/bootstrap/master/bootstrap.sh)"
    fi

    print_green ""
    print_green "Please check the node status manually at:"
    print_green "https://node.nesa.ai/nodes/$NODE_ID"
    print_green ""
    print_green "And check the IPFS WebUI at:"
    print_green "http://$IP_ADDRESS:5001/webui"
    print_green ""
    print_green "Make sure the reported status matches what you see on the dashboard."
}

# Run main function
main

print_green ""
print_green "Script completed. Please check the node and IPFS status manually."
