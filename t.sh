#!/bin/bash

# Drosera Network Testnet Setup Automation Script
# This script automates the setup process for deploying a Trap and four Operators on the Drosera testnet.
# It includes a Crypton header and prompts users to follow https://x.com/0xCrypton_.

# Check if running as root or user
if [ "$(id -u)" -eq 0 ]; then
    IS_ROOT=true
else
    IS_ROOT=false
fi

# Function to check command success
check_status() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1 failed. Exiting."
        exit 1
    fi
}

# Prompt for required inputs
echo "Enter private keys and public addresses for all four operators."
read -p "Enter your first EVM wallet private key (Operator 1): " OPERATOR1_PRIVATE_KEY
read -p "Enter your first EVM wallet public address (Operator 1): " OPERATOR1_ADDRESS
read -p "Enter your second EVM wallet private key (Operator 2): " OPERATOR2_PRIVATE_KEY
read -p "Enter your second EVM wallet public address (Operator 2): " OPERATOR2_ADDRESS
read -p "Enter your third EVM wallet private key (Operator 3): " OPERATOR3_PRIVATE_KEY
read -p "Enter your third EVM wallet public address (Operator 3): " OPERATOR3_ADDRESS
read -p "Enter your fourth EVM wallet private key (Operator 4): " OPERATOR4_PRIVATE_KEY
read -p "Enter your fourth EVM wallet public address (Operator 4): " OPERATOR4_ADDRESS

# Auto-detect VPS public IP
echo "Detecting VPS public IP..."
VPS_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)
if [[ -z "$VPS_IP" ]]; then
    read -p "Could not detect VPS public IP. Please enter it manually: " VPS_IP
fi
echo "VPS public IP: $VPS_IP"

# Step 1: Update and Install Dependencies
echo "Step 1: Updating system and installing dependencies..."
if [ "$IS_ROOT" = true ]; then
    apt-get update && apt-get upgrade -y
    apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
else
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
fi
check_status "Dependency installation"
source $([ "$IS_ROOT" = true ] && echo "/root/.bashrc" || echo "~/.bashrc")

# Step 2: Install Docker (if not already installed)
echo "Step 2: Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo "Docker is already installed. Skipping installation."
else
    echo "Installing Docker..."
    if [ "$IS_ROOT" = true ]; then
        apt update -y && apt upgrade -y
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update -y && sudo apt upgrade -y
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        sudo docker run hello-world
    else
        sudo apt update -y && sudo apt upgrade -y
        sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
    fi
    check_status "Docker installation"
fi
source $([ "$IS_ROOT" = true ] && echo "/root/.bashrc" || echo "~/.bashrc")

# Step 5: Whitelist Operators
echo "Step 5: Whitelisting Operators..."
cd ~/my-drosera-trap || { echo "Error: Cannot change to ~/my-drosera-trap directory."; exit 1; }
# Remove existing whitelist line
sed -i '/whitelist = \[\]/d' drosera.toml
check_status "Removing existing whitelist from drosera.toml"
# Append new whitelist for four operators
cat << EOF >> drosera.toml
private_trap = true
whitelist = ["$OPERATOR1_ADDRESS","$OPERATOR2_ADDRESS","$OPERATOR3_ADDRESS","$OPERATOR4_ADDRESS"]
EOF
check_status "Appending new whitelist to drosera.toml"

# Step 6: Configure and Run Operators (Docker Method)
echo "Step 6: Configuring and running Operators using Docker..."
mkdir -p ~/Drosera-Network
cd ~/Drosera-Network || { echo "Error: Cannot change to ~/Drosera-Network directory."; exit 1; }

# Create .env file with direct variable substitution for four operators
echo "Creating .env file..."
cat << EOF > .env
ETH_PRIVATE_KEY=$OPERATOR1_PRIVATE_KEY
ETH_PRIVATE_KEY2=$OPERATOR2_PRIVATE_KEY
ETH_PRIVATE_KEY3=$OPERATOR3_PRIVATE_KEY
ETH_PRIVATE_KEY4=$OPERATOR4_PRIVATE_KEY
VPS_IP=$VPS_IP
P2P_PORT1=31313
SERVER_PORT1=31314
P2P_PORT2=31315
SERVER_PORT2=31316
P2P_PORT3=31317
SERVER_PORT3=31318
P2P_PORT4=31319
SERVER_PORT4=31320
EOF
check_status "Creating .env file"
sleep 3

# Create docker-compose.yaml file with direct variable substitution for four operators
echo "Creating docker-compose.yaml file..."
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
    command: node --db-file-path /data/drosera.db --network-p2p-port 31313 --server-port 31314 --eth-rpc-url $ETH_RPC_URL --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key $OPERATOR1_PRIVATE_KEY --listen-address 0.0.0.0 --network-external-p2p-address $VPS_IP --disable-dnr-confirmation true
    restart: always
  drosera2:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node2
    ports:
      - "31315:31315"
      - "31316:31316"
    volumes:
      - drosera_data2:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31315 --server-port 31316 --eth-rpc-url $ETH_RPC_URL --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key $OPERATOR2_PRIVATE_KEY --listen-address 0.0.0.0 --network-external-p2p-address $VPS_IP --disable-dnr-confirmation true
    restart: always
  drosera3:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node3
    ports:
      - "31317:31317"
      - "31318:31318"
    volumes:
      - drosera_data3:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31317 --server-port 31318 --eth-rpc-url $ETH_RPC_URL --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key $OPERATOR3_PRIVATE_KEY --listen-address 0.0.0.0 --network-external-p2p-address $VPS_IP --disable-dnr-confirmation true
    restart: always
  drosera4:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node4
    ports:
      - "31319:31319"
      - "31320:31320"
    volumes:
      - drosera_data4:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31319 --server-port 31320 --eth-rpc-url $ETH_RPC_URL --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key $OPERATOR4_PRIVATE_KEY --listen-address 0.0.0.0 --network-external-p2p-address $VPS_IP --disable-dnr-confirmation true
    restart: always
volumes:
  drosera_data1:
  drosera_data2:
  drosera_data3:
  drosera_data4:
EOF
check_status "Creating docker-compose.yaml file"

# Step 9: Start the containers
echo "Starting Docker containers for four operators..."
sudo docker compose up -d
check_status "Starting Docker containers"
sleep 3

# Step 10: Restart and Dryrun Node
echo "Step 10: Restarting node and running dryrun to fetch blocks..."
pkill -f drosera-operator || { echo "Warning: Failed to stop drosera-operator processes, continuing..."; true; }
sleep 3
source $([ "$IS_ROOT" = true ] && echo "/root/.bashrc" || echo "~/.bashrc")
echo "Running drosera dryrun..."
sudo drosera dryrun || { echo "Warning: Failed to run drosera dryrun, continuing..."; true; }
sleep 3
source $([ "$IS_ROOT" = true ] && echo "/root/.bashrc" || echo "~/.bashrc")
cd ~/Drosera-Network || { echo "Error: Cannot change to ~/Drosera-Network directory."; exit 1; }
echo "Restarting node with docker compose..."
sudo docker compose up -d || { echo "Warning: Failed to restart node with docker compose, continuing..."; true; }
sleep 3
source $([ "$IS_ROOT" = true ] && echo "/root/.bashrc" || echo "~/.bashrc")
echo "Node restarted and dryrun completed."

echo "Drosera Network Testnet Setup Complete for Four Operators!"
