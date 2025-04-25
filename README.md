# Drosera-Network
In this Guide, we contribute to Drosera testnet by:
1. Installing the CLI
2. Setting up a vulnerable contract
3. Deploying a Trap on testnet
4. Connecting an operator to the Trap

# Recommended System Requirements
* 2 CPU Cores
* 4 GB RAM
* 20 GB Disk Space
* Get started with a low-budget `VPS` for as low as $5! [Purchase here](https://xorek.cloud/?from=27450)
![image](https://github.com/user-attachments/assets/691efaf0-c589-45df-b2c0-62578e908a56)

After purchasing, access the panel to change the VPS login password
![image](https://github.com/user-attachments/assets/f691baf1-49e5-4246-a5f0-5729c2eef541)
Select "Change password" to change the password
![image](https://github.com/user-attachments/assets/faf2aacf-3562-446d-a075-61259a015fe5)

* Create your own `Ethereum Holesky RPC` in [Alchemy](https://dashboard.alchemy.com/).

* You can use PuTTY to log in to the VPS.

  ![image](https://github.com/user-attachments/assets/869a8124-b57d-4768-bc81-67dc44d6a8d9)

### Install Dependecies
```
sudo apt-get update && sudo apt-get upgrade -y
```
```
sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
```
Docker:
```bash
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker
sudo docker run hello-world
```

<h1 align="center">Trap Setup</h1>

## 1. Configure Enviorments
**Drosera CLI**:
```bash
curl -L https://app.drosera.io/install | bash
```
```
source /root/.bashrc
```
```
droseraup
```

**Foundry CLI**:
```
curl -L https://foundry.paradigm.xyz | bash
```
```
source /root/.bashrc
```
```
foundryup
```

**Bun:**
```
curl -fsSL https://bun.sh/install | bash

source /root/.bashrc
```

---

## 2. Deploy Contract & Trap
```bash
mkdir my-drosera-trap
```
```bash
cd my-drosera-trap
```
**Replace `Github_Email` & `Github_Username`:**
```bash
git config --global user.email "Github_Email"
git config --global user.name "Github_Username"
```
**Initialize Trap**:
```
forge init -t drosera-network/trap-foundry-template
```
**Compile Trap**:
```bash
curl -fsSL https://bun.sh/install | bash

source /root/.bashrc

bun install
```
```bash
forge build
```
> skip warnings!

**Deploy Trap**:
```bash
DROSERA_PRIVATE_KEY=XXX drosera apply --eth-rpc-url RPC_YOU
```
* Replace `xxx` with your EVM wallet `privatekey` (Ensure it's funded with `Holesky ETH`)
* Enter the command, when prompted, write `ofc` and press Enter.

![image](https://github.com/user-attachments/assets/6d1161f1-4423-4ce6-a1a2-77ce567186dc)

🚨 Error: You may get several errors (.eg #429) due to `rpc` issues, to fix, you can enter bellow command by adding `--eth-rpc-url`
```bash
DROSERA_PRIVATE_KEY=xxx drosera apply --eth-rpc-url RPC
```
* Replace `RPC` with your own Ethereum Holesky rpc by registering and creating one in [Alchemy](https://dashboard.alchemy.com/).

---

## 3. Check Trap in Dashboard
1- Connect your Drosera EVM wallet: https://app.drosera.io/

2- Click on `Traps Owned` to see  your deployed Traps OR search your Trap address.

![image](https://github.com/user-attachments/assets/9c39eea0-0aaf-417d-8552-765ff33f8a5e)

---

## 4. Bloom Boost Trap
Open your Trap on Dashboard and Click on `Send Bloom Boost` and deposit some `Holesky ETH` on it.

![image](https://github.com/user-attachments/assets/2f5216fd-fdf9-4732-96d0-959b3fbce479)

## 5. Fetch Blocks
```bash
drosera dryrun
```
* You can

---

<h1 align="center">Operator Setup</h1>

## 1. Whitelist Your Operator
**1- Edit Trap configuration:**
```bash
nano drosera.toml
```
Add the following codes at the bottom of `drosera.toml`:
```toml
private_trap = true
whitelist = ["Operator_Address"]
```
* Replace `Operator_Address` with your EVM wallet `Public Address` between " " symbols
* Your `Public Address` is your `Operator_Address`.

**2- Update Trap Configuration:**
```bash
DROSERA_PRIVATE_KEY=XXX drosera apply --eth-rpc-url RPC_YOU
```
* Replace `xxx` with your EVM wallet `privatekey`
* If RPC issue, use `DROSERA_PRIVATE_KEY=xxx drosera apply --eth-rpc-url RPC` and replace `RPC` with your own.

Your Trap should be private now with your operator address whitelisted internally.

![image](https://github.com/user-attachments/assets/9ae6d58e-3be7-4d0d-9c4b-3b486224df4e)

---

## 2. Operator CLI
```bash
cd ~
```
```bash
# Download
curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz

# Install
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
```
Test the CLI with `./drosera-operator --version` to verify it's working.
```console
# Check version
./drosera-operator --version

# Move path to run it globally
sudo cp drosera-operator /usr/bin

# Check if it is working
drosera-operator
```

## 3. Install Docker image
```
docker pull ghcr.io/drosera-network/drosera-operator:latest
```

---

## 4. Register Operator
```bash
drosera-operator register --eth-rpc-url RPC_YOU --eth-private-key PV_KEY
```
* Replace `PV_KEY` with your Drosera EVM `privatekey`. We use the same wallet as our trap wallet.

---

## 5. Open Ports
```bash
# Enable firewall
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw enable

# Allow Drosera ports
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
```
## Method 1: Docker
### 6-1-1: Configure Docker
* Make sure you have installed `Docker` in Dependecies step.

If you are currently running via old `systemd` method, stop it:
```
sudo systemctl stop drosera
sudo systemctl disable drosera
```
```
git clone https://github.com/0xmoei/Drosera-Network
```
```
cd Drosera-Network
```
```
cp .env.example .env
```
Edit `.env` file:
```
nano .env
```
* Replace `your_evm_private_key` and `your_vps_public_ip`
* To save: `CTRL`+`X`, `Y` & `ENTER`.

Edit `docker-compose.yaml` file:
```bash
nano docker-compose.yaml
```
* Replace default `rpc` to your private [Alchemy](https://dashboard.alchemy.com/) or [QuickNode](https://dashboard.quicknode.com/) Ethereum Holesky RPCs.
* To save: `CTRL`+`X`, `Y` & `ENTER`.

### 6-1-2: Run Operator
```
docker compose up -d
```

### 6-1-3: Check health
```
docker logs -f drosera-node
```

![image](https://github.com/user-attachments/assets/2ec4d181-ac60-4702-b4f4-9722ef275b50)

>  No problem if you are receiveing `WARN drosera_services::network::service: Failed to gossip message: InsufficientPeers`

### 6-1-4: Optional Docker commands
```console
# Stop node
cd Drosera-Network
docker compose down -v

# Restart node
cd Drosera-Network
docker compose up -d
```

**Now running your node using `Docker`, you can Jump to step 7.**

---


## 7. Opt-in Trap
In the dashboard., Click on `Opti in` to connect your operator to the Trap

![image](https://github.com/user-attachments/assets/5189b5cb-cb46-4d10-938a-33f71951dfc2)

---

## 8. Check Node Liveness
Your node will start producing greeen blocks in the dashboard

![image](https://github.com/user-attachments/assets/9ad08265-0ea4-49f7-85e5-316677245254)

---

