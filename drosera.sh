#!/bin/bash

# Drosera Network Testnet Setup Automation Script (1 Operator Version)

# Ensure we start in ~/Drosera
cd ~/Drosera || { echo "Error: Cannot change to ~/Drosera directory."; exit 1; }

# Function to check command success
check_status() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1 failed. Exiting."
        exit 1
    fi
}

# Clean up previous script runs
echo "Cleaning up previous script runs..."
pkill -f drosera-operator
sudo docker compose -f ~/Drosera-Network/docker-compose.yaml down -v 2>/dev/null
sudo docker stop drosera-node1 2>/dev/null
sudo docker rm drosera-node1 2>/dev/null
sudo rm -rf ~/my-drosera-trap ~/Drosera-Network ~/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz /usr/bin/drosera-operator ~/drosera-operator
check_status "Cleanup"
source ~/.bashrc

# Install figlet for ASCII art if not present
if ! command -v figlet &> /dev/null; then
    echo "Installing figlet for ASCII art..."
    sudo apt-get update && sudo apt-get install -y figlet
    check_status "figlet installation"
fi
source ~/.bashrc

# Display Crypton header and Twitter prompt
clear
figlet -f big "Piz|Nexgen Explore"
echo "============================================================="
echo "Follow me on Twitter for updates and more: https://x.com/whalepiz"
echo "Join the Telegram group: https://t.me/Nexgenexplore"
echo "============================================================="
echo ""

# Welcome message
echo "Starting Drosera Network Testnet Setup Automation for One Operator"
echo "Ensure you have funded Holesky ETH wallet for your operator."
echo ""

# Prompt for required inputs
read -p "Enter your EVM wallet private key : " OPERATOR1_PRIVATE_KEY
read -p "Enter your EVM wallet public address : " OPERATOR1_ADDRESS

# Auto-detect VPS public IP
echo "Detecting VPS public IP..."
VPS_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)
if [[ -z "$VPS_IP" ]]; then
    read -p "Could not detect VPS public IP. Please enter it manually: " VPS_IP
fi
echo "VPS public IP: $VPS_IP"

read -p "Enter your Ethereum Holesky RPC URL (press Enter to use default): " ETH_RPC_URL
if [[ -z "$ETH_RPC_URL" ]]; then
    ETH_RPC_URL="https://ethereum-holesky-rpc.publicnode.com"
fi
read -p "Enter your GitHub email: " GITHUB_EMAIL
read -p "Enter your GitHub username: " GITHUB_USERNAME

# Step 1: Update and Install Dependencies
echo "Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y
check_status "Dependency installation"
source ~/.bashrc

# Step 2: Install Docker if missing
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo docker run hello-world
    check_status "Docker installation"
fi
source ~/.bashrc

# Step 3: Install Drosera CLI
echo "Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
source ~/.bashrc
droseraup
source ~/.bashrc

# Step 4: Install Foundry CLI
echo "Installing Foundry CLI..."
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
source ~/.bashrc

# Step 5: Install Bun CLI
echo "Installing Bun CLI..."
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# Step 6: Trap Setup
echo "Setting up Trap..."
mkdir ~/my-drosera-trap
cd ~/my-drosera-trap
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USERNAME"
forge init -t drosera-network/trap-foundry-template
bun install
forge build
source ~/.bashrc

# Deploy Trap
echo "Deploying Trap..."
DROSERA_PRIVATE_KEY=$OPERATOR1_PRIVATE_KEY drosera apply
check_status "Trap deployment"
source ~/.bashrc

# Extract Trap Address
TRAP_ADDRESS=$(awk '/\[traps\.mytrap\]/ {p=1} p && /address =/ {print $3; exit}' ~/my-drosera-trap/drosera.toml | tr -d '"')
if [[ -z "$TRAP_ADDRESS" ]]; then
    read -p "Failed to extract Trap address. Enter manually: " TRAP_ADDRESS
fi
echo "Trap Address: $TRAP_ADDRESS"

# Ask to Send Bloom
echo "Please send Bloom Boost to your Trap at: https://app.drosera.io/"
read -p "Have you sent Bloom? (y/n): " bloom_sent
if [[ "$bloom_sent" != "y" ]]; then
    echo "Please complete the Bloom before proceeding. Exiting."
    exit 1
fi
source ~/.bashrc

# Step 7: Whitelist Operator
echo "Whitelisting Operator..."
cd ~/my-drosera-trap
sed -i '/whitelist = \[\]/d' drosera.toml
cat << EOF >> drosera.toml
private_trap = true
whitelist = ["$OPERATOR1_ADDRESS"]
EOF

echo "Waiting for cooldown..."
sleep 60
DROSERA_PRIVATE_KEY=$OPERATOR1_PRIVATE_KEY drosera apply
check_status "Trap whitelist update"
source ~/.bashrc

# Step 8: Install Operator CLI
echo "Installing Operator CLI..."
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin
sudo chmod +x /usr/bin/drosera-operator
docker pull ghcr.io/drosera-network/drosera-operator:latest
source ~/.bashrc

# Step 9: Register Operator
echo "Registering Operator..."
drosera-operator register --eth-rpc-url "$ETH_RPC_URL" --eth-private-key "$OPERATOR1_PRIVATE_KEY"
check_status "Operator registration"
sleep 3
source ~/.bashrc

# Step 10: Opt-in Operator
echo "Please log in to https://app.drosera.io/ with your Operator wallet and Opt-in to your Trap."
read -p "Have you completed Opt-in? (y/n): " optin_done
if [[ "$optin_done" != "y" ]]; then
    echo "Opt-in not completed. Exiting."
    exit 1
fi
source ~/.bashrc

# Step 11: Open Firewall Ports
echo "Opening Firewall Ports..."
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw enable
source ~/.bashrc

# Step 12: Setup Docker Compose
echo "Setting up Docker Compose for Operator..."
mkdir -p ~/Drosera-Network
cd ~/Drosera-Network
cat << EOF > .env
ETH_PRIVATE_KEY=$OPERATOR1_PRIVATE_KEY
VPS_IP=$VPS_IP
P2P_PORT1=31313
SERVER_PORT1=31314
EOF

cat << EOF > docker-compose.yaml
version: '3'
services:
  drosera1:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node1
    ports:
      - "31313:31313"
      - "31314:31314"
    volumes:
      - drosera_data1:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31313 --server-port 31314 --eth-rpc-url $ETH_RPC_URL --eth-backup-rpc-url https://holesky.drpc.org --drosera-address $TRAP_ADDRESS --eth-private-key $OPERATOR1_PRIVATE_KEY --listen-address 0.0.0.0 --network-external-p2p-address $VPS_IP --disable-dnr-confirmation true
    restart: always
volumes:
  drosera_data1:
EOF

docker compose up -d
check_status "Operator Node started"

# Step 13: Dryrun to verify
echo "Running drosera dryrun..."
cd ~/my-drosera-trap
drosera dryrun || echo "Warning: dryrun failed (can be ignored sometimes)"
sleep 3

# Final message
echo "✅ Drosera Network Testnet Setup Complete for One Operator!"
echo "Check dashboard at https://app.drosera.io/ for liveness (green blocks)."
echo "Follow Crypton on Twitter: https://x.com/whalepiz"
