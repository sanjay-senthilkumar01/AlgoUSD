# Deployment Instructions

## Overview
This folder contains reproducible deploy scripts for testnet/mainnet using Foundry and Hardhat tools. The deployments are idempotent and utilize environment variables to configure parameters securely. Expected deployed addresses include TimelockController, OracleAggregator, CircuitBreaker, and Multisig.

---

## Requirements

### Installed Tools
1. **Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Node.js** and **npm**:
   ```bash
   sudo apt install nodejs npm
   ```

3. **Hardhat**:
   ```bash
   npm install --save-dev hardhat
   ```

### Environment Variables:
Configure the following variables in your `.env` file:
```env
RPC_URL=https://rpc.chainstack.com
PRIVATE_KEY=<your-private-key>
PRICE_FEED_ADDRESS_1=<chainlink-price-feed-primary-address>
PRICE_FEED_ADDRESS_2=<chainlink-price-feed-fallback-address>
TIMELOCK_ADMIN=<timelock-admin-address>
MULTISIG_SIGNERS=0xSigner1,0xSigner2,0xSigner3,0xSigner4,0xSigner5
MULTISIG_ADMIN=<multisig-admin-address>
```

---

## Deployment Instructions
### Foundry
Perform deployment with Foundry as follows:

1. **Navigate to Deployment Folder**
```bash
cd deploy
```

2. **Run Foundry Deployment**
```bash
forge script deploy/foundry-deploy.s.sol --broadcast --rpc-url $RPC_URL
```

3. **Expected Output**
After running successfully, expect logs with the deployed:
- AlgoUSD contract
- TimelockController addresses.


--- Additional Confirmation Artifacts present Updated Test Deployment driven --- example-driven Logical Used Cross Scripting language support, debugging Runtime