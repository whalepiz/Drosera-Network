#!/bin/bash

# ========================
# Script Cài Drosera Trap + Operator FULL AUTO
# Phiên bản: Auto Apply + Fix whitelist = []
# ========================

# 1. Kiểm tra quyền sudo
if sudo -v &>/dev/null; then
    echo "Bạn có quyền sudo."
    SUDO_CMD="sudo"
else
    echo "Bạn KHÔNG có quyền sudo."
    SUDO_CMD=""
fi

# 2. Cập nhật hệ thống
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y

# 3. Cài các gói cần thiết
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev ca-certificates gnupg -y

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

# 10. Export PRIVATE_KEY
export DROSERA_PRIVATE_KEY="$private_key"
echo "export DROSERA_PRIVATE_KEY=\"$private_key\"" >> ~/.bashrc
source ~/.bashrc

# 11. Apply trap lần 1 (Auto Apply)
echo "⚡ Đang apply trap lần đầu..."
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 12. Check drosera.toml tồn tại
cd ~/my-drosera-trap
if [[ -f "drosera.toml" ]]; then
    echo "✅ File drosera.toml đã tồn tại."
else
    echo "❌ Không tìm thấy drosera.toml. Script dừng."
    exit 1
fi

# 13. Hướng dẫn thao tác web
echo "➡️ Truy cập https://app.drosera.io/"
echo "1. Kết nối ví => Traps Owned."
echo "2. Gửi Holesky ETH (Send Bloom Boost)."
echo "3. Sau khi xong, quay lại đây và nhấn N để tiếp tục."

# 14. Hỏi user đã xong chưa
while true; do
    read -p "Bạn đã xong trên web chưa? (Nhập N để tiếp tục / Y nếu chưa): " response
    case $response in
        [Nn]* ) 
            echo "Tiếp tục..."
            break
            ;;
        [Yy]* ) 
            echo "Hãy hoàn thành trên web trước khi tiếp tục."
            ;;
        * ) 
            echo "Chỉ được nhập 'Y' hoặc 'N'."
            ;;
    esac
done

# 15. drosera dryrun
drosera dryrun

# 16. Update whitelist
echo "Nhập địa chỉ ví EVM Operator của bạn:"
read operator_address

# Ghi vào drosera.toml
echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"$operator_address\"]" >> drosera.toml

# Xóa dòng whitelist = [] cũ
sed -i '/whitelist = \[\]/d' drosera.toml

echo "✅ Đã thêm whitelist vào drosera.toml và xoá whitelist = [] cũ."

# 17. Chờ 10 phút để sync
echo "⌛ Đang đợi 10 phút sync trap..."
for ((i=10; i>0; i--)); do
    echo "Còn $i phút..."
    sleep 60
done

# 18. Apply lại trap lần 2 (Auto Apply)
echo "⚡ Đang apply trap lần 2..."
echo "ofc" | drosera apply --eth-rpc-url "$rpc_url"

# 19. Cài drosera-operator
cd ~
echo "⬇️ Tải drosera-operator..."
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
$SUDO_CMD cp drosera-operator /usr/bin/
drosera-operator --version

# 20. Docker Image drosera-operator
docker pull ghcr.io/drosera-network/drosera-operator:latest

# 21. Mở firewall
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw --force enable
$SUDO_CMD ufw status

# 22. Clone Drosera-Network + chỉnh .env
cd ~
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env

sed -i "s/[yY][oO][uU][rR]_[eE][vV]_[pP]rivate_[kK]ey/$private_key/" .env

echo "Nhập địa chỉ IP Public của VPS:"
read vps_ip
sed -i "s/[yY][oO][uU][rR]_[vV][pP]s_[pP]ublic_[iI]p/$vps_ip/" .env

# 23. docker compose
docker compose up -d
docker compose down
docker compose up -d

echo "✅ Hoàn tất cài đặt Drosera Trap + Operator!"
