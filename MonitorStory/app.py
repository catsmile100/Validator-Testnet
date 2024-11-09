from flask import Flask, render_template
import requests
from datetime import datetime
from rich.table import Table

app = Flask(__name__)

VALIDATOR_ADDRESS = "storyvaloper1826z0gntznjlcpa4weu55uvtp5mmd62ns05gyq"

def get_validator_data(validator_address):
    url = f"https://api.testnet.storyscan.app/validators/active"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return next((item for item in data if item["operator_address"] == validator_address), None)
    except Exception as e:
        return {"error": f"Error mengambil data validator: {e}"}

def get_validator_uptime(validator_address):
    url = f"https://api.testnet.storyscan.app/blocks/uptime/{validator_address}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        return {"error": f"Error mengambil data uptime: {e}"}

@app.route('/')
def index():
    validator_info = get_validator_data(VALIDATOR_ADDRESS)
    data = get_validator_uptime(VALIDATOR_ADDRESS)
    if "error" in validator_info or "error" in data:
        return render_template('index.html', error="Gagal mengambil data")

    # Buat tabel status
    table = create_status_table(data, validator_info, 0, "🟢")
    return render_template('index.html', table=table)

def create_status_table(data, validator_info, total_missed_blocks, status_icon):
    if not data or not validator_info:
        return "Tidak ada data yang tersedia"
    
    latest_height = data[0]['height'] if data else "N/A"
    target_block = 10000000 - int(latest_height)
    
    table = Table()
    table.add_column("Info", justify="right")
    table.add_column("Value", justify="left")
    
    table.add_row("Status", status_icon)
    chain = "odyssey-0"
    table.add_row("Chain", chain)
    table.add_row("Block", str(latest_height))
    table.add_row("Target", str(target_block))
    table.add_row("Miss", str(total_missed_blocks))
    table.add_row("Moniker", "CCCCC")
    table.add_row("Uptime", f"{validator_info['uptime']['windowUptime']['uptime']:.2%}")
    table.add_row("Rank", str(validator_info["rank"]))
    table.add_row("Voting", f"{validator_info['votingPowerPercent']:.2%}")
    
    blocks = ""
    for block in data[:20]:
        blocks += "🟩" if block['signed'] else "🟥"
    table.add_row("Blocks", blocks)
    
    table.add_row("Update", datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    return table

if __name__ == "__main__":
    app.run(debug=True)