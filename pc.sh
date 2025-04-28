#!/bin/bash

# ========================
# Drosera Trap + Operator FULL AUTO Installation Script (no manual sourcing needed)
# ========================

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Nice loading bar
loading_bar() {
  duration=$1
  for ((i=1; i<=$duration; i++)); do
    printf "\r⏳ Waiting %s seconds..." "$i"
    sleep 1
  done
  echo -e "\n${GREEN}✅ Waiting completed!${NC}"
}

# Check sudo permission
if sudo -v &>/dev/null; then
    echo -e "${GREEN}You have sudo permission.${NC}"
    SUDO_CMD="sudo"
else
    echo -e "${YELLOW}You DO NOT have sudo permission.${NC}"
    SUDO_CMD=""
fi

# Update and install necessary packages
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ca-certificates gnupg figlet -y

# Install Docker
if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO_CMD apt-get update && $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    $SUDO_CMD docker run hello-world
fi

# Install Drosera CLI
echo "Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
sleep 3
export PATH="$HOME/.drosera/bin:$PATH"  # Fix PATH
source ~/.bashrc

if command -v droseraup &> /dev/null; then
    echo "Running droseraup to complete Drosera installation..."
    droseraup
    sleep 3
    export PATH="$HOME/.drosera/bin:$PATH"  # Ensure PATH again
    source ~/.bashrc
else
    echo -e "${RED}❌ droseraup command not found after install.${NC}"
    exit 1
fi

if ! command -v drosera &> /dev/null; then
    echo -e "${RED}❌ Drosera CLI installation failed even after droseraup.${NC}"
    exit 1
fi

# Install Foundry CLI
echo "Installing Foundry CLI..."
curl -L https://foundry.paradigm.xyz | bash
sleep 3
export PATH="$HOME/.foundry/bin:$PATH"   # Fix PATH Foundry
source ~/.bashrc

if command -v foundryup &> /dev/null; then
    echo "Running foundryup to complete Foundry installation..."
    foundryup
    sleep 5
    export PATH="$HOME/.foundry/bin:$PATH"  # Ensure PATH again
    source ~/.bashrc
else
    echo -e "${RED}❌ foundryup command not found after install.${NC}"
    exit 1
fi

if ! command -v forge &> /dev/null; then
    echo -e "${RED}❌ Foundry CLI installation failed even after foundryup.${NC}"
    exit 1
fi

# Install Bun CLI
echo "Installing Bun CLI..."
curl -fsSL https://bun.sh/install | bash
sleep 3
export PATH="$HOME/.bun/bin:$PATH"   # Fix PATH Bun
source ~/.bashrc

if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Bun CLI installation failed.${NC}"
    exit 1
fi

# Create Trap
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# Git config
read -p "Enter your GitHub Email: " github_email
read -p "Enter your GitHub Username: " github_username

git config --global user.email "$github_email"
git config --global user.name "$github_username"

# Init project
forge init -t drosera-network/trap-foundry-template
bun install
forge build

# Enter PRIVATE_KEY and RPC_URL
read -p "Enter your PRIVATE_KEY: " private_key
read -p "Enter your RPC URL: " rpc_url

export DROSERA_PRIVATE_KEY="$private_key"
echo "export DROSERA_PRIVATE_KEY=\"$private_key\"" >> ~/.bashrc
source ~/.bashrc

# First trap apply
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# Check drosera.toml
if [[ ! -f "drosera.toml" ]]; then
    echo -e "${RED}❌ drosera.toml not found. Script stops.${NC}"
    exit 1
fi

# Instructions for sending Bloom Boost
clear
echo -e "${YELLOW}➡️ Please follow these steps:${NC}"
echo -e "1. Visit: https://app.drosera.io/"
echo -e "2. Connect your EVM wallet"
echo -e "3. Click on Traps Owned"
echo -e "4. Click Send Bloom Boost and send Holesky ETH"
while true; do
    read -p "Have you completed Send Bloom Boost? (N Completed / Y Not Yet): " response
    [[ "$response" =~ ^[Nn]$ ]] && break
    echo "Please complete it on the website before continuing."
done

# Update whitelist
read -p "Enter your EVM Wallet Address: " operator_address

echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$operator_address\"]" >> drosera.toml
sed -i '/whitelist = \[\]/d' drosera.toml

# Banner + Loading
clear
figlet -f big "PIZ - NODE"
echo "============================================================="
echo "Follow me on Twitter for updates and more: https://x.com/whalepiz"
echo "Join the Telegram group: https://t.me/Nexgenexplore"
echo -e "${PURPLE}💎Donate (Wallet EVM - BNB,ETH,USDT): 0x3192b8D1f19E8914BD5Bf52941Ac704455151475 ${NC}"
echo "============================================================="
echo -e "${YELLOW}⌛ Waiting 8 minutes for synchronization...${NC}"
loading_bar 480

# Second trap apply
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# Install operator
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
$SUDO_CMD cp drosera-operator /usr/bin/

# Docker Image operator
$SUDO_CMD docker pull ghcr.io/drosera-network/drosera-operator:latest

# Register operator node
echo -e "${GREEN}Registering Operator Node...${NC}"
drosera-operator register --eth-rpc-url "$rpc_url" --eth-private-key "$private_key"

# Open firewall
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw --force enable

# Clone Drosera-Network and edit .env
[ -d "Drosera-Network" ] && rm -rf Drosera-Network    # Remove old folder if exists
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env
sed -i "s/your_evm_private_key/$private_key/g" .env
sed -i "s/your_actual_private_key/$private_key/g" .env

read -p "Your VPS Public IP: " vps_ip
sed -i "s/your_vps_public_ip/$vps_ip/g" .env
sed -i "s|https://ethereum-holesky-rpc.publicnode.com|$rpc_url|g" docker-compose.yaml

# Docker compose up
$SUDO_CMD docker compose up -d

# Instructions for Opti In after install
echo -e "${YELLOW}➡️ Please follow these steps to perform Opti In:${NC}"
echo -e "1. Visit: https://app.drosera.io/"
echo -e "2. Connect your EVM wallet"
echo -e "3. Click on Traps Owned"
echo -e "4. Click Opti In to confirm the operation"
while true; do
    read -p "Have you clicked Opti In? (N Completed / Y Not Yet): " response
    [[ "$response" =~ ^[Nn]$ ]] && break
    echo "Please complete it on the website before continuing."
done

# Congratulations
echo ""
echo -e "${GREEN}🎉 Congratulations, you have completed the Node installation process!${NC}"
echo -e "${YELLOW}➡️ For the node to work stably and see green bars, please patiently wait between 3 to 10 hours.${NC}"
