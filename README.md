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

## 🏁 Final Steps

1. **Monitor Node Status**:
   - After the script completes, visit the Drosera dashboard at [https://app.drosera.io/](https://app.drosera.io/) to check for green blocks indicating node liveness.
   - You can also view Docker logs to monitor the nodes:

     ```bash
     cd ~/Drosera-Network
     docker logs drosera-node1
     ```
or

   ```bash
     cd ~/Drosera-Network
     docker logs drosera-node2
   ```

   - Check That you Have Green Block Log on your Dashboard ( Wait For At Least 1 Hour To Check )

![Screenshot 2025-04-26 105901](https://github.com/user-attachments/assets/6ec00420-7e4c-49c9-a64a-0efc2dfccb2c)

2. **Optional Command (Restart and Dryrun Node)**:
   - To fetch blocks again and restart the node, run:
     ```bash
     pkill -f drosera-operator
     cd ~
     cd my-drosera-trap
     source /root/.bashrc
     drosera dryrun
     cd ~
     cd Drosera-Network
     docker compose up -d
     ```

3. **Stay Updated**:
   - Follow [Drosera](https://x.com/DroseraNetwork) on Twitter for the latest news and updates about Drosera .

4. **Get Support**:
   - If you have questions or need help, reach out via [Twitter](https://x.com/0xCrypton_) or the Drosera community.

🚀 **Done!** Your Drosera node should now be running smoothly.




