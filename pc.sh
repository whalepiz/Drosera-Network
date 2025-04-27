#!/bin/bash

# ========================
# Script Cài Drosera Trap + Operator FULL AUTO (Tối ưu tự động source ~/.bashrc)
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
    printf "\r\u23F3 Đang chờ %s giây..." "$i"
    sleep 1
  done
  echo -e "\n${GREEN}\u2705 Hoàn thành đợi!${NC}"
}

# Kiểm tra sudo
if sudo -v &>/dev/null; then
    echo -e "${GREEN}Bạn có quyền sudo.${NC}"
    SUDO_CMD="sudo"
else
    echo -e "${YELLOW}Bạn KHÔNG có quyền sudo.${NC}"
    SUDO_CMD=""
fi

# Update và cài đặt gói cần thiết
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ca-certificates gnupg figlet -y

# Cài Docker
if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO_CMD apt-get update && $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    $SUDO_CMD docker run hello-world
fi

# Cài Drosera CLI
echo "Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
sleep 3
source ~/.bashrc

if command -v droseraup &> /dev/null; then
    echo "Running droseraup to complete Drosera installation..."
    droseraup
    sleep 3
    source ~/.bashrc
else
    echo -e "${RED}❌ droseraup command not found after install.${NC}"
    exit 1
fi

if ! command -v drosera &> /dev/null; then
    echo -e "${RED}❌ Drosera CLI installation failed even after droseraup.${NC}"
    exit 1
fi

# Cài Foundry CLI
curl -L https://foundry.paradigm.xyz | bash
sleep 3
source ~/.bashrc
if ! command -v forge &> /dev/null; then
    echo -e "${RED}❌ Foundry CLI installation failed.${NC}"
    exit 1
fi

# Cài Bun CLI
curl -fsSL https://bun.sh/install | bash
sleep 3
source ~/.bashrc
if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Bun CLI installation failed.${NC}"
    exit 1
fi

# 6. Tạo Trap
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# 7. Git config
read -p "Nhập GitHub Email của bạn: " github_email
read -p "Nhập GitHub Username của bạn: " github_username

git config --global user.email "$github_email"
git config --global user.name "$github_username"

# 8. Init project
forge init -t drosera-network/trap-foundry-template
bun install
forge build

# 9. Nhập PRIVATE_KEY và RPC_URL
read -p "Nhập PRIVATE_KEY của bạn: " private_key
read -p "Nhập RPC URL của bạn: " rpc_url

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

# 12. Hướng dẫn thao tác web
clear
echo -e "${YELLOW}➡️ Truy cập: https://app.drosera.io/ để Send Bloom Boost.${NC}"
while true; do
    read -p "Hoàn thành Send Bloom Boost chưa? (N để tiếp tục / Y nếu chưa): " response
    [[ "$response" =~ ^[Nn]$ ]] && break
    echo "Hãy hoàn thành Send Bloom Boost trên web trước khi tiếp tục."
done

# 13. Update whitelist
read -p "Nhập địa chỉ ví EVM Operator của bạn: " operator_address

echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$operator_address\"]" >> drosera.toml
sed -i '/whitelist = \[\]/d' drosera.toml

# 14. Banner + Loading
clear
figlet -f big "PIZ - NODE"
echo -e "${YELLOW}⌛ Đợi 8 phút đồng bộ...${NC}"
loading_bar 480

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

# 22. Hướng dẫn Opti In sau cài
echo -e "${YELLOW}➡️ Truy cập: https://app.drosera.io/ để thực hiện Opti In.${NC}"
while true; do
    read -p "Bạn đã nhấn vào Opti In và thực hiện lệnh chưa? (N để tiếp tục / Y nếu chưa): " response
    [[ "$response" =~ ^[Nn]$ ]] && break
    echo "Hãy hoàn thành Opti In trên web trước khi tiếp tục."
done

# 23. Chúc mừng hoàn tất
echo -e "\n${GREEN}🎉 CHÚC MỪNG BẠN ĐÃ HOÀN TẤT QUÁ TRÌNH CÀI ĐẶT NODE!${NC}"
echo -e "${YELLOW}➡️ Để node hoạt động ổn định, vui lòng kiên nhẫn đợi từ 1-5 tiếng.${NC}\n"
