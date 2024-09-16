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
    if docker exec ipfs_node ipfs id >/dev/null 2>&1; then
        print_green "IPFS connected."
        PEER_COUNT=$(docker exec ipfs_node ipfs swarm peers | wc -l)
        print_green "Connected peers: $PEER_COUNT"
        PEER_ID=$(docker exec ipfs_node ipfs id -f="<id>")
        print_green "Peer ID: $PEER_ID"
        BANDWIDTH_INFO=$(docker exec ipfs_node ipfs stats bw)
        print_green "Bandwidth info:"
        print_green "$BANDWIDTH_INFO"
        REPO_SIZE=$(docker exec ipfs_node ipfs repo stat | grep "RepoSize" | awk '{print $2}')
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
    cd ~/.nesa/docker

    # Stop and remove existing IPFS container if it exists
    if docker ps -a | grep -q ipfs_node; then
        print_green "Stopping and removing existing IPFS container..."
        docker stop ipfs_node
        docker rm ipfs_node
    fi

    # Remove existing network if it exists
    if docker network ls | grep -q docker_nesa; then
        print_green "Stopping all containers connected to docker_nesa network..."
        docker network inspect docker_nesa -f '{{range .Containers}}{{.Name}} {{end}}' | xargs -r docker stop
        print_green "Removing existing docker_nesa network..."
        docker network rm docker_nesa || true
    fi

    docker compose -f compose.community.yml down ipfs

    # Remove volumes only if they exist
    if docker volume ls | grep -q docker_ipfs-data; then
        docker volume rm docker_ipfs-data
    fi
    if docker volume ls | grep -q docker_ipfs-staging; then
        docker volume rm docker_ipfs-staging
    fi

    docker compose -f compose.community.yml up -d ipfs
    sleep 30
    
    print_green "Configuring CORS for IPFS..."
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://$IP_ADDRESS:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'
    
    print_green "Enabling Experimental Pubsub..."
    docker exec ipfs_node ipfs config --json Experimental.Pubsub true
    
    print_green "Adding bootstrap nodes..."
    docker exec ipfs_node ipfs bootstrap add --default
    docker exec ipfs_node ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN
    docker exec ipfs_node ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa
    docker exec ipfs_node ipfs bootstrap add /dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb
    
    print_green "Restarting IPFS node..."
    docker restart ipfs_node
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
    docker exec ipfs_node ipfs daemon --enable-pubsub-experiment &
    sleep 30

    # Configure CORS for IPFS
    print_green "Configuring CORS for IPFS..."
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://$IP_ADDRESS:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
    docker exec ipfs_node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'

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

# Function to check if Docker is installed
check_docker_installed() {
    if command -v docker &> /dev/null; then
        print_green "Docker is already installed."
        return 0
    else
        print_green "Docker is not installed."
        return 1
    fi
}

# Function to install Docker
install_docker() {
    print_green "Installing Docker..."
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

# Main function
main() {
    print_green "Starting NESA node check and repair..."
    get_node_info

    # Check if Docker is installed, if not install it
    if ! check_docker_installed; then
        install_docker
    fi

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
