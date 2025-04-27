#!/bin/bash

# ========================
# Script Cài Drosera Trap + Operator FULL AUTO
# Phiên bản: Loading đẹp + Echo màu + Banner PIZ
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

# ========================

# 1. Kiểm tra quyền sudo
if sudo -v &>/dev/null; then
    echo -e "${GREEN}Bạn có quyền sudo.${NC}"
    SUDO_CMD="sudo"
else
    echo -e "${YELLOW}Bạn KHÔNG có quyền sudo.${NC}"
    SUDO_CMD=""
fi

# 2. Cập nhật hệ thống
echo -e "${YELLOW}⚡ Đang cập nhật hệ thống...${NC}"
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y

# 3. Cài các gói cần thiết
echo -e "${YELLOW}⚡ Đang cài đặt các gói cần thiết...${NC}"
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev ca-certificates gnupg -y

# 4. Cài Docker
echo -e "${YELLOW}⚡ Đang cài Docker...${NC}"
if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO_CMD apt-get update && $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    $SUDO_CMD docker run hello-world
fi

# 5. Cài CLI Tools
echo -e "${YELLOW}⚡ Đang cài CLI Tools...${NC}"
curl -L https://app.drosera.io/install | bash
curl -L https://foundry.paradigm.xyz | bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# 6. Tạo Trap
echo -e "${YELLOW}⚡ Tạo Trap Project...${NC}"
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# 7. Git config
echo -e "${YELLOW}⚡ Cấu hình Git...${NC}"
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
echo -e "${YELLOW}⚡ Nhập thông tin Blockchain...${NC}"
echo "Nhập PRIVATE_KEY của bạn:"
read private_key
echo "Nhập RPC URL của bạn:"
read rpc_url

# 10. Export PRIVATE_KEY
export DROSERA_PRIVATE_KEY="$private_key"
echo "export DROSERA_PRIVATE_KEY=\"$private_key\"" >> ~/.bashrc
source ~/.bashrc

# 11. Apply trap lần 1 (Auto Apply)
echo -e "${YELLOW}⚡ Apply Trap lần 1...${NC}"
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 12. Check drosera.toml tồn tại
cd ~/my-drosera-trap
if [[ -f "drosera.toml" ]]; then
    echo -e "${GREEN}✅ File drosera.toml đã tồn tại.${NC}"
else
    echo -e "${RED}❌ Không tìm thấy drosera.toml. Script dừng.${NC}"
    exit 1
fi

# 13. Hướng dẫn thao tác web
echo -e "${YELLOW}➡️ Truy cập https://app.drosera.io/ để gửi Bloom Boost.${NC}"

while true; do
    read -p "Bạn đã hoàn thành gửi Boost chưa? (N để tiếp tục / Y nếu chưa): " response
    case $response in
        [Nn]* ) break ;;
        [Yy]* ) echo "Hãy hoàn thành trên web trước khi tiếp tục." ;;
        * ) echo "Chỉ được nhập 'Y' hoặc 'N'." ;;
    esac
done

# 14. drosera dryrun
drosera dryrun

# 15. Update whitelist
echo "Nhập địa chỉ ví EVM Operator của bạn:"
read operator_address

echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$operator_address\"]" >> drosera.toml

# Xóa dòng whitelist = [] cũ
sed -i '/whitelist = \[\]/d' drosera.toml

echo -e "${GREEN}✅ Đã thêm whitelist vào drosera.toml và xoá whitelist = [] cũ.${NC}"

# 16. Hiển thị Banner và Loading 10 phút
if ! command -v figlet &> /dev/null
then
    echo -e "${YELLOW}⚡ Đang cài figlet để in banner đẹp...${NC}"
    $SUDO_CMD apt install figlet -y
fi

clear
figlet -f big "PIZ"
echo "============================================================="
echo "Follow me on Twitter for updates and more: https://whalepiz"
echo "============================================================="
echo ""

echo -e "${YELLOW}⌛ Đang chờ 10 phút để đồng bộ trap...${NC}"
loading_bar 600

# 17. Apply lại trap lần 2
echo -e "${YELLOW}⚡ Apply Trap lần 2...${NC}"
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 18. Cài drosera-operator
cd ~
echo -e "${YELLOW}⬇️ Tải drosera-operator...${NC}"
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
$SUDO_CMD cp drosera-operator /usr/bin/
drosera-operator --version

# 19. Docker Image drosera-operator
$SUDO_CMD docker pull ghcr.io/drosera-network/drosera-operator:latest

# 20. Mở firewall
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw --force enable
$SUDO_CMD ufw status

# 21. Clone Drosera-Network + chỉnh .env
cd ~
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env

sed -i "s/[yY][oO][uU][rR]_[eE][vV]_[pP]rivate_[kK]ey/$private_key/" .env

echo "Nhập địa chỉ IP Public của VPS:"
read vps_ip
sed -i "s/[yY][oO][uU][rR]_[vV][pP]s_[pP]ublic_[iI]p/$vps_ip/" .env

# 22. docker compose
$SUDO_CMD docker compose up -d
$SUDO_CMD docker compose down
$SUDO_CMD docker compose up -d

echo -e "${GREEN}✅ Hoàn tất cài đặt Drosera Trap + Operator!${NC}"
