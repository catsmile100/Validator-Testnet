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

check_port_4001() {
    if lsof -i :4001 > /dev/null 2>&1; then
        PROCESS=$(lsof -i :4001 | tail -n 1 | awk '{print $1}')
        PID=$(lsof -i :4001 | tail -n 1 | awk '{print $2}')
        print_green "Port 4001 is in use by process $PROCESS (PID: $PID)"
        return 1
    else
        print_green "Port 4001 is available"
        return 0
    fi
}

check_docker_status() {
    if docker ps | grep -q "ipfs"; then
        print_green "IPFS container is running"
        return 0
    else
        print_green "IPFS container is not running"
        return 1
    fi
}

stop_port_4001() {
    print_green "Stopping process using port 4001..."
    sudo lsof -ti:4001 | xargs -r sudo kill -9
    sleep 5
}

fix_ipfs() {
    print_green "Fixing IPFS using Docker Compose..."
    
    stop_port_4001
    
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
    print_green "Starting comprehensive IPFS node check..."
    get_node_info

    print_green "Checking IPFS connection..."
    check_ipfs_connection
    
    print_green "Checking port 4001..."
    check_port_4001
    
    print_green "Checking Docker status..."
    check_docker_status

    if check_ipfs_connection && check_docker_status && ! check_port_4001; then
        print_green "IPFS is already connected and working properly. No repairs needed."
    else
        print_green "Issues detected. Starting repair process..."
        for i in {1..3}; do
            print_green "Attempt $i: Fixing IPFS..."
            fix_ipfs
            sleep 30
            if check_ipfs_connection && check_docker_status && ! check_port_4001; then
                print_green "IPFS has been successfully repaired and is now connected."
                break
            fi
        done
        
        if ! check_ipfs_connection || ! check_docker_status || check_port_4001; then
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
