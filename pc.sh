#!/bin/bash

# ========================
# Script cài Drosera Trap + Operator Full Auto
# Người viết: Đã Fix lỗi drosera apply + Tối ưu hoá
# ========================

# Kiểm tra quyền sudo
if sudo -v &>/dev/null; then
    echo "Bạn có quyền sử dụng sudo."
    SUDO_CMD="sudo"
else
    echo "Bạn không có quyền sử dụng sudo."
    SUDO_CMD=""
fi

# Cập nhật hệ thống
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y

# Cài đặt gói cần thiết
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev ca-certificates gnupg -y

# Cài đặt Docker
if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null

    $SUDO_CMD apt-get update && $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Kiểm tra docker
    $SUDO_CMD docker run hello-world
fi

# Cài Drosera CLI, Foundry, Bun
curl -L https://app.drosera.io/install | bash
curl -L https://foundry.paradigm.xyz | bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# Tạo trap
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# Git config
echo "Nhập GitHub Email của bạn:"
read github_email
echo "Nhập GitHub Username của bạn:"
read github_username

git config --global user.email "$github_email"
git config --global user.name "$github_username"

# Init trap
forge init -t drosera-network/trap-foundry-template
bun install
forge build

# Lấy PRIVATE_KEY và RPC
echo "Hãy Nhập PRIVATE_KEY của bạn:"
read private_key
echo "Hãy Nhập RPC URL của bạn:"
read rpc_url

# Export để drosera apply thành công
export DROSERA_PRIVATE_KEY="$private_key"
echo "export DROSERA_PRIVATE_KEY=\"$private_key\"" >> ~/.bashrc
source ~/.bashrc

# drosera apply
drosera apply --eth-rpc-url "$rpc_url"

# Hướng dẫn người dùng
echo "Bây giờ truy cập https://app.drosera.io/"
echo "1. Kết nối ví, chọn 'Traps Owned'"
echo "2. Send Bloom Boost => Gửi Holesky ETH"
echo "=> Sau đó quay lại đây và nhấn 'N' để tiếp tục"

while true; do
    read -p "Bạn đã làm xong chưa? (Nhấn 'N' để tiếp tục hoặc 'Y' nếu chưa): " response
    case $response in
        [Nn]* ) 
            echo "Tiếp tục chạy lệnh..."
            break
            ;;
        [Yy]* ) 
            echo "Hãy hoàn thành các bước trên web rồi nhấn N sau."
            ;;
        * ) 
            echo "Vui lòng nhập 'Y' hoặc 'N'."
            ;;
    esac
done

# drosera dryrun
drosera dryrun

# Update drosera.toml whitelist
echo "Nhập địa chỉ ví EVM của bạn (Operator Address):"
read operator_address

config_file="./my-drosera-trap/drosera.toml"
if [[ -f "$config_file" ]]; then
    echo "private_trap = true" >> "$config_file"
    echo "whitelist = [\"$operator_address\"]" >> "$config_file"
    echo "Đã cập nhật whitelist trong drosera.toml."
else
    echo "Không tìm thấy file drosera.toml."
fi

# Đợi 10 phút
echo "Đang chờ 10 phút (sync trap)..."
for ((i=10; i>0; i--)); do
    echo "Còn $i phút..."
    sleep 60
done

# drosera apply lại
drosera apply --eth-rpc-url "$rpc_url"

# Cài đặt drosera-operator
cd ~
echo "Tải và cài drosera-operator..."
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
$SUDO_CMD cp drosera-operator /usr/bin/
drosera-operator --version

# Cài docker image drosera-operator
docker pull ghcr.io/drosera-network/drosera-operator:latest

# Mở firewall
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw --force enable
$SUDO_CMD ufw status

# Clone Drosera-Network và chỉnh sửa .env
cd ~
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env

sed -i "s/[yY][oO][uU][rR]_[eE][vV]_[pP]rivate_[kK]ey/$private_key/" .env

echo "Nhập địa chỉ IP public của VPS:"
read vps_ip
sed -i "s/[yY][oO][uU][rR]_[vV][pP]s_[pP]ublic_[iI]p/$vps_ip/" .env

echo "Đã chỉnh sửa file .env."

# docker compose
docker compose up -d

# Restart container
docker compose down
docker compose up -d

echo "✅ Cài đặt thành công Drosera Trap + Operator!"
