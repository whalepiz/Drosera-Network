# Drosera-Network
In this Guide, we contribute to Drosera testnet by:
1. Installing the CLI
2. Setting up a vulnerable contract
3. Deploying a Trap on testnet
4. Connecting an operator to the Trap

## Recommended System Requirements
* 2 CPU Cores
* 4 GB RAM
* 20 GB Disk Space
* Get started with a low-budget `VPS` for as low as $5! [Purchase here](https://xorek.cloud/?from=27450)
![image](https://github.com/user-attachments/assets/691efaf0-c589-45df-b2c0-62578e908a56)

After purchasing, access the panel to change the VPS login password
![image](https://github.com/user-attachments/assets/f691baf1-49e5-4246-a5f0-5729c2eef541)
Select "Change password" to change the password
![image](https://github.com/user-attachments/assets/faf2aacf-3562-446d-a075-61259a015fe5)

## Facet Ethereum Holesky 

Facet : [Holesky Faucet](https://holesky-faucet.pk910.de/))

## Ethereum Holesky RPC URL:
* Create your own `Ethereum Holesky RPC` in [Alchemy](https://dashboard.alchemy.com/).
## PuTTY

* You can use PuTTY to log in to the VPS.
  
![image](https://github.com/user-attachments/assets/869a8124-b57d-4768-bc81-67dc44d6a8d9)

## GitHub Account:
*Provide your GitHub email and username for configuring Git during the setup

## Installation
◾ Clone the Repository
```
git clone https://github.com/whalepiz/Drosera-Network/
cd Drosera-Network && chmod +x pc.sh && ./pc.sh
```
## Provide Information:
*The script will prompt you to enter the following details accurately:

🔸 Private Key: 

🔸 Public Address: 

🔸 Ethereum Holesky RPC URL: 
* Your RPC URL from Alchemy, QuickNode, or a public node. Press Enter to use the default (https://ethereum-holesky-rpc.publicnode.com).
* Example: https://eth-holesky.alchemyapi.io/v2/your-api-key
  
🔸 GitHub Email:

🔸 GitHub Username: 

## Check Node Liveness

🔸 Once the script execution is complete, navigate to the Drosera Dashboard at https://app.drosera.io/ to verify node activity. Look for green blocks, which indicate that your nodes are live and operational.

🔸 To monitor node performance in real-time, you can inspect the Docker logs using the following command:

```
cd ~/Drosera-Network
docker logs -f drosera-node
```
🔸 Check That you Have Green Block Log on your Dashboard ( Wait For At Least 1 Hour To Check )

![image](https://github.com/user-attachments/assets/0d1b0211-f970-45b2-9be2-3c4db6554d7c)

## Optional Command  [if required ]
```
pkill -f drosera-operator
cd ~
cd my-drosera-trap
source /root/.bashrc
drosera dryrun
cd ~
cd Drosera-Network
docker compose up -d
```




