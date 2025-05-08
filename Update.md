# How to Upgrade Your Drosera Node

# 1. Stop your Docker

## If using Docker:

```
cd ~
cd ~/Drosera-Network
docker compose down -v
```
```
pkill -f drosera-operator
```

# 2. Update Drosera:

```
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.17.1/drosera-operator-v1.17.1-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.17.1-x86_64-unknown-linux-gnu.tar.gz
sudo cp drosera-operator /usr/bin
drosera-operator --version
```

# 3. Install Docker Image

```
docker pull ghcr.io/drosera-network/drosera-operator:latest
```

# 4. Apply New RPC:

1. Navigate to your Drosera configuration directory:

```cd ~
cd my-drosera-trap
nano drosera.toml
```
2. Update the drosera_rpc in the file: Replace:

   ```
   drosera_rpc = "http://seed-node.testnet.drosera.io"
   ```
   Replace with:

   ```
   drosera_team = "https://relayer.testnet.drosera.io/
   ```
   
```
cd && cd my-drosera-trap && source /root/.bashrc && drosera dryrun

```

# Put Your Private key 

```
DROSERA_PRIVATE_KEY=your_private_key drosera apply
```

# Restart node 
```
cd && cd Drosera-Network
docker compose up -d && cd

```
