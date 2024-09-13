#!/bin/bash

set -e

echo "Script started..."

# Configuration
RPC_ENDPOINT="https://story-testnet-rpc.itrocket.net"
TARGET_HEIGHT=626575
AVERAGE_BLOCK_TIME=6 # Assumed average block time in seconds
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/$(basename "${BASH_SOURCE[0]}")"
TARGET_VERSION="v0.10.00"

# Check and install dependencies
check_install_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y $1
    fi
}

check_install_dependency curl
check_install_dependency jq

get_latest_block() {
    local result=$(curl -s -X POST $RPC_ENDPOINT -H "Content-Type: application/json" \
         -d '{"jsonrpc":"2.0","method":"abci_info","params":[],"id":1}')
    if [ $? -ne 0 ]; then
        echo "Error: Failed to connect to RPC endpoint" >&2
        return 1
    fi
    echo $result | jq -r '.result.response.last_block_height // empty'
}

run_upgrade_script() {
    cd $HOME
    rm -rf story
    git clone https://github.com/piplabs/story
    cd $HOME/story
    git checkout $TARGET_VERSION
    go build -o story ./client
    sudo mv $HOME/story/story $(which story)
    sudo systemctl restart story
}

setup_cron() {
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "*/5 * * * * $SCRIPT_PATH") | crontab -
    echo "Cron job set up to run every 5 minutes."
}

remove_cron() {
    crontab -l | grep -v "$SCRIPT_PATH" | crontab -
    echo "Cron job removed."
}

check_story_version() {
    local current_version=$(story version 2>/dev/null | grep Version | awk '{print $2}' | cut -d'-' -f1)
    if [ -z "$current_version" ]; then
        echo "Error: Unable to get current Story version" >&2
        return 1
    fi
    if [ "$current_version" = "$TARGET_VERSION" ]; then
        return 0
    else
        return 1
    fi
}

check_block_height() {
    if check_story_version; then
        echo "Story is already upgraded to $TARGET_VERSION. Exiting."
        remove_cron
        exit 0
    fi

    local current_height=$(get_latest_block)
    if [ -z "$current_height" ]; then
        echo "Error getting latest block height."
        return 1
    fi

    local blocks_remaining=$((TARGET_HEIGHT - current_height))
    local seconds_remaining=$((blocks_remaining * AVERAGE_BLOCK_TIME))
    local estimated_completion=$(date -d "@$(($(date +%s) + seconds_remaining))" "+%Y-%m-%d %H:%M:%S")

    echo "Current block height: $current_height"
    echo "Blocks remaining: $blocks_remaining"
    echo "Estimated time left: $(($seconds_remaining / 3600)) hours $(($seconds_remaining % 3600 / 60)) minutes"
    echo "Estimated completion time: $estimated_completion"
    echo "--------------------"

    if [ $current_height -ge $TARGET_HEIGHT ]; then
        echo "Reached target height $TARGET_HEIGHT. Starting upgrade..."
        run_upgrade_script
        if check_story_version; then
            echo "Upgrade to $TARGET_VERSION successful."
            remove_cron
            exit 0
        else
            echo "Upgrade failed. Current version: $(story version | grep Version)"
            return 1
        fi
    fi
}

# Set up cron job if not already set
if ! crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
    setup_cron
fi

# Check if script is run manually or by cron
if [ -t 0 ]; then
    echo "Running in interactive mode. Starting continuous check..."
    while true; do
        if ! check_block_height; then
            echo "Error occurred during block height check. Retrying in 5 minutes..."
        fi
        sleep 300 # Wait 5 minutes before next check
    done
else
    # Running from cron, just do one check
    check_block_height
fi
