**Monitor Node Analog**

This script is designed to monitor the status of a blockchain node and integrate it with a Telegram bot. It utilizes the local IP with port 9944 (default) as a means to fetch information from the node. Here's a more detailed explanation of how this script works:

1. **Fetching Node Information**
The `getNodeInfo` function is used to retrieve various information from the blockchain node through several HTTP requests using axios. The information retrieved includes:
   - Number of Connected Peers: Indicates how many peers are currently connected to the node.
   - Node Version: Displays the version of the running node.
   - Synchronization Status: Indicates whether the node is currently synchronizing or not.
   - Current Block: The block currently being processed by the node.
   - Highest Block: The highest block known by the node.

2. **Checking Synchronization Status**
The `checkSyncStatus` function is used to check if the blockchain node is out of sync. This function calls `getNodeInfo` and compares `currentBlock` and `highestBlock` to determine if there's a significant difference (>= 10 blocks). If there's a significant difference, it indicates that the node is not synchronized.

3. **Sending Telegram Messages**
The `sendTelegramMessage` function is used to send messages to Telegram users via the bot. These messages can be information about the node status or notifications if the node is not synchronized.

4. **Initializing Telegram Bot**
This part initializes the Telegram bot with the provided token and sets up polling to receive messages. The bot will respond to the /start command from users and display the "INFO" button.

5. **Handler for /start Command**
This section handles the /start command from users and displays the "INFO" button. When the "INFO" button is pressed, the bot will fetch node information and send it to the user.

6. **Handler for Callback Query**
This section handles the callback query when the user presses the "INFO" button. It calls `getNodeInfo` and sends the node information to the user.

7. **Interval for Checking Synchronization Status**
This part sets the interval to check the synchronization status of the node every 60 seconds. If the node is not synchronized, the bot will send a message to a specific chat ID to notify that the node is not synchronized.

**Conclusion**
This script allows you to monitor the real-time status of a blockchain node and receive notifications via a Telegram bot. By utilizing the local IP and port 9944, this script can fetch crucial information from the node and deliver it to Telegram users, ensuring that you always have the latest information about your node status.

###  Dependency Installation
```
npm install axios node-telegram-bot-api
```
### monitor-analog.js
```
const axios = require('axios');
const TelegramBot = require('node-telegram-bot-api');

const TOKEN = "<token_telegram>";
const CHECK_INTERVAL = 60 * 1000;  // milliseconds

async function getNodeInfo() {
    const url = "http://localhost:9944";
    try {
        const healthResponse = await axios.post(url, {
            jsonrpc: "2.0",
            method: "system_health",
            params: [],
            id: 1
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        const versionResponse = await axios.post(url, {
            jsonrpc: "2.0",
            method: "system_version",
            params: [],
            id: 1
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        const syncStateResponse = await axios.post(url, {
            jsonrpc: "2.0",
            method: "system_syncState",
            params: [],
            id: 1
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        return {
            peers: healthResponse.data.result.peers,
            isSyncing: healthResponse.data.result.isSyncing,
            version: versionResponse.data.result,
            currentBlock: syncStateResponse.data.result.currentBlock,
            highestBlock: syncStateResponse.data.result.highestBlock
        };
    } catch (error) {
        console.error("Error fetching node info:", error);
        throw new Error("Failed to fetch node info");
    }
}

async function checkSyncStatus() {
    try {
        const nodeInfo = await getNodeInfo();
        if (!nodeInfo) return false;
        const { current_block, highest_block } = nodeInfo; 
        return highest_block - current_block >= 10;
    } catch (error) {
        return false;
    }
}

async function sendTelegramMessage(chatId, message) {
    try {
        await bot.sendMessage(chatId, message);
    } catch (error) {
        console.error("Failed to send message:", error);
    }
}

const bot = new TelegramBot(TOKEN, { polling: true });

bot.onText(/\/start/, (msg) => {
    const chatId = msg.chat.id;
    const keyboard = [[{ text: "INFO", callback_data: 'info' }]];
    const reply_markup = { inline_keyboard: keyboard };
    bot.sendMessage(chatId, 'Please select:', { reply_markup });
});

bot.on('callback_query', async (query) => {
    const chatId = query.message.chat.id;
    if (query.data === 'info') {
        try {
            const nodeInfo = await getNodeInfo();
            const message = `Node Version   : ${nodeInfo.version}\n`
                + `Peers Connected: ${nodeInfo.peers}\n`
                + `Is Syncing     : ${nodeInfo.isSyncing}\n`
                + `Current Block  : ${nodeInfo.currentBlock}\n`
                + `Highest Block  : ${nodeInfo.highestBlock}`;
            await sendTelegramMessage(chatId, message);
        } catch (error) {
            await sendTelegramMessage(chatId, "Error fetching node info.");
        }
    }
});

setInterval(async () => {
    try {
        const isOutOfSync = await checkSyncStatus();
        if (isOutOfSync) {
            const chatId = '<chat_id>';
            await sendTelegramMessage(chatId, "Node: out-of-sync");
        }
    } catch (error) {
        console.error("Failed to check sync status:", error);
    }
}, CHECK_INTERVAL);

```
***change <token_telegram> & <chat_id>***

### Create services
```
sudo tee /etc/systemd/system/monitor-analog.service > /dev/null <<EOF
[Unit]
Description=Monitor Analog Service
After=network.target

[Service]
User=$USER
WorkingDirectory=/root
ExecStart=/usr/bin/node /root/monitor-analog.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=monitor-analog

[Install]
WantedBy=multi-user.target
EOF
```

###  Enable Service
```
sudo systemctl daemon-reload
sudo systemctl enable monitor-analog.service
sudo systemctl start monitor-analog.service
```
###  Run Sample
![runss](https://github.com/catsmile100/Validator-Testnet/assets/85368621/ac2d81eb-ee59-4b45-8cf7-ab373e581f44)

