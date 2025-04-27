#!/bin/bash

# Kiểm tra xem người dùng có quyền sudo không
if sudo -v &>/dev/null; then
    echo "Bạn có quyền sử dụng sudo."
    SUDO_CMD="sudo"
else
    echo "Bạn không có quyền sử dụng sudo."
    SUDO_CMD=""
fi

# Cập nhật và nâng cấp hệ thống
$SUDO_CMD apt-get update && $SUDO_CMD apt-get upgrade -y

# Cài đặt các gói cần thiết
$SUDO_CMD apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# Cài đặt Docker (Nếu người dùng có quyền sudo)
if [ -n "$SUDO_CMD" ]; then
    # Cài đặt Docker nếu có quyền sudo
    $SUDO_CMD apt update -y && $SUDO_CMD apt upgrade -y
    $SUDO_CMD apt-get install ca-certificates curl gnupg
    $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.gpg

    # Thêm kho Docker vào nguồn cài đặt
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Cập nhật và nâng cấp lại sau khi thêm kho Docker
    $SUDO_CMD apt update -y && $SUDO_CMD apt upgrade -y
    $SUDO_CMD apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Kiểm tra Docker đã cài đặt thành công
    $SUDO_CMD docker run hello-world
fi

# Cài đặt Drosera CLI
curl -L https://app.drosera.io/install | bash
source ~/.bashrc
droseraup

# Cài đặt Foundry CLI
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# Cài đặt Bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# Tạo thư mục cho việc thiết lập Drosera Trap
mkdir my-drosera-trap
cd my-drosera-trap

# Nhập email và username của GitHub từ người dùng
echo "Nhập GitHub Email của bạn:"
read github_email

echo "Nhập GitHub Username của bạn:"
read github_username

# Thay đổi thông tin GitHub Email và Username
git config --global user.email "$github_email"
git config --global user.name "$github_username"

# Khởi tạo Trap
forge init -t drosera-network/trap-foundry-template

# Cài đặt Bun và build Trap
bun install
forge build

# Nhập PRIVATE_KEY và RPC_URL từ người dùng
echo "Hãy Nhập PRIVATE_KEY của bạn:"
read private_key

echo "Hãy Nhập RPC của bạn:"
read rpc_url

# Thay thế giá trị PRIVATE_KEY và RPC_URL vào lệnh drosera apply
DROSERA_PRIVATE_KEY=$private_key drosera apply --eth-rpc-url $rpc_url

# Hướng dẫn người dùng thực hiện các bước tiếp theo trên trang Drosera
echo "Bây giờ, bạn cần thực hiện các bước sau trên trang web Drosera:"
echo "1. Truy cập https://app.drosera.io/."
echo "2. Kết nối ví của bạn."
echo "3. Sau khi kết nối ví, hãy click vào 'Traps Owned'."
echo "4. Tiếp theo, nhấn vào 'Send Bloom Boost' để gửi Holesky ETH."
echo "Khi bạn đã thực hiện xong, nhấn 'N' để tiếp tục chạy lệnh tiếp theo."

# Tự động tiếp tục sau khi thực hiện các bước trên trang web Drosera
echo "Tự động tiếp tục sau khi thực hiện các bước trên trang web Drosera..."

# Chạy lệnh drosera dryrun
echo "Bây giờ, chạy lệnh drosera dryrun..."
drosera dryrun

# Nhập địa chỉ ví EVM từ người dùng để thay vào whitelist
echo "Hãy Nhập địa chỉ ví EVM của bạn (Operator_Address):"
read operator_address

# Cập nhật file drosera.toml và thay thế vào whitelist
config_file="./my-drosera-trap/drosera.toml"

# Kiểm tra nếu file drosera.toml tồn tại
if [[ -f "$config_file" ]]; then
    # Thêm dòng vào file
    echo "private_trap = true" >> "$config_file"
    echo "whitelist = [\"$operator_address\"]" >> "$config_file"
    echo "Đã thêm địa chỉ ví vào whitelist và cập nhật file drosera.toml."
else
    echo "File drosera.toml không tìm thấy trong thư mục my-drosera-trap."
fi

# Đợi 10 phút
echo "Đang chờ 10 phút..."
sleep 600  # 600 giây tương đương 10 phút

echo "Đã đợi 10 phút. Tiến hành bước tiếp theo..."

# Cuối cùng, chạy lệnh drosera apply với PRIVATE_KEY và RPC_URL đã thay thế trước đó
echo "Bây giờ, chạy lệnh drosera apply với các tham số đã thay thế..."
DROSERA_PRIVATE_KEY=$private_key drosera apply --eth-rpc-url $rpc_url

# Tiến hành cài đặt drosera-operator
echo "Chuyển đến thư mục home..."
cd ~

# Tải xuống drosera-operator
echo "Tải drosera-operator..."
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz

# Giải nén và cài đặt drosera-operator
echo "Giải nén và cài đặt drosera-operator..."
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz

# Kiểm tra phiên bản
echo "Kiểm tra phiên bản drosera-operator..."
./drosera-operator --version

# Di chuyển drosera-operator vào thư mục /usr/bin để chạy toàn cục
echo "Di chuyển drosera-operator vào /usr/bin..."
$SUDO_CMD cp drosera-operator /usr/bin

# Kiểm tra lại drosera-operator
echo "Kiểm tra drosera-operator..."
drosera-operator

# Cài đặt Docker image của drosera-operator
echo "Tải Docker image của drosera-operator..."
docker pull ghcr.io/drosera-network/drosera-operator:latest

# Mở các cổng firewall cần thiết
echo "Mở các cổng firewall..."
$SUDO_CMD ufw allow ssh
$SUDO_CMD ufw allow 22
$SUDO_CMD ufw enable

# Cho phép các cổng của Drosera
$SUDO_CMD ufw allow 31313/tcp
$SUDO_CMD ufw allow 31314/tcp
$SUDO_CMD ufw allow 30304/tcp
$SUDO_CMD ufw status

# Git clone Drosera-Network repository
echo "Cloning Drosera-Network repository..."
git clone https://github.com/whalepiz/Drosera-Network
cd Drosera-Network
cp .env.example .env

# Sửa file .env
echo "Đang sửa file .env..."

# Thay đổi giá trị your_evm_private_key thành private_key mà người dùng nhập
sed -i "s/[yY][oO][uU][rR]_[eE][vV]_[pP]rivate_[kK]ey/$private_key/" .env

# Nhập địa chỉ IP của VPS
echo "Hãy Nhập địa chỉ IP của VPS (your_vps_public_ip):"
read vps_ip

# Thay đổi giá trị your_vps_public_ip trong file .env
sed -i "s/[yY][oO][uU][rR]_[vV][pP]s_[pP]ublic_[iI]p/$vps_ip/" .env

echo "File .env đã được sửa và lưu lại."

# Tiến hành chạy lệnh `docker compose up -d`
echo "Chạy docker compose up -d..."
docker compose up -d

# Quay lại thư mục home và chạy các lệnh docker compose tiếp theo
cd ~

# Quay lại thư mục Drosera-Network và tắt Docker container
cd ~/Drosera-Network
docker compose down

# Chạy lại Docker container với lệnh up
docker compose up -d
