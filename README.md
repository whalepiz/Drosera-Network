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

## Facet Ethereum Holesky 

Facet : [Holesky Faucet](https://holesky-faucet.pk910.de/))

## Ethereum Holesky RPC URL:
* Create your own `Ethereum Holesky RPC` in [Alchemy](https://dashboard.alchemy.com/).

## Installation
◾ Clone the Repository
```
git clone https://github.com/whalepiz/Drosera-Network/
cd Drosera-Network && chmod +x s.sh && ./s.sh
```

### **Important Note: Ethereum Holesky Faucet**

Before starting, you need to **Faucet Ethereum Holesky** into the wallet addresses of both Operator 1 and Operator 2. Visit the **Holesky Faucet** page to request test ETH for both wallets. Ensure that you have enough ETH in these wallets before proceeding with the setup.

---

### **Summary of User Input Requirements:**

1. **Private Key of Operator 1**
2. **Public Address of Operator 1**
3. **Private Key of Operator 2**
4. **Public Address of Operator 2**
5. **VPS Public IP** (can be auto-detected or manually entered)
6. **Ethereum Holesky RPC URL** (optional)
7. **GitHub Email**
8. **GitHub Username**

---

Make sure to enter all the above information correctly for the script to function properly.

## Last Steps

1. **Monitor Node Status**:
   Once the script finishes, head over to the [https://app.drosera.io/](https://app.drosera.io/) to check for green blocks, which indicate that your node is live and functioning properly.
   You can also monitor the node’s activity through Docker logs:

     ```bash
     cd ~/Drosera-Network
     docker logs drosera-node1
     ```
or

   ```bash
     cd ~/Drosera-Network
     docker logs drosera-node2
   ```

 Make sure to check for green block logs on your dashboard. (Wait for at least 1 hour to ensure the data updates correctly.)

![image](https://github.com/user-attachments/assets/d2d89770-25fb-4ed8-a49c-4d339cd740fe)



2. **Optional Command (Restart and Dryrun Node):**:
     ```bash
     cd ~/Drosera-Network
     docker compose down -v
     pkill -f drosera-operator
     cd ~
     cd my-drosera-trap
     source /root/.bashrc
     drosera dryrun
     cd ~
     cd Drosera-Network
     docker compose up -d
     ```






