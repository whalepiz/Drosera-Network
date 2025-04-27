#!/bin/bash

# ========================
# Script Cài Drosera Trap + Operator FULL AUTO
# Phiên bản: Auto Apply + Banner PIZ + Sửa .env đầy đủ
# ========================

# Định nghĩa màu sắc
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Loading đẹp
loading_bar() {
  duration=$1
  for ((i=1; i<=$duration; i++)); do
    printf "\r⏳ Đang chờ %s giây..." "$i"
    sleep 1
  done
  echo -e "\n${GREEN}✅ Hoàn thành đợi!${NC}"
}

# 1. Kiểm tra quyền sudo
if sudo -v &>/dev/null; then
    echo -e "${GREEN}Bạn có quyền sudo.${NC}"
    SUDO_CMD="sudo"
else
    echo -e "${YELLOW}Bạn KHÔNG có quyền sudo.${NC}"
    SUDO_CMD=""
fi

# 2. Cập nhật hệ thống
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y

# 3. Cài các gói cần thiết
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev ca-certificates gnupg figlet -y

# 4. Cài Docker
if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO_CMD apt-get update && $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    $SUDO_CMD docker run hello-world
fi

# 5. Cài CLI Tools
curl -L https://app.drosera.io/install | bash
curl -L https://foundry.paradigm.xyz | bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# 6. Tạo Trap
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# 7. Git config
echo "Nhập GitHub Email của bạn:"
read github_email
echo "Nhập GitHub Username của bạn:"
read github_username

git config --global user.email "$github_email"
git config --global user.name "$github_username"

# 8. Init project
forge init -t drosera-network/trap-foundry-template
bun install
forge build

# 9. Nhập PRIVATE_KEY và RPC_URL
echo "Nhập PRIVATE_KEY của bạn:"
read private_key
echo "Nhập RPC URL của bạn:"
read rpc_url

export DROSERA_PRIVATE_KEY="$private_key"
echo "export DROSERA_PRIVATE_KEY=\"$private_key\"" >> ~/.bashrc
source ~/.bashrc

# 10. Apply trap lần 1
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 11. Check drosera.toml
if [[ ! -f "drosera.toml" ]]; then
    echo -e "${RED}❌ Không tìm thấy drosera.toml. Script dừng.${NC}"
    exit 1
fi

# 12. Hướng dẫn web
while true; do
    read -p "Hoàn thành gửi Boost chưa? (N để tiếp tục / Y nếu chưa): " response
    [[ "$response" =~ ^[Nn]$ ]] && break
    echo "Hãy hoàn thành trên web trước khi tiếp tục."
done

drosera dryrun

# 13. Update whitelist
echo "Nhập địa chỉ ví EVM Operator của bạn:"
read operator_address

echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$operator_address\"]" >> drosera.toml
sed -i '/whitelist = \[\]/d' drosera.toml

# 14. Banner + Loading
clear
figlet -f big "PIZ - NODE"
echo -e "${YELLOW}⌛ Đợi 10 phút đồng bộ...${NC}"
loading_bar 600

# 15. Apply trap lần 2
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 16. Cài operator
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
$SUDO_CMD cp drosera-operator /usr/bin/

# 17. Docker Image operator
$SUDO_CMD docker pull ghcr.io/drosera-network/drosera-operator:latest

# 18. Mở firewall
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw --force enable

# 19. Clone và chỉnh .env
$SUDO_CMD rm -rf ~/Drosera-Network
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env
sed -i "s/your_evm_private_key/$private_key/g" .env
sed -i "s/your_actual_private_key/$private_key/g" .env

read -p "IP Public VPS của bạn: " vps_ip
sed -i "s/your_vps_public_ip/$vps_ip/g" .env

sed -i "s|https://ethereum-holesky-rpc.publicnode.com|$rpc_url|g" docker-compose.yaml

# 20. Docker compose
$SUDO_CMD docker compose up -d
$SUDO_CMD docker compose down
$SUDO_CMD docker compose up -d

echo -e "${GREEN}✅ Hoàn tất!${NC}"
